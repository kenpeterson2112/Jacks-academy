-- Jacks Home Practice: two new Hitting activities, Hip Rotation #1 and #2, from the coach.
-- Each gets its YouTube video and the full step-by-step directions he sent on 2026-10-23.
-- The drills slot in at sort_order 5 and 6 so the Hitting group stays together:
-- Fielding and Pitching move down two spots. Safe to re-run: the renumber and the
-- inserts are both skipped if Hip Rotation #1 is already there.
-- Lines starting with "Equipment:" fill the app's "What you need" list, and the
-- "Look for:" line shows as a tip under the numbered steps.
-- TO APPLY: paste this whole file into the Supabase SQL Editor for project
-- ieivgzhdgjizwabdlixs and run it. (The project may need unpausing first.)

begin;

update public.activities set sort_order = sort_order + 2
 where sort_order >= 5
   and not exists (select 1 from public.activities where title = 'Hip Rotation #1');

insert into public.activities(category, sort_order, title, summary, video_url, drill_steps)
select 'Hitting', 5, 'Hip Rotation #1',
  'Pipe held upright: stride, land, and turn your hips.',
  'https://youtu.be/CIBs4RyGrx8',
  E'Equipment: A PVC pipe (or a broom stick)\nEquipment: A batting tee\nSet up in a wide athletic stance beside the tee. Hold the pipe upright in front of you with both hands, like a bat.\nLoad your weight onto your back leg.\nTake a stride toward the pitcher.\nLand with your front leg bent and your back leg long and braced.\nTurn your hips first, then bring your hands and the pipe through.\nFinish with your chest facing the pitcher and the pipe wrapped across your back shoulder.\nReset to your stance and repeat 10 times.\nLook for: Hips turning before the hands, a firm front leg, and a balanced finish.'
 where not exists (select 1 from public.activities where title = 'Hip Rotation #1');

insert into public.activities(category, sort_order, title, summary, video_url, drill_steps)
select 'Hitting', 6, 'Hip Rotation #2',
  'Pipe at chest height: rotate your hips and sweep through the hitting zone.',
  'https://youtu.be/nRCKcFZhPfY',
  E'Equipment: A PVC pipe (or a broom stick)\nEquipment: A batting tee\nStart in your stance beside the tee, holding the pipe out level with your hands together.\nStride and land with your front leg firm and your back leg driving.\nRotate your hips toward the pitcher.\nLet your hands follow and sweep the pipe level through the tee-height zone.\nFinish high, with the pipe over your front shoulder and your weight on your front leg.\nHold the finish for one second.\nReset and repeat 10 times.\nLook for: Hips leading the swing, a level pipe through the zone, and a high, balanced finish.'
 where not exists (select 1 from public.activities where title = 'Hip Rotation #2');

commit;

-- Should show Hitting 6, Fielding 4, Pitching 7, with Hip Rotation #1 and #2 at sort_order 5 and 6
select category, sort_order, title, video_url from public.activities order by sort_order;
