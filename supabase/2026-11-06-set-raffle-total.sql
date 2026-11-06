-- Jacks Home Practice: let the coach set a player's raffle ticket total directly (Players tab, Manage).
-- A player's total is still tickets earned from finished activities this round plus a coach adjustment
-- (players.bonus_entries). coach_set_entries works out the adjustment needed to hit the total the coach
-- typed, so it can now be negative (taking tickets away). _entries never goes below 0, so draws stay sound.
-- A new raffle round still clears the adjustment, as before.
-- APPLIED to project ieivgzhdgjizwabdlixs on 2026-11-06. Reference copy only.

create or replace function public._earned_entries(p_player uuid) returns int
language sql stable security definer set search_path = public as $$
  select coalesce((
      select sum(case when a.video_requested then 2 else 1 end)
        from progress pr join activities a on a.id = pr.activity_id
       where pr.player_id = p_player and pr.completed_at is not null and pr.completed_at >= _round_start()
    ), 0)::int
$$;

create or replace function public._entries(p_player uuid) returns int
language sql stable security definer set search_path = public as $$
  select greatest(0, _earned_entries(p_player) + coalesce((select bonus_entries from players where id = p_player), 0))
$$;

create or replace function public.coach_set_entries(p_token uuid, p_player uuid, p_total int) returns json
language plpgsql security definer set search_path = public as $$
begin
  perform _require_coach(p_token);
  if p_total is null or p_total < 0 or p_total > 999 then raise exception 'BAD_TOTAL'; end if;
  update players set bonus_entries = p_total - _earned_entries(p_player) where id = p_player;
  return coach_dashboard(p_token);
end $$;

-- Helpers stay ungranted; the new coach function gets the same grants as the other coach_* functions.
revoke all on function public._earned_entries(uuid) from public, anon, authenticated;
revoke all on function public.coach_set_entries(uuid, uuid, int) from public, authenticated;
grant execute on function public.coach_set_entries(uuid, uuid, int) to anon, service_role;
