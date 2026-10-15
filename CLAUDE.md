# Jacks Home Practice

At-home practice app for the Northumberland Jacks 11U baseball team. Kids log in, work through drill activities, and earn raffle entries. Coaches manage players, activities, questions and the raffle.

Started as a UBC MET ETEC 523 "DIY mobile project" exercise. It is a working prototype with real players in it, so treat the database as production.

## About the owner

- Ken is not a terminal user. Explain changes in plain language, and prefer GitHub web upload / web editor steps over git CLI instructions when he needs to do something himself.
- No em dashes in any text written for Ken or shown in the app.
- Hosting: GitHub Pages at https://kenpeterson2112.github.io/Jacks-academy/. A push to the default branch runs `.github/workflows/deploy-pages.yml`, which publishes the top-level `*.html` files and the archived Outfield IQ build. Do not move it to Netlify.

## Files

- `index.html`: the whole app. One file: React 18 + Babel standalone from CDN (versions pinned), supabase-js v2. No build step. Keep it single-file unless Ken asks otherwise.
- `ground-ball-drill.html`: standalone animated drill page (SVG + vanilla JS). Linked from activities, not embedded in the app.
- `supabase/schema.sql`: the full database setup (tables + RPC functions + grants). Reference copy; it has already been applied.
- `archive/outfield-iq/`: the first version of this repo (Outfield IQ, React + Vite). Kept as is and still deployed at `/Jacks-academy/outfield-iq/`. Copy pieces out of it rather than editing it.

## Backend (Supabase)

- Project: "Jacks Home Practice", ref `ieivgzhdgjizwabdlixs`, region ca-central-1. Separate from the Jacks Dugout lineup app's projects.
- The publishable key in `index.html` is meant to be public. Never put a service-role key in the client.
- **Security model:** no Supabase Auth. All tables have RLS on with no policies, and `anon` has no table access at all. Everything goes through `SECURITY DEFINER` RPC functions that take a session token (`p_token uuid`). `player_login` / `coach_login` create rows in `sessions`. Player tokens can only touch that player's data; `coach_*` functions call `_require_coach` first. The Supabase advisor warnings about anon-executable SECURITY DEFINER functions are expected for this design.
- Any new function must check the token the same way, and must be added to the explicit `grant execute ... to anon` list. Helpers (prefixed `_`) stay ungranted.
- Player login: name (case-insensitive) + 4-digit PIN, bcrypt via pgcrypto. 5 wrong tries locks the player for 10 minutes.
- Coach login: one shared passphrase, bcrypt hash in `settings.coach_pass_hash`. Changed from the app's Settings tab. Never write the passphrase into code or docs.

## Product rules

- Activity checklist: Watch video (only if `video_url`), Pass the quiz (only if quiz has questions, must get all right), Do the drill (always), Send your video (only if `video_requested`).
- Kids send videos to the coach on WhatsApp. The app only stores a checkbox ("I sent my video"). Do not add video uploads without asking: it involves storing video of minors.
- Completion is computed server-side in `_refresh_completion` and is permanent once earned (unchecking a box later does not remove it).
- Raffle: 1 entry per completed activity, 2 if it requested a video, plus coach-given bonus entries. Only completions since the current round started count. `coach_new_round` resets the round and bonuses. Draws are weighted by entries.
- Prizes: no preset list. The coach types the prize into the box on the Raffle tab for each draw.
- Quiz answers are graded in the database; the client never receives the correct answers.

## Design

Palette matches the drill animation: warm paper `#f7f0e5`, ink `#2f2620`, rust `#c4592a`, field green `#4f7f5b`, infield peach `#e2b496`. Headings in Graduate (Google Fonts), body in Nunito. Mobile-first: most players use a parent's phone.

## Known limits / ideas

- Activity videos must be YouTube links. Supporting a GIF or a link to a page like `ground-ball-drill.html` in the Watch step was discussed but not built.
- No per-coach accounts; all coaches share one passphrase.
- Free tier Supabase pauses after a week of no activity.
