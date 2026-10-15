-- Jacks Home Practice: full database setup (reference copy, already applied to project ieivgzhdgjizwabdlixs).
-- After running on a fresh project, seed the coach passphrase:
--   insert into public.settings(key, value) values ('coach_pass_hash', extensions.crypt('<choose one>', extensions.gen_salt('bf')));

create extension if not exists pgcrypto with schema extensions;

create table public.settings (key text primary key, value text not null);

create table public.players (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 40),
  name_key text generated always as (lower(btrim(name))) stored,
  pin_hash text not null,
  bonus_entries int not null default 0,
  failed_attempts int not null default 0,
  locked_until timestamptz,
  created_at timestamptz not null default now(),
  constraint players_name_key_uniq unique (name_key)
);

create table public.sessions (
  token uuid primary key default gen_random_uuid(),
  role text not null check (role in ('player','coach')),
  player_id uuid references public.players(id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '90 days'
);

create table public.activities (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  summary text not null default '',
  video_url text,
  drill_steps text not null default '',
  quiz jsonb not null default '[]'::jsonb,   -- [{ "q": text, "options": [text], "answer": int }]
  video_requested boolean not null default false,
  video_note text not null default '',
  sort_order int not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.progress (
  player_id uuid not null references public.players(id) on delete cascade,
  activity_id uuid not null references public.activities(id) on delete cascade,
  watched boolean not null default false,
  quiz_done boolean not null default false,
  quiz_best int not null default 0,
  drill_done boolean not null default false,
  video_sent boolean not null default false,
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (player_id, activity_id)
);

create table public.questions (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references public.players(id) on delete cascade,
  activity_id uuid references public.activities(id) on delete set null,
  body text not null check (char_length(body) between 1 and 500),
  reply text,
  created_at timestamptz not null default now(),
  replied_at timestamptz
);

create table public.raffle_draws (
  id uuid primary key default gen_random_uuid(),
  prize text not null,
  player_id uuid references public.players(id) on delete set null,
  player_name text not null,
  entries_at_draw int not null,
  total_entries int not null,
  drawn_at timestamptz not null default now()
);

alter table public.settings enable row level security;
alter table public.players enable row level security;
alter table public.sessions enable row level security;
alter table public.activities enable row level security;
alter table public.progress enable row level security;
alter table public.questions enable row level security;
alter table public.raffle_draws enable row level security;
revoke all on all tables in schema public from anon, authenticated;

-- ---------- helpers (not granted to anon) ----------
create or replace function public._session_player(p_token uuid) returns uuid
language plpgsql stable security definer set search_path = public as $$
declare v uuid;
begin
  select player_id into v from sessions
   where token = p_token and role = 'player' and expires_at > now();
  if v is null then raise exception 'NOT_LOGGED_IN'; end if;
  return v;
end $$;

create or replace function public._require_coach(p_token uuid) returns void
language plpgsql stable security definer set search_path = public as $$
begin
  if not exists (select 1 from sessions where token = p_token and role = 'coach' and expires_at > now()) then
    raise exception 'NOT_COACH';
  end if;
end $$;

create or replace function public._round_start() returns timestamptz
language sql stable security definer set search_path = public as $$
  select coalesce((select value::timestamptz from settings where key = 'round_start'), '-infinity'::timestamptz)
$$;

create or replace function public._entries(p_player uuid) returns int
language sql stable security definer set search_path = public as $$
  select coalesce((
      select sum(case when a.video_requested then 2 else 1 end)
        from progress pr join activities a on a.id = pr.activity_id
       where pr.player_id = p_player and pr.completed_at is not null and pr.completed_at >= _round_start()
    ), 0)::int
    + coalesce((select bonus_entries from players where id = p_player), 0)
$$;

create or replace function public._refresh_completion(p_player uuid, p_activity uuid) returns void
language plpgsql security definer set search_path = public as $$
declare a activities; pr progress; done boolean;
begin
  select * into a from activities where id = p_activity;
  if not found then return; end if;
  select * into pr from progress where player_id = p_player and activity_id = p_activity;
  if not found then return; end if;
  done := (a.video_url is null or btrim(a.video_url) = '' or pr.watched)
      and pr.drill_done
      and (jsonb_array_length(a.quiz) = 0 or pr.quiz_done)
      and (not a.video_requested or pr.video_sent);
  -- completion is permanent once earned
  update progress
     set completed_at = coalesce(completed_at, case when done then now() end),
         updated_at = now()
   where player_id = p_player and activity_id = p_activity;
end $$;

-- ---------- player API ----------
create or replace function public.player_login(p_name text, p_pin text) returns json
language plpgsql security definer set search_path = public, extensions as $$
declare p players; t uuid;
begin
  select * into p from players where name_key = lower(btrim(p_name));
  if not found then return json_build_object('ok', false, 'error', 'BAD_LOGIN'); end if;
  if p.locked_until is not null and p.locked_until > now() then
    return json_build_object('ok', false, 'error', 'LOCKED');
  end if;
  if p.pin_hash <> crypt(coalesce(p_pin, ''), p.pin_hash) then
    update players set
      failed_attempts = case when failed_attempts + 1 >= 5 then 0 else failed_attempts + 1 end,
      locked_until = case when failed_attempts + 1 >= 5 then now() + interval '10 minutes' else locked_until end
     where id = p.id;
    return json_build_object('ok', false, 'error', 'BAD_LOGIN');
  end if;
  update players set failed_attempts = 0, locked_until = null where id = p.id;
  delete from sessions where expires_at < now();
  insert into sessions(role, player_id) values ('player', p.id) returning token into t;
  return json_build_object('ok', true, 'token', t, 'name', p.name);
end $$;

create or replace function public.logout(p_token uuid) returns void
language sql security definer set search_path = public as $$
  delete from sessions where token = p_token
$$;

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
        select a.id, a.title, a.summary, a.video_url, a.drill_steps, a.video_requested, a.video_note,
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
      select json_agg(json_build_object('id', q.id, 'body', q.body, 'reply', q.reply,
                                        'activity_id', q.activity_id, 'created_at', q.created_at)
                      order by q.created_at desc)
        from questions q where q.player_id = pid), '[]'::json)
  );
end $$;

create or replace function public.player_set_step(p_token uuid, p_activity uuid, p_step text, p_value boolean) returns json
language plpgsql security definer set search_path = public as $$
declare pid uuid;
begin
  pid := _session_player(p_token);
  if p_step not in ('watched', 'drill_done', 'video_sent') then raise exception 'BAD_STEP'; end if;
  if not exists (select 1 from activities where id = p_activity and published) then raise exception 'NO_ACTIVITY'; end if;
  insert into progress(player_id, activity_id) values (pid, p_activity) on conflict do nothing;
  update progress set
    watched    = case when p_step = 'watched'    then p_value else watched end,
    drill_done = case when p_step = 'drill_done' then p_value else drill_done end,
    video_sent = case when p_step = 'video_sent' then p_value else video_sent end
   where player_id = pid and activity_id = p_activity;
  perform _refresh_completion(pid, p_activity);
  return player_home(p_token);
end $$;

create or replace function public.player_submit_quiz(p_token uuid, p_activity uuid, p_answers jsonb) returns json
language plpgsql security definer set search_path = public as $$
declare pid uuid; a activities; total int; score int := 0; results jsonb := '[]'::jsonb; i int;
begin
  pid := _session_player(p_token);
  select * into a from activities where id = p_activity and published;
  if not found then raise exception 'NO_ACTIVITY'; end if;
  total := jsonb_array_length(a.quiz);
  for i in 0 .. total - 1 loop
    if (p_answers->>i) is not null and (p_answers->>i)::int = (a.quiz->i->>'answer')::int then
      score := score + 1; results := results || 'true'::jsonb;
    else
      results := results || 'false'::jsonb;
    end if;
  end loop;
  insert into progress(player_id, activity_id) values (pid, p_activity) on conflict do nothing;
  update progress set quiz_best = greatest(quiz_best, score),
                      quiz_done = quiz_done or (score = total)
   where player_id = pid and activity_id = p_activity;
  perform _refresh_completion(pid, p_activity);
  return json_build_object('score', score, 'total', total, 'results', results, 'home', player_home(p_token));
end $$;

create or replace function public.player_ask(p_token uuid, p_activity uuid, p_body text) returns json
language plpgsql security definer set search_path = public as $$
declare pid uuid;
begin
  pid := _session_player(p_token);
  insert into questions(player_id, activity_id, body) values (pid, p_activity, btrim(p_body));
  return player_home(p_token);
end $$;

-- ---------- coach API ----------
create or replace function public.coach_login(p_pass text) returns json
language plpgsql security definer set search_path = public, extensions as $$
declare h text; t uuid;
begin
  select value into h from settings where key = 'coach_pass_hash';
  if h is null or h <> crypt(coalesce(p_pass, ''), h) then
    perform pg_sleep(1);
    return json_build_object('ok', false, 'error', 'BAD_LOGIN');
  end if;
  insert into sessions(role) values ('coach') returning token into t;
  return json_build_object('ok', true, 'token', t);
end $$;

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
                                  'body', q.body, 'reply', q.reply, 'created_at', q.created_at)
                                  order by (q.reply is not null), q.created_at desc)
                             from questions q join players p on p.id = q.player_id), '[]'::json),
    'draws', coalesce((select json_agg(d order by d.drawn_at desc) from raffle_draws d), '[]'::json),
    'round_start', (select value from settings where key = 'round_start')
  );
end $$;

create or replace function public.coach_add_player(p_token uuid, p_name text, p_pin text) returns json
language plpgsql security definer set search_path = public, extensions as $$
begin
  perform _require_coach(p_token);
  if p_pin !~ '^[0-9]{4}$' then raise exception 'PIN_MUST_BE_4_DIGITS'; end if;
  insert into players(name, pin_hash) values (btrim(p_name), crypt(p_pin, gen_salt('bf')));
  return coach_dashboard(p_token);
end $$;

create or replace function public.coach_reset_pin(p_token uuid, p_player uuid, p_pin text) returns json
language plpgsql security definer set search_path = public, extensions as $$
begin
  perform _require_coach(p_token);
  if p_pin !~ '^[0-9]{4}$' then raise exception 'PIN_MUST_BE_4_DIGITS'; end if;
  update players set pin_hash = crypt(p_pin, gen_salt('bf')), failed_attempts = 0, locked_until = null where id = p_player;
  return coach_dashboard(p_token);
end $$;

create or replace function public.coach_delete_player(p_token uuid, p_player uuid) returns json
language plpgsql security definer set search_path = public as $$
begin
  perform _require_coach(p_token);
  delete from players where id = p_player;
  return coach_dashboard(p_token);
end $$;

create or replace function public.coach_set_bonus(p_token uuid, p_player uuid, p_bonus int) returns json
language plpgsql security definer set search_path = public as $$
begin
  perform _require_coach(p_token);
  update players set bonus_entries = greatest(0, p_bonus) where id = p_player;
  return coach_dashboard(p_token);
end $$;

create or replace function public.coach_save_activity(p_token uuid, p jsonb) returns json
language plpgsql security definer set search_path = public as $$
begin
  perform _require_coach(p_token);
  if coalesce(btrim(p->>'title'), '') = '' then raise exception 'TITLE_REQUIRED'; end if;
  if jsonb_typeof(coalesce(p->'quiz', '[]'::jsonb)) <> 'array' then raise exception 'BAD_QUIZ'; end if;
  if (p->>'id') is null then
    insert into activities(title, summary, video_url, drill_steps, quiz, video_requested, video_note, sort_order, published)
    values (p->>'title', coalesce(p->>'summary', ''), nullif(btrim(coalesce(p->>'video_url', '')), ''),
            coalesce(p->>'drill_steps', ''), coalesce(p->'quiz', '[]'::jsonb),
            coalesce((p->>'video_requested')::boolean, false), coalesce(p->>'video_note', ''),
            coalesce((p->>'sort_order')::int, 0), coalesce((p->>'published')::boolean, true));
  else
    update activities set
      title = p->>'title', summary = coalesce(p->>'summary', ''),
      video_url = nullif(btrim(coalesce(p->>'video_url', '')), ''),
      drill_steps = coalesce(p->>'drill_steps', ''), quiz = coalesce(p->'quiz', '[]'::jsonb),
      video_requested = coalesce((p->>'video_requested')::boolean, false),
      video_note = coalesce(p->>'video_note', ''),
      sort_order = coalesce((p->>'sort_order')::int, 0),
      published = coalesce((p->>'published')::boolean, true)
    where id = (p->>'id')::uuid;
  end if;
  return coach_dashboard(p_token);
end $$;

create or replace function public.coach_delete_activity(p_token uuid, p_activity uuid) returns json
language plpgsql security definer set search_path = public as $$
begin
  perform _require_coach(p_token);
  delete from activities where id = p_activity;
  return coach_dashboard(p_token);
end $$;

create or replace function public.coach_reply(p_token uuid, p_question uuid, p_reply text) returns json
language plpgsql security definer set search_path = public as $$
begin
  perform _require_coach(p_token);
  update questions set reply = nullif(btrim(p_reply), ''), replied_at = now() where id = p_question;
  return coach_dashboard(p_token);
end $$;

create or replace function public.coach_draw(p_token uuid, p_prize text) returns json
language plpgsql security definer set search_path = public as $$
declare total int; pick int; running int := 0; r record;
begin
  perform _require_coach(p_token);
  select coalesce(sum(_entries(id)), 0) into total from players;
  if total = 0 then raise exception 'NO_ENTRIES_YET'; end if;
  pick := floor(random() * total)::int + 1;
  for r in select id, name, _entries(id) as e from players order by name loop
    running := running + r.e;
    if r.e > 0 and running >= pick then
      insert into raffle_draws(prize, player_id, player_name, entries_at_draw, total_entries)
      values (btrim(p_prize), r.id, r.name, r.e, total);
      return json_build_object('winner', r.name, 'entries', r.e, 'total', total, 'dashboard', coach_dashboard(p_token));
    end if;
  end loop;
  raise exception 'DRAW_FAILED';
end $$;

create or replace function public.coach_new_round(p_token uuid) returns json
language plpgsql security definer set search_path = public as $$
begin
  perform _require_coach(p_token);
  insert into settings(key, value) values ('round_start', now()::text)
    on conflict (key) do update set value = excluded.value;
  update players set bonus_entries = 0;
  return coach_dashboard(p_token);
end $$;

create or replace function public.coach_change_pass(p_token uuid, p_new text) returns void
language plpgsql security definer set search_path = public, extensions as $$
begin
  perform _require_coach(p_token);
  if char_length(coalesce(p_new, '')) < 8 then raise exception 'PASSPHRASE_TOO_SHORT'; end if;
  update settings set value = crypt(p_new, gen_salt('bf')) where key = 'coach_pass_hash';
  delete from sessions where role = 'coach' and token <> p_token;
end $$;

-- ---------- permissions: only the public API is callable ----------
revoke execute on all functions in schema public from public, anon, authenticated;
grant execute on function
  public.player_login(text, text),
  public.logout(uuid),
  public.player_home(uuid),
  public.player_set_step(uuid, uuid, text, boolean),
  public.player_submit_quiz(uuid, uuid, jsonb),
  public.player_ask(uuid, uuid, text),
  public.coach_login(text),
  public.coach_dashboard(uuid),
  public.coach_add_player(uuid, text, text),
  public.coach_reset_pin(uuid, uuid, text),
  public.coach_delete_player(uuid, uuid),
  public.coach_set_bonus(uuid, uuid, int),
  public.coach_save_activity(uuid, jsonb),
  public.coach_delete_activity(uuid, uuid),
  public.coach_reply(uuid, uuid, text),
  public.coach_draw(uuid, text),
  public.coach_new_round(uuid),
  public.coach_change_pass(uuid, text)
to anon;
