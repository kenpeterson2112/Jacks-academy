import { useEffect, useRef, useState } from "react";
import styles from "./DecisionTimer.module.css";

interface DecisionTimerProps {
  /** Changing this key resets the countdown — pass the scenario id. */
  scenarioKey: string;
  timeLimitMs: number;
  onExpire: () => void;
}

const TICK_MS = 50;

export const DEFAULT_TIME_LIMIT_MS = 3000;

export function DecisionTimer({ scenarioKey, timeLimitMs, onExpire }: DecisionTimerProps) {
  const [remainingMs, setRemainingMs] = useState(timeLimitMs);
  const onExpireRef = useRef(onExpire);
  onExpireRef.current = onExpire;

  useEffect(() => {
    let expired = false;
    const startedAt = Date.now();
    setRemainingMs(timeLimitMs);

    const intervalId = window.setInterval(() => {
      const elapsed = Date.now() - startedAt;
      const next = Math.max(0, timeLimitMs - elapsed);
      setRemainingMs(next);
      if (next <= 0 && !expired) {
        expired = true;
        window.clearInterval(intervalId);
        onExpireRef.current();
      }
    }, TICK_MS);

    return () => window.clearInterval(intervalId);
  }, [scenarioKey, timeLimitMs]);

  const pct = timeLimitMs === 0 ? 0 : Math.max(0, Math.min(100, (remainingMs / timeLimitMs) * 100));
  const isUrgent = pct <= 25;

  return (
    <div className={styles.track} role="timer" aria-label="Time remaining to make your throw">
      <div
        className={`${styles.fill} ${isUrgent ? styles.urgent : ""}`}
        style={{ width: `${pct}%` }}
      />
    </div>
  );
}
