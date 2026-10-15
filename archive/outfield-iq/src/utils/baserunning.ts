import type { BaseOccupied, Scenario } from "../types/game";

const BASES: BaseOccupied[] = ["1B", "2B", "3B"];

export function computeRunnersAfterHit(scenario: Scenario): Partial<Record<BaseOccupied, boolean>> {
  const { runners, hitType } = scenario;
  const advances = hitType === "gapper" ? 2 : 1;
  const result: Partial<Record<BaseOccupied, boolean>> = {};

  // Process 3B→1B so a runner advancing into an occupied base doesn't collide
  for (let i = 2; i >= 0; i--) {
    if (runners[BASES[i]]) {
      const dest = i + advances;
      if (dest < 3) result[BASES[dest]] = true;
      // dest >= 3 means runner scores — omit from result
    }
  }

  // Add batter-runner (fly-ball batter is out, no new runner)
  if (hitType === "single" || hitType === "line-drive" || hitType === "ground-ball") {
    result["1B"] = true;
  } else if (hitType === "gapper") {
    result["2B"] = true;
  }

  return result;
}
