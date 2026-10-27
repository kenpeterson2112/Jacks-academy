# Jacks Home Practice

At-home practice app for the Northumberland Jacks 11U baseball team. Kids log in, work through drill activities, and earn raffle entries. Coaches manage players, activities, questions and the raffle.

Started as a UBC MET ETEC 523 "DIY mobile project" exercise. It is a working prototype with real players in it, so treat the database as production.

## About the owner

- Ken is not a terminal user. Explain changes in plain language, and prefer GitHub web upload / web editor steps over git CLI instructions when he needs to do something himself.
- No em dashes in any text written for Ken or shown in the app.
- Hosting: GitHub Pages at https://kenpeterson2112.github.io/Jacks-academy/. A push to `main` (the default branch) runs `.github/workflows/deploy-pages.yml`, which publishes the top-level `*.html` files, the `media/` folder (images and GIFs for activities) and the archived Outfield IQ build. Do not move it to Netlify.

## Files

- `index.html`: the whole app. One file: React 18 + Babel standalone from CDN (versions pinned), supabase-js v2. No build step. Keep it single-file unless Ken asks otherwise.
- `ground-ball-drill.html`: standalone animated drill page (SVG + vanilla JS). Linked from activities, not embedded in the app.
- `supabase/schema.sql`: the original database setup (tables + RPC functions + grants). Reference copy; already applied.
- `supabase/2026-10-15-categories-and-new-drills.sql`: adds `activities.category` and `activities.image_url`, updates `_refresh_completion`, `player_home` and `coach_save_activity`, hides the 3 original activities (category 'Retired', unpublished), and loads the 15 Skills & Drills activities. Already applied; reference only. Ken later deleted the 3 retired activities himself, so only the 15 drills remain.
- `supabase/2026-10-16-drill-directions.sql`: full step-by-step directions for the 15 drills from the coach's "Skills & Drills" handout (summary and drill_steps), plus YouTube links for 10 of them and each drill's equipment. Already applied; reference only.
- `supabase/2026-10-23-hip-rotation-drills.sql`: adds two Hitting activities (Hip Rotation #1 and #2) with their YouTube videos and the coach's full directions, renumbering Fielding and Pitching sort order so Hitting stays grouped (17 activities total). Prepared Oct 23, 2026; Ken applies it in the Supabase SQL Editor.
- `media/`: images and GIFs used by activities. Reference them from an activity as `media/<file>`.
- `archive/outfield-iq/`: the first version of this repo (Outfield IQ, React + Vite). Kept as is and still deployed at `/Jacks-academy/outfield-iq/`. Copy pieces out of it rather than editing it.

## Backend (Supabase)

- Project: "Jacks Home Practice", ref `ieivgzhdgjizwabdlixs`, region ca-central-1. Separate from the Jacks Dugout lineup app's projects.
- The publishable key in `index.html` is meant to be public. Never put a service-role key in the client.
- **Security model:** no Supabase Auth. All tables have RLS on with no policies, and `anon` has no table access at all. Everything goes through `SECURITY DEFINER` RPC functions that take a session token (`p_token uuid`). `player_login` / `coach_login` create rows in `sessions`. Player tokens can only touch that player's data; `coach_*` functions call `_require_coach` first. The Supabase advisor warnings about anon-executable SECURITY DEFINER functions are expected for this design.
- Any new function must check the token the same way, and must be added to the explicit `grant execute ... to anon` list. Helpers (prefixed `_`) stay ungranted.
- Player login: name (case-insensitive) + 4-digit PIN, bcrypt via pgcrypto. 5 wrong tries locks the player for 10 minutes.
- Coach login: one shared passphrase, bcrypt hash in `settings.coach_pass_hash`. Changed from the app's Settings tab. Never write the passphrase into code or docs.

## Product rules

- Every activity has a `category` (Hitting, Fielding, Pitching so far), shown as a coloured chip. No grouping or collapsing yet, by choice.
- Activity checklist: Watch (only if `video_url` or `image_url`; an image/GIF shows above the video), Pass the quiz (only if quiz has questions, must get all right), Do the drill (always), Send your video (only if `video_requested`).
- Drill steps are one per line. Lines starting with `Equipment:` (one item each) fill an expandable "What you need" list at the top of the activity. Lines starting with `Setup:` or `Look for:` show as tips (Setup above the numbered steps, Look for below). Every other line is a numbered step.
- Player navigation is kept simple for ages 9 to 11: the top bar always shows their raffle tickets (a small yellow pill, top right); inside an activity it also shows a big Back button (Log out only on the home screen), the bottom has Next (their next unfinished activity) and All activities, and the phone's back button returns to the list (browser history).
- Finished activities (player home) and answered questions (coach Questions tab) move into a collapsed section at the bottom. Collapsed by default; the open state is not remembered. The equipment list opens as a floating box that closes on a tap elsewhere.
- Kids send videos to the coach on WhatsApp. The app only stores a checkbox ("I sent my video"). Do not add video uploads without asking: it involves storing video of minors.
- Completion is computed server-side in `_refresh_completion` and is permanent once earned (unchecking a box later does not remove it).
- Raffle: 1 entry per completed activity, 2 if it requested a video, plus coach-given bonus entries. Only completions since the current round started count. `coach_new_round` resets the round and bonuses. Draws are weighted by entries.
- Prizes: no preset list. The coach types the prize into the box on the Raffle tab for each draw.
- Quiz answers are graded in the database; the client never receives the correct answers.

## Design

Branding follows the Northumberland Jacks x Be On Time Athletics winter development poster: near-black `#0f1a13` (header, dark buttons), Jacks green `#16703d` (main buttons, header stripe), BOT yellow `#f2cf1d` (raffle ticket count, in-progress rings, draw winner), on a maple-bat tan page `#ecdfc3` with cream cards `#fbf8f0` (no bright white backgrounds anywhere; use `var(--card)`). Soft tan `#ebe3cf` for tips, lines `#dccdab`. Red `#c0392b` is only for wrong answers, alerts and remove buttons. Colours are CSS variables in `:root` at the top of `index.html`. Headings in Graduate (Google Fonts), body in Nunito. Mobile-first: most players use a parent's phone.

## Known limits / ideas

- Videos must be YouTube links. Images/GIFs can be any image URL, or `media/<file>` for a file committed to this repo.
- The drills have no quiz questions yet.
- Database changes that delete rows have been blocked from Claude's Supabase connection; prefer hiding (`published = false`) over deleting, or give Ken SQL to run in the Supabase SQL Editor.
- No per-coach accounts; all coaches share one passphrase.
- Free tier Supabase pauses after a week of no activity. `.github/workflows/keep-supabase-awake.yml` pings the database every 3 days to prevent this (a red run means it did not answer, likely paused). Ken's free plan allows only 2 active projects, so restoring one can mean pausing another. GitHub turns off scheduled workflows after 60 days with no commits to the repo; re-enable it from the Actions tab if that happens.
