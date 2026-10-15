import type { Scenario } from "../types/game";

/**
 * Hand-authored scenario bank. Each scenario's correctDecision and explanation
 * are pre-determined by a human, not computed from a physics/probability model.
 *
 * fielderPosition below is a flavor default only — useGameSession randomizes
 * the actual fielderPosition shown to the kid for each play.
 */
export const SCENARIO_BANK: Scenario[] = [
  {
    id: "s1",
    fielderPosition: "LF",
    outs: 0,
    runners: { "1B": true },
    hitType: "single",
    correctDecision: "2B",
    // PLACEHOLDER — verify rules accuracy before shipping real content
    explanation:
      "With a runner only on first, there's no run in immediate danger. Get the ball back to second base quickly so the batter-runner can't stretch the single into a double.",
    videoUrlCorrect: undefined,
    videoUrlIncorrect: undefined,
  },
  {
    id: "s2",
    fielderPosition: "RF",
    outs: 2,
    runners: { "2B": true, "3B": true },
    hitType: "fly-ball",
    correctDecision: "Home",
    // PLACEHOLDER — verify rules accuracy before shipping real content
    explanation:
      "Two outs means every runner is going as soon as the ball is on the ground — extra bases elsewhere don't matter. Throw home and try to cut down the run before the inning's third out.",
    videoUrlCorrect: undefined,
    videoUrlIncorrect: undefined,
  },
  {
    id: "s3",
    fielderPosition: "CF",
    outs: 1,
    runners: { "1B": true, "2B": true },
    hitType: "gapper",
    correctDecision: "Cutoff",
    // PLACEHOLDER — verify rules accuracy before shipping real content
    explanation:
      "The ball is deep in the gap and you had to run it down — there's no way to make an accurate throw all the way to a base from out there. Hit the cutoff man so the infield can react to whatever the runners try.",
    videoUrlCorrect: undefined,
    videoUrlIncorrect: undefined,
  },
  {
    id: "s4",
    fielderPosition: "LF",
    outs: 1,
    runners: { "3B": true },
    hitType: "line-drive",
    correctDecision: "Home",
    // PLACEHOLDER — verify rules accuracy before shipping real content
    explanation:
      "A sharp line drive single means you should be charging hard. With the go-ahead run on third, your only job is to throw home and try to keep that run from scoring.",
    videoUrlCorrect: undefined,
    videoUrlIncorrect: undefined,
  },
];
