import type { GameSummary } from "../../types/game";
import styles from "./SummaryScreen.module.css";

interface SummaryScreenProps {
  summary: GameSummary;
  onPlayAgain: () => void;
}

export function SummaryScreen({ summary, onPlayAgain }: SummaryScreenProps) {
  return (
    <div className={styles.container}>
      <h1 className={styles.heading}>Game Summary</h1>

      <div className={styles.badge}>{summary.overallBadge}</div>

      <div className={styles.stats}>
        <div className={styles.stat}>
          <span className={styles.statValue}>{summary.decisionAccuracyPct}%</span>
          <span className={styles.statLabel}>Decision accuracy</span>
        </div>
        <div className={styles.stat}>
          <span className={styles.statValue}>{summary.speedSuccessPct}%</span>
          <span className={styles.statLabel}>Speed success</span>
        </div>
        <div className={styles.stat}>
          <span className={styles.statValue}>
            {summary.pointsScored}/{summary.totalScenarios}
          </span>
          <span className={styles.statLabel}>Outs made</span>
        </div>
        <div className={styles.stat}>
          <span className={styles.statValue}>
            {summary.quizScore}/{summary.quizTotal}
          </span>
          <span className={styles.statLabel}>Quiz score</span>
        </div>
      </div>

      <button type="button" className={styles.playAgainButton} onClick={onPlayAgain}>
        Play Again
      </button>
    </div>
  );
}
