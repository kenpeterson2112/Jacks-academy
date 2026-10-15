import type { DecisionOutcome, DecisionRecord, GameSummary, ThrowTarget } from "../types/game";
import type { QuizAnswerRecord } from "../types/quiz";

export function resolveOutcome(
  correctDecision: ThrowTarget,
  chosen: ThrowTarget | null,
  reactionTimeMs: number,
  timeLimitMs: number
): DecisionOutcome {
  if (chosen === null) return "timeout";
  if (chosen !== correctDecision) return "wrong-decision";
  return reactionTimeMs <= timeLimitMs ? "out" : "safe-correct-read";
}

export function computeBadge(overallPct: number): string {
  if (overallPct >= 90) return "Gold Glove";
  if (overallPct >= 70) return "Solid Outfielder";
  if (overallPct >= 50) return "Rookie";
  return "Keep Practicing";
}

export function computeSummary(
  decisions: DecisionRecord[],
  quizAnswers: QuizAnswerRecord[]
): GameSummary {
  const totalScenarios = decisions.length;
  const correctDecisions = decisions.filter(
    (d) => d.outcome === "out" || d.outcome === "safe-correct-read"
  );
  const pointsScored = decisions.filter((d) => d.outcome === "out").length;

  const decisionAccuracyPct = totalScenarios === 0
    ? 0
    : Math.round((correctDecisions.length / totalScenarios) * 100);

  const speedSuccessPct = correctDecisions.length === 0
    ? 0
    : Math.round((pointsScored / correctDecisions.length) * 100);

  const quizTotal = quizAnswers.length;
  const quizScore = quizAnswers.filter((a) => a.correct).length;

  const scenarioPct = totalScenarios === 0 ? 0 : (pointsScored / totalScenarios) * 100;
  const quizPct = quizTotal === 0 ? 0 : (quizScore / quizTotal) * 100;
  const overallPct = (scenarioPct + quizPct) / 2;

  return {
    totalScenarios,
    pointsScored,
    decisionAccuracyPct,
    speedSuccessPct,
    quizScore,
    quizTotal,
    overallBadge: computeBadge(overallPct),
    completedAt: Date.now(),
  };
}
