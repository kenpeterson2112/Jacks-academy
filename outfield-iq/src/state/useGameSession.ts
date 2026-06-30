import { useCallback, useMemo, useState } from "react";
import type { DecisionRecord, FieldingPosition, GameSummary, Scenario } from "../types/game";
import type { QuizAnswerRecord, QuizQuestion } from "../types/quiz";
import { SCENARIO_BANK } from "../data/scenarios";
import { QUIZ_BANK } from "../data/quizQuestions";
import { buildSequence, pickRandom } from "../utils/random";
import { computeSummary } from "../utils/scoring";
import type { GamePhase } from "./gamePhase";

const SCENARIOS_PER_SESSION = 8;
const FIELDING_POSITIONS: FieldingPosition[] = ["LF", "CF", "RF"];

/** Each play gets a freshly randomized fielder position — never fixed per session. */
function randomizeScenarioSequence(): Scenario[] {
  return buildSequence(SCENARIO_BANK, SCENARIOS_PER_SESSION).map((scenario, index) => ({
    ...scenario,
    id: `${scenario.id}-${index}`,
    fielderPosition: pickRandom(FIELDING_POSITIONS),
  }));
}

interface GameSessionState {
  phase: GamePhase;
  scenarios: Scenario[];
  currentScenarioIndex: number;
  decisions: DecisionRecord[];
  quizQuestions: QuizQuestion[];
  currentQuizIndex: number;
  quizAnswers: QuizAnswerRecord[];
  summary: GameSummary | null;
}

function initialState(): GameSessionState {
  return {
    phase: "intro",
    scenarios: [],
    currentScenarioIndex: 0,
    decisions: [],
    quizQuestions: [],
    currentQuizIndex: 0,
    quizAnswers: [],
    summary: null,
  };
}

export function useGameSession() {
  const [state, setState] = useState<GameSessionState>(initialState);

  const start = useCallback(() => {
    setState({
      phase: "playing",
      scenarios: randomizeScenarioSequence(),
      currentScenarioIndex: 0,
      decisions: [],
      quizQuestions: buildSequence(QUIZ_BANK, QUIZ_BANK.length),
      currentQuizIndex: 0,
      quizAnswers: [],
      summary: null,
    });
  }, []);

  const submitDecision = useCallback((record: DecisionRecord) => {
    setState((prev) => ({ ...prev, decisions: [...prev.decisions, record] }));
  }, []);

  const nextScenario = useCallback(() => {
    setState((prev) => {
      const nextIndex = prev.currentScenarioIndex + 1;
      if (nextIndex >= prev.scenarios.length) {
        return { ...prev, phase: "quiz" };
      }
      return { ...prev, currentScenarioIndex: nextIndex };
    });
  }, []);

  const submitQuizAnswer = useCallback((record: QuizAnswerRecord) => {
    setState((prev) => ({ ...prev, quizAnswers: [...prev.quizAnswers, record] }));
  }, []);

  const nextQuizQuestion = useCallback(() => {
    setState((prev) => {
      const nextIndex = prev.currentQuizIndex + 1;
      if (nextIndex >= prev.quizQuestions.length) {
        const summary = computeSummary(prev.decisions, prev.quizAnswers);
        return { ...prev, phase: "summary", summary };
      }
      return { ...prev, currentQuizIndex: nextIndex };
    });
  }, []);

  const restart = useCallback(() => {
    setState(initialState());
  }, []);

  const currentScenario = state.scenarios[state.currentScenarioIndex] ?? null;
  const currentQuizQuestion = state.quizQuestions[state.currentQuizIndex] ?? null;

  return useMemo(
    () => ({
      phase: state.phase,
      currentScenario,
      currentScenarioIndex: state.currentScenarioIndex,
      totalScenarios: state.scenarios.length,
      decisions: state.decisions,
      currentQuizQuestion,
      currentQuizIndex: state.currentQuizIndex,
      totalQuizQuestions: state.quizQuestions.length,
      quizAnswers: state.quizAnswers,
      summary: state.summary,
      start,
      submitDecision,
      nextScenario,
      submitQuizAnswer,
      nextQuizQuestion,
      restart,
    }),
    [
      state,
      currentScenario,
      currentQuizQuestion,
      start,
      submitDecision,
      nextScenario,
      submitQuizAnswer,
      nextQuizQuestion,
      restart,
    ]
  );
}
