import { useEffect, useState } from "react";
import { useGameSession } from "./state/useGameSession";
import { IntroScreen } from "./components/IntroScreen/IntroScreen";
import { PlayingPhase } from "./components/PlayingPhase/PlayingPhase";
import { QuizPhase } from "./components/QuizPhase/QuizPhase";
import { SummaryScreen } from "./components/SummaryScreen/SummaryScreen";
import { loadLastSummary, saveLastSummary } from "./utils/persistence";
import type { GameSummary } from "./types/game";
import styles from "./App.module.css";

export default function App() {
  const session = useGameSession();
  const [lastSummary, setLastSummary] = useState<GameSummary | null>(() => loadLastSummary());

  useEffect(() => {
    if (session.summary) {
      saveLastSummary(session.summary);
      setLastSummary(session.summary);
    }
  }, [session.summary]);

  return (
    <div className={styles.app}>
      {session.phase === "intro" && <IntroScreen onStart={session.start} lastSummary={lastSummary} />}

      {session.phase === "playing" && session.currentScenario && (
        <PlayingPhase
          key={session.currentScenario.id}
          scenario={session.currentScenario}
          scenarioNumber={session.currentScenarioIndex + 1}
          totalScenarios={session.totalScenarios}
          onSubmitDecision={session.submitDecision}
          onNext={session.nextScenario}
        />
      )}

      {session.phase === "quiz" && session.currentQuizQuestion && (
        <QuizPhase
          question={session.currentQuizQuestion}
          questionNumber={session.currentQuizIndex + 1}
          totalQuestions={session.totalQuizQuestions}
          onAnswer={session.submitQuizAnswer}
          onNext={session.nextQuizQuestion}
        />
      )}

      {session.phase === "summary" && session.summary && (
        <SummaryScreen summary={session.summary} onPlayAgain={session.restart} />
      )}
    </div>
  );
}
