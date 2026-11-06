-- Jacks Home Practice: "Reset data" options on the coach Settings tab.
-- One coach-only function, coach_reset(token, what), where what is one of:
--   'questions' : delete every player question and equipment request
--   'draws'     : delete the list of past raffle draws (winners and prizes)
--   'tickets'   : start a new raffle round (everyone back to 0 tickets, bonus tickets cleared);
--                 finished activities stay finished
--   'progress'  : delete every player's checkmarks and finished activities
--                 (this also removes the tickets those activities earned)
-- Players, PINs, activities and settings are never touched.
-- Deleted rows cannot be restored: the free Supabase plan keeps no backups we can restore from.
-- APPLIED to project ieivgzhdgjizwabdlixs on 2026-11-06. Reference copy only.

create or replace function public.coach_reset(p_token uuid, p_what text) returns json
language plpgsql security definer set search_path = public as $$
begin
  perform _require_coach(p_token);
  if p_what = 'questions' then
    delete from questions where true;
  elsif p_what = 'draws' then
    delete from raffle_draws where true;
  elsif p_what = 'tickets' then
    insert into settings(key, value) values ('round_start', now()::text)
      on conflict (key) do update set value = excluded.value;
    update players set bonus_entries = 0 where true;
  elsif p_what = 'progress' then
    delete from progress where true;
  else
    raise exception 'BAD_RESET';
  end if;
  return coach_dashboard(p_token);
end $$;

-- Same grants as the other coach_* functions: anon (the app) and service_role only.
revoke all on function public.coach_reset(uuid, text) from public, authenticated;
grant execute on function public.coach_reset(uuid, text) to anon, service_role;
