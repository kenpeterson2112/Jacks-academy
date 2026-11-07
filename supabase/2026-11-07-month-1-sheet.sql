-- Jacks Home Practice: the coaches' "Month 1" Skills & Drills sheet (Nov 7, 2026).
-- Text is copied word for word from the sheet, as Ken asked (its slips included; fix them later
-- in the app's activity editor if wanted). "Part:" lines split a drill into sections (On knees,
-- Standing), each numbered from 1, as on the sheet. The fielding intro on the sheet becomes each
-- fielding drill's "Setup:" tip.
--   Hitting:  Hip Rotation #1 renamed Hip Rotation #2 (its video is already the "Hip rotation #2" one),
--             10 reps; Single Tee gets "(25 swings is recommended)".
--   Fielding: new Fielding Barehand and Fielding With Glove with Ken's new videos. The two
--             "Normal Glove" drills they replace are hidden (published = false), not deleted.
--   Pitching: Shoulder-Hip Separation #1 renamed as on the sheet, 10 reps. Full Motion unchanged.
-- APPLIED to project ieivgzhdgjizwabdlixs on 2026-11-07. Reference copy only; do not run again.

begin;

update public.activities set title = 'Hip Rotation #2',
  drill_steps = replace(drill_steps, 'Reset and repeat 5 to 8 times.', 'Reset and repeat 10 times.')
  where title = 'Hip Rotation #1';

update public.activities set
  drill_steps = replace(drill_steps, 'Reset the ball and repeat.', 'Reset the ball and repeat (25 swings is recommended).')
  where title = 'Single Tee';

update public.activities set title = 'Shoulder–Hip Separation #1 (PVC)',
  drill_steps = replace(drill_steps, 'Reset and repeat 5 to 8 times.', 'Reset and repeat 10 times.')
  where title = 'Shoulder Hip Separation #1 (PVC)';

update public.activities set published = false
  where title in ('On Knees: Normal Glove', 'Standing: Normal Glove');

insert into public.activities (category, sort_order, title, summary, video_url, drill_steps, published)
select 'Fielding', 6, 'Fielding Barehand',
  'On knees, then standing: straight-on, forehand, backhand, transfer, and throw.',
  'https://youtu.be/np54hablK8g',
  $s$Equipment: Baseballs (or whiffle balls, tennis balls, etc.)
Equipment: PVC pipe (5 feet in length is recommended), laid on the ground as a guide
Equipment: A partner
Setup: Lay a pipe on the ground as a guide for your glove path, and have a partner roll or toss short 1 hop ground balls from 10 to 15 feet.
Part: On knees
On knees: kneel on both knees, bend at the waist, with your bare hand low and open.
Straight-on: field 5 ground balls to your glove side. Field in front, attack the ball.
Forehand: field 5 ground balls to your glove side. Field in front, attack the ball.
Backhand: field 5 ground balls to your glove side. Field in front, attack the ball
Part: Standing
On knees: kneel on both knees, bend at waist, with your bare hand low and open.
Straight-on: field 5 ground balls to your glove side. Field in front, attack the ball.
Forehand: field 5 ground balls to your glove side. Field in front, attack the ball.
Backhand: field 5 ground balls to your glove side. Field in front, attack the ball.
Look for: Attacking the ball – going through the ball.$s$,
  true
where not exists (select 1 from public.activities where title = 'Fielding Barehand');

insert into public.activities (category, sort_order, title, summary, video_url, drill_steps, published)
select 'Fielding', 8, 'Fielding With Glove',
  'On knees, then standing: straight-on, forehand, backhand, transfer, and throw.',
  'https://youtu.be/_JLIc_KrIMQ',
  $s$Equipment: Glove
Equipment: Baseballs (or whiffle balls, tennis balls, etc.)
Equipment: PVC pipe (5 feet in length is recommended), laid on the ground as a guide
Equipment: A partner
Setup: Lay a pipe on the ground as a guide for your glove path, and have a partner roll or toss short 1 hop ground balls from 10 to 15 feet.
Part: On knees
On knees: kneel on both knees with your bare hand low and open.
Straight-on: field 5 ground balls to your glove side. Field in front, attack the ball.
Forehand: field 5 ground balls to your glove side. Field in front, attack the ball.
Backhand: field 5 ground balls to your glove side. Field in front, attack the ball
Part: Standing
On knees: kneel on both knees with your bare hand low and open.
Straight-on: field 5 ground balls to your glove side. Field in front, attack the ball.
Forehand: field 5 ground balls to your glove side. Field in front, attack the ball.
Backhand: field 5 ground balls to your glove side. Field in front, attack the ball.
Look for: Attacking the ball – going through the ball.$s$,
  true
where not exists (select 1 from public.activities where title = 'Fielding With Glove');

commit;

-- Check: the published list should be Hip Rotation #2, Single Tee, Fielding Barehand,
-- Fielding With Glove, Shoulder–Hip Separation #1 (PVC), Full Motion (PVC Pipe).
-- select sort_order, category, title from public.activities where published order by sort_order, created_at;
