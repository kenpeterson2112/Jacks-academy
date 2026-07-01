import { useEffect, useRef, useState } from "react";
import type { BaseOccupied, DecisionOutcome, DecisionRecord, Scenario, ThrowTarget } from "../../types/game";
import { FieldView } from "../FieldView/FieldView";
import { DecisionTimer, DEFAULT_TIME_LIMIT_MS } from "../DecisionTimer/DecisionTimer";
import { DecisionFeedback } from "../DecisionFeedback/DecisionFeedback";
import { resolveOutcome } from "../../utils/scoring";
import { computeRunnersAfterHit } from "../../utils/baserunning";
import { FIELDER_COORDS, TARGET_COORDS } from "../FieldView/positions";
import styles from "./PlayingPhase.module.css";

interface PlayingPhaseProps {
  scenario: Scenario;
  scenarioNumber: number;
  totalScenarios: number;
  onSubmitDecision: (record: DecisionRecord) => void;
  onNext: () => void;
}

const HIT_TYPE_LABELS: Record<Scenario["hitType"], string> = {
  single: "Single",
  gapper: "Gapper into the gap",
  "line-drive": "Sharp line drive",
  "fly-ball": "Fly ball",
  "ground-ball": "Ground ball",
};

const BASE_LABELS: Record<"1B" | "2B" | "3B", string> = {
  "1B": "1st",
  "2B": "2nd",
  "3B": "3rd",
};

function describeRunners(scenario: Scenario): string {
  const bases = (["1B", "2B", "3B"] as const).filter((base) => scenario.runners[base]);
  if (bases.length === 0) return "Bases empty";
  return `Runner${bases.length > 1 ? "s" : ""} on ${bases.map((b) => BASE_LABELS[b]).join(" and ")}`;
}

type DecisionPhase = "ball-incoming" | "deciding" | "feedback";

/** Extra window after the timer bar empties where a tap still counts (just late) before it's a true no-tap timeout. */
const GRACE_PERIOD_MS = 4000;
/** Duration of the ball-flight-in cinematic before the timer starts. */
const BALL_INCOMING_MS = 800;
/** Duration of the throw animation before finalizing the decision. */
const THROW_ANIM_MS = 300;

/** Home plate coords — ball starts here (the batter just hit it). */
const HOME_COORD = { x: 50, y: 88 };

export function PlayingPhase({
  scenario,
  scenarioNumber,
  totalScenarios,
  onSubmitDecision,
  onNext,
}: PlayingPhaseProps) {
  const [decisionPhase, setDecisionPhase] = useState<DecisionPhase>("ball-incoming");
  const [outcome, setOutcome] = useState<DecisionOutcome | null>(null);
  const [isOvertime, setIsOvertime] = useState(false);
  const [ballCoord, setBallCoord] = useState<{ x: number; y: number }>(HOME_COORD);
  const [displayRunners, setDisplayRunners] = useState<Partial<Record<BaseOccupied, boolean>> | null>(null);

  const startTimeRef = useRef<number>(0);
  const decidedRef = useRef(false);
  const graceTimeoutRef = useRef<number | undefined>(undefined);
  const incomingTimerRef = useRef<number | undefined>(undefined);
  const throwTimerRef = useRef<number | undefined>(undefined);

  const timeLimitMs = scenario.timeLimitMs ?? DEFAULT_TIME_LIMIT_MS;

  // Ball-incoming cinematic: fly ball from plate to fielder, runners advance.
  useEffect(() => {
    setBallCoord(HOME_COORD);
    setDecisionPhase("ball-incoming");
    setDisplayRunners(null);
    decidedRef.current = false;

    // One rAF so the initial position renders before the transition target is set.
    const rafId = requestAnimationFrame(() => {
      setBallCoord(FIELDER_COORDS[scenario.fielderPosition]);
      setDisplayRunners(computeRunnersAfterHit(scenario));
    });

    incomingTimerRef.current = window.setTimeout(() => {
      startTimeRef.current = Date.now();
      setDecisionPhase("deciding");
    }, BALL_INCOMING_MS);

    return () => {
      cancelAnimationFrame(rafId);
      window.clearTimeout(incomingTimerRef.current);
      window.clearTimeout(graceTimeoutRef.current);
      window.clearTimeout(throwTimerRef.current);
    };
  }, [scenario.id]); // intentionally excludes scenario fields — only re-runs when scenario identity changes

  function finalizeDecision(chosen: ThrowTarget | null) {
    if (decidedRef.current) return;
    decidedRef.current = true;
    if (graceTimeoutRef.current !== undefined) window.clearTimeout(graceTimeoutRef.current);

    const reactionTimeMs = Date.now() - startTimeRef.current;
    const resolved = resolveOutcome(scenario.correctDecision, chosen, reactionTimeMs, timeLimitMs);

    const record: DecisionRecord = {
      scenarioId: scenario.id,
      chosen,
      correctDecision: scenario.correctDecision,
      outcome: resolved,
      reactionTimeMs,
      timeLimitMs,
    };

    onSubmitDecision(record);
    setOutcome(resolved);
    setDecisionPhase("feedback");
  }

  function handleThrow(target: ThrowTarget) {
    if (decidedRef.current || decisionPhase !== "deciding") return;
    // Briefly animate the ball toward the chosen target before locking in.
    setBallCoord(TARGET_COORDS[target]);
    throwTimerRef.current = window.setTimeout(() => finalizeDecision(target), THROW_ANIM_MS);
  }

  function handleTimeLimitReached() {
    if (decidedRef.current) return;
    setIsOvertime(true);
    graceTimeoutRef.current = window.setTimeout(() => {
      finalizeDecision(null);
    }, GRACE_PERIOD_MS);
  }

  const fieldDisabled = decisionPhase !== "deciding";

  return (
    <div className={styles.container}>
      <p className={styles.progress}>
        Play {scenarioNumber} of {totalScenarios}
      </p>
      <p className={styles.situation}>
        You're playing <strong>{scenario.fielderPosition}</strong> · {scenario.outs}{" "}
        {scenario.outs === 1 ? "out" : "outs"} · {describeRunners(scenario)}
      </p>
      <p className={styles.hitType}>{HIT_TYPE_LABELS[scenario.hitType]} hit your way! Where do you throw?</p>

      {decisionPhase === "deciding" && (
        <DecisionTimer scenarioKey={scenario.id} timeLimitMs={timeLimitMs} onExpire={handleTimeLimitReached} />
      )}
      {decisionPhase === "deciding" && isOvertime && (
        <p className={styles.overtime}>Time's up — throw now or it's a no-call!</p>
      )}

      <FieldView
        scenario={scenario}
        onThrow={handleThrow}
        disabled={fieldDisabled}
        ballCoord={ballCoord}
        displayRunners={displayRunners}
      />

      {decisionPhase === "feedback" && outcome && (
        <DecisionFeedback
          scenario={scenario}
          outcome={outcome}
          onNext={onNext}
          isLastScenario={scenarioNumber === totalScenarios}
        />
      )}
    </div>
  );
}
