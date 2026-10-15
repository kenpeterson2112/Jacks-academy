export type FieldingPosition = "LF" | "CF" | "RF";

export type ThrowTarget = "1B" | "2B" | "3B" | "Home" | "Cutoff";

export type BaseOccupied = "1B" | "2B" | "3B";

export type HitType =
  | "single"
  | "gapper"
  | "line-drive"
  | "fly-ball"
  | "ground-ball";

export interface Scenario {
  id: string;
  fielderPosition: FieldingPosition;
  outs: 0 | 1 | 2;
  runners: Partial<Record<BaseOccupied, boolean>>;
  hitType: HitType;
  correctDecision: ThrowTarget;
  explanation: string;
  /** Overrides DEFAULT_TIME_LIMIT_MS for this scenario when set. */
  timeLimitMs?: number;
  /** Shown when the kid makes the correct call. */
  videoUrlCorrect?: string;
  /** Shown when the kid makes the wrong call. */
  videoUrlIncorrect?: string;
}

export type DecisionOutcome =
  | "out"
  | "safe-correct-read"
  | "wrong-decision"
  | "timeout";

export interface DecisionRecord {
  scenarioId: string;
  chosen: ThrowTarget | null;
  correctDecision: ThrowTarget;
  outcome: DecisionOutcome;
  reactionTimeMs: number;
  timeLimitMs: number;
}

export interface GameSummary {
  totalScenarios: number;
  pointsScored: number;
  decisionAccuracyPct: number;
  speedSuccessPct: number;
  quizScore: number;
  quizTotal: number;
  overallBadge: string;
  completedAt: number;
}
