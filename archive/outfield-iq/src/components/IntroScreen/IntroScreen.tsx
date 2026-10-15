import type { GameSummary } from "../../types/game";
import styles from "./IntroScreen.module.css";

interface IntroScreenProps {
  onStart: () => void;
  lastSummary: GameSummary | null;
}

export function IntroScreen({ onStart, lastSummary }: IntroScreenProps) {
  return (
    <div className={styles.container}>
      <h1 className={styles.title}>⚾ Outfield IQ</h1>
      <p className={styles.tagline}>Think fast. Throw smart. Make the play.</p>

      <div className={styles.instructions}>
        <p>You're an outfielder. A ball is hit your way and you've got just a few seconds to decide:</p>
        <ul>
          <li>1st base</li>
          <li>2nd base</li>
          <li>3rd base</li>
          <li>Home plate</li>
          <li>Hit the cutoff man</li>
        </ul>
        <p>Pick the right base — and be quick about it — to get the out.</p>
        <p>After 8 plays, you'll take a quick quiz on outfielder rules.</p>
      </div>

      {lastSummary && (
        <div className={styles.lastResult}>
          <p className={styles.lastResultHeading}>Last time you played:</p>
          <p>
            <strong>{lastSummary.overallBadge}</strong> · {lastSummary.decisionAccuracyPct}% decision accuracy ·{" "}
            {lastSummary.quizScore}/{lastSummary.quizTotal} quiz score
          </p>
        </div>
      )}

      <button type="button" className={styles.startButton} onClick={onStart}>
        Play Ball
      </button>
    </div>
  );
}
