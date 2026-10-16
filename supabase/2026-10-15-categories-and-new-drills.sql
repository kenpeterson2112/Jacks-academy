-- Jacks Home Practice: activity categories, image/GIF field, and the new Skills & Drills list.
-- APPLIED to project ieivgzhdgjizwabdlixs on 2026-10-15. Reference copy only; do not run again.
-- The 3 'Retired' activities this hides were later deleted by hand, so only the 15 new drills remain.

begin;

alter table public.activities
  add column if not exists category text not null default '',
  add column if not exists image_url text;

-- Watch step is required when the activity has a video OR an image/GIF
create or replace function public._refresh_completion(p_player uuid, p_activity uuid) returns void
language plpgsql security definer set search_path = public as $$
declare a activities; pr progress; done boolean;
begin
  select * into a from activities where id = p_activity;
  if not found then return; end if;
  select * into pr from progress where player_id = p_player and activity_id = p_activity;
  if not found then return; end if;
  done := ((coalesce(btrim(a.video_url), '') = '' and coalesce(btrim(a.image_url), '') = '') or pr.watched)
      and pr.drill_done
      and (jsonb_array_length(a.quiz) = 0 or pr.quiz_done)
      and (not a.video_requested or pr.video_sent);
  update progress
     set completed_at = coalesce(completed_at, case when done then now() end),
         updated_at = now()
   where player_id = p_player and activity_id = p_activity;
end $$;

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
      select json_agg(json_build_object('id', q.id, 'body', q.body, 'reply', q.reply,
                                        'activity_id', q.activity_id, 'created_at', q.created_at)
                      order by q.created_at desc)
        from questions q where q.player_id = pid), '[]'::json)
  );
end $$;

create or replace function public.coach_save_activity(p_token uuid, p jsonb) returns json
language plpgsql security definer set search_path = public as $$
begin
  perform _require_coach(p_token);
  if coalesce(btrim(p->>'title'), '') = '' then raise exception 'TITLE_REQUIRED'; end if;
  if jsonb_typeof(coalesce(p->'quiz', '[]'::jsonb)) <> 'array' then raise exception 'BAD_QUIZ'; end if;
  if (p->>'id') is null then
    insert into activities(title, summary, category, video_url, image_url, drill_steps, quiz, video_requested, video_note, sort_order, published)
    values (p->>'title', coalesce(p->>'summary', ''), btrim(coalesce(p->>'category', '')),
            nullif(btrim(coalesce(p->>'video_url', '')), ''), nullif(btrim(coalesce(p->>'image_url', '')), ''),
            coalesce(p->>'drill_steps', ''), coalesce(p->'quiz', '[]'::jsonb),
            coalesce((p->>'video_requested')::boolean, false), coalesce(p->>'video_note', ''),
            coalesce((p->>'sort_order')::int, 0), coalesce((p->>'published')::boolean, true));
  else
    update activities set
      title = p->>'title', summary = coalesce(p->>'summary', ''),
      category = btrim(coalesce(p->>'category', '')),
      video_url = nullif(btrim(coalesce(p->>'video_url', '')), ''),
      image_url = nullif(btrim(coalesce(p->>'image_url', '')), ''),
      drill_steps = coalesce(p->>'drill_steps', ''), quiz = coalesce(p->'quiz', '[]'::jsonb),
      video_requested = coalesce((p->>'video_requested')::boolean, false),
      video_note = coalesce(p->>'video_note', ''),
      sort_order = coalesce((p->>'sort_order')::int, 0),
      published = coalesce((p->>'published')::boolean, true)
    where id = (p->>'id')::uuid;
  end if;
  return coach_dashboard(p_token);
end $$;

-- Hide the old activities instead of deleting them, so progress and raffle entries already earned are kept.
-- (They stay in the coach's Activities list, marked hidden, under the category 'Retired'.)
update public.activities set published = false, category = 'Retired', sort_order = 100 + sort_order where category = '';

insert into public.activities(category, sort_order, title, summary, drill_steps) values
('Hitting', 1, 'Single Tee', 'Set up the tee in the middle of the plate.',
 E'Set the tee at belt height in the middle of the plate.\nGet in your stance so your bat covers the whole plate.\nSwing level and hit a line drive right back up the middle.\nReset your stance before every swing.\nDo 3 sets of 10.'),
('Hitting', 2, 'Bat Speed', 'Underload, overload, and regular bat swings.',
 E'Take 5 fast swings with a lighter bat (underload).\nTake 5 swings with a heavier bat (overload).\nTake 5 swings with your game bat.\nSwing as fast as you can while staying balanced.\nDo 3 rounds.'),
('Hitting', 3, 'Inside, Middle, and Outside', 'Move the tee to each pitch location.',
 E'Start with the tee in the middle of the plate and hit it up the middle.\nMove the tee to the inside corner and a little farther out in front. Hit it to your pull side.\nMove the tee to the outside corner and a little deeper. Hit it the other way.\nDo 10 swings at each spot.'),
('Hitting', 4, 'Drop Toss', 'Drop-toss timing and tracking.',
 E'Your partner stands off to the side, safely out of your swing, and holds the ball out at shoulder height over the plate.\nGet in your stance and wait.\nYour partner drops the ball with no warning.\nHit it before it bounces, and watch it all the way to the bat.\nDo 3 sets of 10.'),
('Fielding', 5, 'On Knees: Pancake Glove', 'Short-hop and angle work.',
 E'Kneel with your knees wide and your pancake glove out in front.\nYour partner throws short hops right at you.\nField the ball out in front and bring your top hand over it.\nThen take short hops to your left and right.\nDo 3 sets of 10.'),
('Fielding', 6, 'On Knees: Normal Glove', 'Straight-on, forehand, and backhand.',
 E'Kneel with your knees wide and your glove out in front.\nField 10 balls straight on.\nField 10 to your glove side (forehand).\nField 10 to your throwing-hand side (backhand).\nCover the ball with your top hand every time.'),
('Fielding', 7, 'Standing: Pancake Glove', 'Forehand, backhand, transfer, and footwork.',
 E'Get in your ready stance with your pancake glove.\nField grounders straight on, then forehand, then backhand.\nAfter each catch, move your feet and transfer the ball to your throwing hand.\nDo 10 of each.'),
('Fielding', 8, 'Standing: Normal Glove', 'Forehand, backhand, transfer, and throw.',
 E'Get in your ready stance with your normal glove.\nField grounders straight on, then forehand, then backhand.\nTransfer the ball to your throwing hand, step to your target, and throw.\nDo 10 of each.'),
('Pitching', 9, 'Sit Drill (PVC Pipe)', 'The Sequence, step 1: start at set, move into the ''sit'' position.',
 E'Start in your set position holding the PVC pipe.\nMove into your ''sit'' position.\nHold it for 3 seconds and check your balance.\nReset and do 10 reps.'),
('Pitching', 10, 'Shoulder Hip Separation #1 (PVC)', 'The Sequence, step 2: start at landing, rotate hips, keep shoulders back.',
 E'Hold the PVC pipe and start in your landing position.\nRotate your hips toward the target.\nKeep your shoulders back.\nHold for 2 seconds, reset, and do 10 reps.'),
('Pitching', 11, 'Shoulder Hip Separation #2 (PVC)', 'The Sequence, step 3: start at landing, rotate hips, then rotate shoulders.',
 E'Hold the PVC pipe and start in your landing position.\nRotate your hips first.\nThen rotate your shoulders.\nReset and do 10 reps.'),
('Pitching', 12, 'Shoulder Hip Separation #3 (PVC)', 'The Sequence, step 4: start at landing, rotate hips, shoulders, and follow through.',
 E'Hold the PVC pipe and start in your landing position.\nRotate your hips, then your shoulders.\nFinish with a full follow-through.\nReset and do 10 reps.'),
('Pitching', 13, 'Full Motion (PVC Pipe)', 'Motion and progressions: all 4 sequence steps at game speed.',
 E'Hold the PVC pipe and start from your set position.\nGo through all 4 sequence steps in one smooth motion: sit, hips, shoulders, follow-through.\nStart slow, then build up to game speed.\nDo 10 reps.'),
('Pitching', 14, 'Extension Drill', 'Motion and progressions: start at the release position.',
 E'Start in your release position with the ball.\nReach out toward your target and throw to your partner.\nFinish with your arm out in front, extended toward the target.\nDo 10 throws.'),
('Pitching', 15, 'Towel Drill', 'Motion and progressions: full motion, snap through the release point.',
 E'Hold a small towel by one corner like a ball.\nGo through your full pitching motion.\nSnap the towel through your release point, out in front.\nDo 15 reps.');

commit;

-- Should show Hitting 4, Fielding 4, Pitching 7 (plus 3 hidden Retired)
select category, count(*) from public.activities group by category order by min(sort_order);
