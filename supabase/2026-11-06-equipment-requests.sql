-- Equipment requests (Nov 6, 2026).
-- Players can ask Coach for equipment from the "What you need" list on an activity.
-- Requests are stored with questions, marked kind = 'request', and coaches answer them
-- the same way (coach_reply). Safe for the old app: the new column has a default and
-- the JSON only gains a field.

alter table public.questions
  add column if not exists kind text not null default 'question'
  check (kind in ('question', 'request'));

-- player_home: same as before, plus each question's kind
create or replace function public.player_home(p_token uuid) returns json
language plpgsql stable security definer set search_path = public as $$
declare pid uuid;
begin
  pid := _session_player(p_token);
  return json_build_object(
    'name', (select name from players where id = pid),
    'entries', _entries(pid),
    'activities', coalesce((
      select json_agg(x order by x.sort_order, x.created_at) from (
        select a.id, a.title, a.summary, a.category, a.video_url, a.image_url, a.drill_steps, a.video_requested, a.video_note,
               a.sort_order, a.created_at,
               (select coalesce(json_agg(json_build_object('q', e.q->>'q', 'options', e.q->'options') order by e.ord), '[]'::json)
                  from jsonb_array_elements(a.quiz) with ordinality as e(q, ord)) as quiz,
               coalesce(pr.watched, false) as watched,
               coalesce(pr.quiz_done, false) as quiz_done,
               coalesce(pr.quiz_best, 0) as quiz_best,
               coalesce(pr.drill_done, false) as drill_done,
               coalesce(pr.video_sent, false) as video_sent,
               pr.completed_at
          from activities a
          left join progress pr on pr.activity_id = a.id and pr.player_id = pid
         where a.published
      ) x), '[]'::json),
    'questions', coalesce((
      select json_agg(json_build_object('id', q.id, 'body', q.body, 'reply', q.reply, 'kind', q.kind,
                                        'activity_id', q.activity_id, 'created_at', q.created_at)
                      order by q.created_at desc)
        from questions q where q.player_id = pid), '[]'::json)
  );
end $$;

-- coach_dashboard: same as before, plus each question's kind
create or replace function public.coach_dashboard(p_token uuid) returns json
language plpgsql stable security definer set search_path = public as $$
begin
  perform _require_coach(p_token);
  return json_build_object(
    'players', coalesce((select json_agg(json_build_object('id', p.id, 'name', p.name, 'bonus', p.bonus_entries,
                                  'entries', _entries(p.id), 'locked', (p.locked_until is not null and p.locked_until > now()))
                                  order by p.name) from players p), '[]'::json),
    'activities', coalesce((select json_agg(a order by a.sort_order, a.created_at) from activities a), '[]'::json),
    'progress', coalesce((select json_agg(pr) from progress pr), '[]'::json),
    'questions', coalesce((select json_agg(json_build_object('id', q.id, 'player', p.name, 'activity_id', q.activity_id,
                                  'body', q.body, 'reply', q.reply, 'kind', q.kind, 'created_at', q.created_at)
                                  order by (q.reply is not null), q.created_at desc)
                             from questions q join players p on p.id = q.player_id), '[]'::json),
    'draws', coalesce((select json_agg(d order by d.drawn_at desc) from raffle_draws d), '[]'::json),
    'round_start', (select value from settings where key = 'round_start')
  );
end $$;

-- New: a player asks for equipment for an activity
create or replace function public.player_request_equipment(p_token uuid, p_activity uuid, p_body text) returns json
language plpgsql security definer set search_path = public as $$
declare pid uuid;
begin
  pid := _session_player(p_token);
  insert into questions(player_id, activity_id, body, kind) values (pid, p_activity, btrim(p_body), 'request');
  return player_home(p_token);
end $$;

revoke execute on function public.player_request_equipment(uuid, uuid, text) from public, authenticated;
grant execute on function public.player_request_equipment(uuid, uuid, text) to anon;
