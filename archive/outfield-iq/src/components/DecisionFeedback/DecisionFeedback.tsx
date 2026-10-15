import type { DecisionOutcome, Scenario } from "../../types/game";
import { WatchPlayLink } from "../WatchPlayLink/WatchPlayLink";
import styles from "./DecisionFeedback.module.css";

interface DecisionFeedbackProps {
  scenario: Scenario;
  outcome: DecisionOutcome;
  onNext: () => void;
  isLastScenario: boolean;
}

const HEADLINES: Record<DecisionOutcome, string> = {
  out: "OUT! Great read and a strong throw.",
  "safe-correct-read": "Safe — but you read it right. The runner just beat your throw.",
  "wrong-decision": "Wrong call.",
  timeout: "Time's up!",
};

const OUTCOME_STYLES: Record<DecisionOutcome, string> = {
  out: "out",
  "safe-correct-read": "safeCorrectRead",
  "wrong-decision": "wrongDecision",
  timeout: "timeout",
};

export function DecisionFeedback({ scenario, outcome, onNext, isLastScenario }: DecisionFeedbackProps) {
  const videoUrl = outcome === "out" ? scenario.videoUrlCorrect : scenario.videoUrlIncorrect;

  return (
    <div className={`${styles.card} ${styles[OUTCOME_STYLES[outcome]]}`}>
      <h2 className={styles.headline}>{HEADLINES[outcome]}</h2>
      <p className={styles.explanation}>{scenario.explanation}</p>
      <WatchPlayLink url={videoUrl} />
      <button type="button" className={styles.nextButton} onClick={onNext}>
        {isLastScenario ? "Go to Quiz" : "Next Play"}
      </button>
    </div>
  );
}
