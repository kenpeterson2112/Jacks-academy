-- Jacks Home Practice: November drill update from the coaches' revised "Skills & Drills" sheet.
-- Ken is hiding every drill not on the sheet. These 5 were brought in line with it: new summaries,
-- 'Look for' lines and equipment (5 ft PVC pipe, sock net, whiffle/tennis balls). Videos unchanged;
-- all 5 already had the right one (or none, for Single Tee).
-- Later the same day: the sheet's 'Hip Rotation #1' was added (its steps are the October 'Hip Rotation #2'
-- drill word for word, so it uses that video, nRCKcFZhPfY), and Single Tee got its video ('Hitting Drill - Tee').
-- The October file 2026-10-23-hip-rotation-drills.sql was never applied and is now superseded.
-- APPLIED to project ieivgzhdgjizwabdlixs on 2026-11-06. Reference copy only; do not run again.

begin;
update public.activities set summary = 'Set up the tee in the middle of the plate.',
  drill_steps = 'Equipment: Batting tee
Equipment: Bat
Equipment: Baseballs (or whiffle balls, tennis balls, etc.)
Equipment: Batting net (sock net)
Place the tee in the middle of the plate with the top of the tee about belt height.
Set a ball on the tee and stand in your normal stance, feet about shoulder-width apart.
Fix your eyes on the back of the ball.
Take a small stride and load your hands back.
Swing level through the ball and drive it into the middle of the net.
Finish the swing and hold the finish for one second.
Reset the ball and repeat.
Look for: Contact out in front of your body, a line drive, and a balanced finish.'
  where title = 'Single Tee';
update public.activities set summary = 'Straight-on, forehand, backhand.',
  drill_steps = 'Equipment: Glove
Equipment: Baseballs (or whiffle balls, tennis balls, etc.)
Equipment: PVC pipe (5 feet in length is recommended), laid on the ground as a guide
Equipment: A partner
Setup: Lay a pipe on the ground as a guide for your glove path. Your partner rolls or tosses short hops from 10 to 15 feet away.
Kneel on both knees with your normal glove low and open.
Straight-on: field 5 short hops right at your belly button.
Forehand: field 5 hops to your glove side.
Backhand: field 5 hops where you reach the glove across your body to your throwing side.
After each catch, bring the ball to your chest with both hands.
Look for: The glove attacking the ball.'
  where title = 'On Knees: Normal Glove';
update public.activities set summary = 'Forehand, backhand, transfer, and throw.',
  drill_steps = 'Equipment: Glove
Equipment: Baseballs (or whiffle balls, tennis balls, etc.)
Equipment: PVC pipe (5 feet in length is recommended), laid on the ground as a guide
Equipment: A partner
Setup: Lay a pipe on the ground as a guide for your glove path. Your partner rolls or tosses short hops from 10 to 15 feet away.
Start in an athletic stance with your normal glove low.
Your partner rolls or tosses a ball to your glove side.
Move your feet, field the ball out in front, and bring it to your chest.
Transfer the ball to your throwing hand.
Step toward your target and throw to your partner.
Repeat 5 reps to the forehand, 5 straight-on, then 5 to the backhand side.
Look for: The glove attacking the ball.'
  where title = 'Standing: Normal Glove';
update public.activities set summary = 'The Sequence: start at the landing position, rotate your hips, and keep your shoulders back.',
  drill_steps = 'Equipment: PVC pipe (5 feet in length is recommended)
Get into the landing position: front foot planted toward the target, back foot behind, and the pipe across your shoulders pointing sideways.
Rotate your hips toward the target.
Keep your shoulders closed so the pipe stays pointing sideways.
Pause for 1 second and feel your hips open ahead of your shoulders.
Reset and repeat 5 to 8 times.
Look for: Hips turning first, with the pipe staying in place.'
  where title = 'Shoulder Hip Separation #1 (PVC)';
update public.activities set summary = 'Full pitch sequence at game speed.',
  drill_steps = 'Equipment: PVC pipe (5 feet in length is recommended)
Stand in set with the pipe across your shoulders.
Move through the sit position, the landing position, the hip turn, and the shoulder turn.
Keep going into your follow-through without stopping between steps.
Finish balanced, then reset.
Do 5 reps at a smooth pace, then 5 at game speed.
Look for: All four pieces from the sequence showing up, one right after the other.'
  where title = 'Full Motion (PVC Pipe)';
commit;

-- Hip Rotation #1 and the Single Tee video (applied 2026-11-06)
begin;
update public.activities set video_url = 'https://youtu.be/hWvyun24ZgI' where title = 'Single Tee';
insert into public.activities(category, sort_order, title, summary, drill_steps, video_url)
select 'Hitting', 0, 'Hip Rotation #1', 'Pipe swing: rotate your hips and sweep through the hitting zone.', 'Equipment: Batting tee
Equipment: PVC pipe (5 feet in length is recommended)
Start in your stance beside the tee, holding the pipe out level with your hands together.
Stride and land with your front leg firm and your back leg driving.
Rotate your hips toward the pitcher.
Let your hands follow and sweep the pipe level through the tee-height zone.
Finish high, with the pipe over your front shoulder and your weight on your front leg.
Hold the finish for one second.
Reset and repeat 5 to 8 times.
Look for: Hips leading the swing, a level pipe through the zone, and a high, balanced finish.', 'https://youtu.be/nRCKcFZhPfY'
where not exists (select 1 from public.activities where title ilike 'Hip Rotation%');
commit;
