-- Jacks Home Practice: full step-by-step directions for the 15 Skills & Drills activities,
-- from the coach's "Skills & Drills" handout. Only summary and drill_steps change.
-- Lines starting with "Setup:" or "Look for:" are shown by the app as notes, not numbered steps.
-- APPLIED to project ieivgzhdgjizwabdlixs on 2026-10-16. Reference copy only; do not run again.

begin;

update public.activities set summary = 'Set up the tee in the middle of the plate.',
  drill_steps = 'Place the tee in the middle of the plate with the top of the tee about belt height.
Set a ball on the tee and stand in your normal stance, feet about shoulder-width apart.
Fix your eyes on the back of the ball.
Take a small stride and load your hands back.
Swing level through the ball and drive it into the middle of the net.
Finish the swing and hold the finish for one second.
Reset the ball and repeat.
Look for: Contact out in front of your body, a line drive, and a balanced finish.'
  where title = 'Single Tee';
update public.activities set summary = 'Underload, overload, and regular bat swings.',
  drill_steps = 'Set the tee in the middle of the plate.
Underload: take 5 swings with a lighter bat. Swing as fast as you can.
Rest for 20 to 30 seconds.
Overload: take 5 controlled swings with a heavier bat.
Rest for 20 to 30 seconds.
Regular bat: take 5 swings off the tee with your game bat and try to match the speed of the light bat.
Look for: The same swing path with every bat, and a fast, relaxed finish.'
  where title = 'Bat Speed';
update public.activities set summary = 'Move the tee to each pitch location.',
  drill_steps = 'Start with the tee in the middle of the plate and hit 5 balls.
Inside: move the tee closer to your body and a few inches toward the pitcher. Meet the ball out in front and pull it.
Hit 5 balls.
Outside: move the tee to the far edge of the plate and a few inches toward the catcher. Let the ball travel deeper and drive it the other way.
Hit 5 balls.
Finish with 5 more in the middle.
Look for: A different contact point for each location, with the same balanced swing.'
  where title = 'Inside, Middle, and Outside';
update public.activities set summary = 'Drop-toss timing and tracking.',
  drill_steps = 'Stand in your normal stance. Your partner stands in front of your lead hip, outside your swing path and behind a screen.
Your partner holds a ball at shoulder height over the middle of the plate.
Load your hands as you watch the ball.
Your partner drops the ball straight down with no toss.
Start your swing as the ball falls and track it with your eyes all the way to the bat.
Hit the ball into the net, then repeat 5 to 8 times.
Look for: A steady drop height, eyes on the ball through contact, and a smooth, on-time swing.'
  where title = 'Drop Toss';
update public.activities set summary = 'Short-hop and angle work.',
  drill_steps = 'Setup: Lay a pipe on the ground as a guide for your glove path. Your partner rolls or tosses short hops from 10 to 15 feet away.
Kneel on both knees with your chest up and your back straight.
Hold the flat glove low, palm up, with the glove touching the ground.
Your partner tosses a short hop at you.
Keep your eyes on the ball and let it hop into the glove. Do not stab at it.
Bring the glove and ball up to your chest.
Repeat 5 to 8 times, then change the angle of the toss so the glove follows the pipe line each time.
Look for: A glove that stays low, soft hands, and eyes on the ball into the glove.'
  where title = 'On Knees: Pancake Glove';
update public.activities set summary = 'Straight-on, forehand, and backhand.',
  drill_steps = 'Setup: Lay a pipe on the ground as a guide for your glove path. Your partner rolls or tosses short hops from 10 to 15 feet away.
Kneel on both knees with your normal glove low and open.
Straight-on: field 5 short hops right at your belly button.
Forehand: field 5 hops to your glove side.
Backhand: field 5 hops where you reach the glove across your body to your throwing side.
After each catch, bring the ball to your chest with both hands.
Look for: The glove going to the ball, not the body reaching past it, and a smooth finish to the chest.'
  where title = 'On Knees: Normal Glove';
update public.activities set summary = 'Forehand, backhand, transfer, and footwork.',
  drill_steps = 'Setup: Lay a pipe on the ground as a guide for your glove path. Your partner rolls or tosses short hops from 10 to 15 feet away.
Start in an athletic stance with your knees bent and the flat glove low.
Your partner rolls or tosses a ball to your glove side.
Move your feet to get in front of the ball, then field it with the glove flat.
Bring the ball to your chest and transfer it to your throwing hand.
Reset your feet so you are ready to throw.
Repeat to the glove side, then to the backhand side. Do 5 reps each.
Look for: Quick feet, low hands, and a clean transfer.'
  where title = 'Standing: Pancake Glove';
update public.activities set summary = 'Forehand, backhand, transfer, and throw.',
  drill_steps = 'Setup: Lay a pipe on the ground as a guide for your glove path. Your partner rolls or tosses short hops from 10 to 15 feet away.
Start in an athletic stance with your normal glove low.
Your partner rolls or tosses a ball to your glove side.
Move your feet, field the ball out in front, and bring it to your chest.
Transfer the ball to your throwing hand.
Step toward your target and throw to your partner.
Repeat 5 reps to the glove side, then 5 to the backhand side.
Look for: Feet in front of the ball, a quick transfer, and a throw that finishes toward the target.'
  where title = 'Standing: Normal Glove';
update public.activities set summary = 'The Sequence, step 1: start at set, then move into the sit position.',
  drill_steps = 'Stand in your set position with the pipe across your shoulders and your feet about shoulder-width apart.
Lift your front knee while staying balanced over your back leg.
Sit into your back hip by bending the back knee slightly, with your chest tall.
Hold the sit position for 2 seconds.
Return to set and repeat 5 to 8 times.
Look for: A steady head, a level pipe, and weight loaded on the back leg.'
  where title = 'Sit Drill (PVC Pipe)';
update public.activities set summary = 'The Sequence, step 2: start at the landing position, rotate your hips, and keep your shoulders back.',
  drill_steps = 'Get into the landing position: front foot planted toward the target, back foot behind, and the pipe across your shoulders pointing sideways.
Rotate your hips toward the target.
Keep your shoulders closed so the pipe stays pointing sideways.
Pause for 1 second and feel your hips open ahead of your shoulders.
Reset and repeat 5 to 8 times.
Look for: Hips turning first, with the pipe staying in place.'
  where title = 'Shoulder Hip Separation #1 (PVC)';
update public.activities set summary = 'The Sequence, step 3: start at the landing position, rotate your hips, then rotate your shoulders.',
  drill_steps = 'Start in the landing position with the pipe pointing sideways.
Rotate your hips toward the target.
Once your hips have opened, rotate your shoulders so the pipe turns toward the target.
Stop when your chest faces the target.
Reset and repeat 5 to 8 times.
Look for: Hips first, shoulders second, with a clear gap in timing between them.'
  where title = 'Shoulder Hip Separation #2 (PVC)';
update public.activities set summary = 'The Sequence, step 4: start at the landing position, rotate your hips and shoulders, then follow through.',
  drill_steps = 'Start in the landing position with the pipe pointing sideways.
Rotate your hips toward the target.
Rotate your shoulders after your hips.
Keep going into your follow-through, letting your back leg come around and your chest move over your front leg.
Finish balanced and facing the target.
Reset and repeat 5 to 8 times.
Look for: One smooth, unbroken turn from hips to shoulders to finish.'
  where title = 'Shoulder Hip Separation #3 (PVC)';
update public.activities set summary = 'Motion and progressions: all four sequence steps at game speed.',
  drill_steps = 'Stand in set with the pipe across your shoulders.
Move through the sit position, the landing position, the hip turn, and the shoulder turn.
Keep going into your follow-through without stopping between steps.
Finish balanced, then reset.
Do 5 reps at a smooth pace, then 5 at game speed.
Look for: All four pieces from the sequence showing up, one right after the other.'
  where title = 'Full Motion (PVC Pipe)';
update public.activities set summary = 'Motion and progressions: start at the release position.',
  drill_steps = 'Get into the release position: front leg landed and bent, chest over the front knee, and your throwing arm reaching toward the target.
Your partner holds a ball or a target at the release point, just in front of your throwing hand.
Reach out and tap or take the ball at the release point.
Hold the position for 2 seconds and stay balanced.
Reset and repeat 5 to 8 times.
Look for: A long reach out front, a tall chest over the front leg, and no falling off to the side.'
  where title = 'Extension Drill';
update public.activities set summary = 'Motion and progressions: full motion, snapping through the release point.',
  drill_steps = 'Clear a safe space in front of you and hold a hand towel by one end in your throwing hand.
Start in set and go through the full motion at game speed.
At the release point, snap the towel out in front of you toward your target.
Listen for a sharp snap at the release point.
Finish through your follow-through and reset.
Repeat 5 to 8 times.
Look for: The towel snapping out in front of your body, and a free, fast arm through the finish.'
  where title = 'Towel Drill';

commit;

-- YouTube videos for 10 of the drills (the 4 hitting drills and Extension Drill have none yet).
-- A video adds a required "Watch the video" step. Applied the same day; nobody had progress yet.
begin;
update public.activities a set video_url = v.url
from (values
  ('On Knees: Pancake Glove', 'https://youtu.be/172vNRosyxU'),
  ('On Knees: Normal Glove', 'https://youtu.be/O1jc3rmy-jQ'),
  ('Standing: Pancake Glove', 'https://youtu.be/u-b-TLgz_o4'),
  ('Standing: Normal Glove', 'https://youtu.be/QFt4BDQmqb4'),
  ('Sit Drill (PVC Pipe)', 'https://youtu.be/kZkcUicLWSo'),
  ('Shoulder Hip Separation #1 (PVC)', 'https://youtu.be/A-Y1OrsG1g8'),
  ('Shoulder Hip Separation #2 (PVC)', 'https://youtu.be/c36JNH80uFA'),
  ('Shoulder Hip Separation #3 (PVC)', 'https://youtu.be/ShsgY3DvfvQ'),
  ('Full Motion (PVC Pipe)', 'https://youtu.be/T21y3eOa1B4'),
  ('Towel Drill', 'https://youtu.be/JKmweW1za5s')
) as v(title, url)
where a.title = v.title;
commit;

-- Equipment for each drill (from page 1 of the handout), stored as "Equipment:" lines at the top of
-- drill_steps. The app shows them in an expandable "What you need" list at the top of the activity.
begin;
update public.activities a set drill_steps = v.gear || E'\n' || a.drill_steps
from (values
  ('Single Tee', 'Equipment: Batting tee and home plate
Equipment: Your game bat
Equipment: Baseballs or soft balls, and a net or screen'),
  ('Bat Speed', 'Equipment: Batting tee and home plate
Equipment: Regular bat, plus a lighter and a heavier bat
Equipment: Baseballs or soft balls, and a net or screen'),
  ('Inside, Middle, and Outside', 'Equipment: Batting tee and home plate
Equipment: Your game bat
Equipment: Baseballs or soft balls, and a net or screen'),
  ('Drop Toss', 'Equipment: Home plate
Equipment: Your game bat
Equipment: Baseballs or soft balls, and a net or screen
Equipment: A partner'),
  ('On Knees: Pancake Glove', 'Equipment: A flat training glove (pancake)
Equipment: A pipe or marker line laid on the ground as a path guide
Equipment: A partner, plus a bucket of balls'),
  ('On Knees: Normal Glove', 'Equipment: Your regular game glove
Equipment: A pipe or marker line laid on the ground as a path guide
Equipment: A partner, plus a bucket of balls'),
  ('Standing: Pancake Glove', 'Equipment: A flat training glove (pancake)
Equipment: A pipe or marker line laid on the ground as a path guide
Equipment: A partner, plus a bucket of balls'),
  ('Standing: Normal Glove', 'Equipment: Your regular game glove
Equipment: A pipe or marker line laid on the ground as a path guide
Equipment: A partner, plus a bucket of balls'),
  ('Sit Drill (PVC Pipe)', 'Equipment: A long PVC pipe that rests across both shoulders (or a broom stick)'),
  ('Shoulder Hip Separation #1 (PVC)', 'Equipment: A long PVC pipe that rests across both shoulders (or a broom stick)'),
  ('Shoulder Hip Separation #2 (PVC)', 'Equipment: A long PVC pipe that rests across both shoulders (or a broom stick)'),
  ('Shoulder Hip Separation #3 (PVC)', 'Equipment: A long PVC pipe that rests across both shoulders (or a broom stick)'),
  ('Full Motion (PVC Pipe)', 'Equipment: A long PVC pipe that rests across both shoulders (or a broom stick)'),
  ('Extension Drill', 'Equipment: A ball
Equipment: A partner to hold the ball or a target'),
  ('Towel Drill', 'Equipment: A hand towel
Equipment: A clear, safe space in front of you')
) as v(title, gear)
where a.title = v.title and a.drill_steps not like 'Equipment:%';
commit;
