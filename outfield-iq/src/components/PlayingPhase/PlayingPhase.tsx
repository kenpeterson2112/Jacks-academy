import { useEffect, useRef, useState } from "react";
import type { DecisionOutcome, DecisionRecord, Scenario, ThrowTarget } from "../../types/game";
import { FieldView } from "../FieldView/FieldView";
import { DecisionTimer, DEFAULT_TIME_LIMIT_MS } from "../DecisionTimer/DecisionTimer";
import { DecisionFeedback } from "../DecisionFeedback/DecisionFeedback";
import { resolveOutcome } from "../../utils/scoring";
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

type DecisionPhase = "deciding" | "feedback";

/** Extra window after the timer bar empties where a tap still counts (just late) before it's a true no-tap timeout. */
const GRACE_PERIOD_MS = 4000;

export function PlayingPhase({
  scenario,
  scenarioNumber,
  totalScenarios,
  onSubmitDecision,
  onNext,
}: PlayingPhaseProps) {
  const [decisionPhase, setDecisionPhase] = useState<DecisionPhase>("deciding");
  const [outcome, setOutcome] = useState<DecisionOutcome | null>(null);
  const [isOvertime, setIsOvertime] = useState(false);
  const startTimeRef = useRef(Date.now());
  const decidedRef = useRef(false);
  const graceTimeoutRef = useRef<number | undefined>(undefined);

  const timeLimitMs = scenario.timeLimitMs ?? DEFAULT_TIME_LIMIT_MS;

  useEffect(() => {
    return () => {
      if (graceTimeoutRef.current !== undefined) {
        window.clearTimeout(graceTimeoutRef.current);
      }
    };
  }, []);

  function finalizeDecision(chosen: ThrowTarget | null) {
    if (decidedRef.current) return;
    decidedRef.current = true;
    if (graceTimeoutRef.current !== undefined) {
      window.clearTimeout(graceTimeoutRef.current);
    }

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
    finalizeDecision(target);
  }

  function handleTimeLimitReached() {
    if (decidedRef.current) return;
    setIsOvertime(true);
    graceTimeoutRef.current = window.setTimeout(() => {
      finalizeDecision(null);
    }, GRACE_PERIOD_MS);
  }

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

      <FieldView scenario={scenario} onThrow={handleThrow} disabled={decisionPhase === "feedback"} />

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
