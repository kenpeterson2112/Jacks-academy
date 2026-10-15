import type { QuizAnswerRecord, QuizQuestion } from "../../types/quiz";
import { QuizQuestionCard } from "../QuizQuestionCard/QuizQuestionCard";
import styles from "./QuizPhase.module.css";

interface QuizPhaseProps {
  question: QuizQuestion;
  questionNumber: number;
  totalQuestions: number;
  onAnswer: (record: QuizAnswerRecord) => void;
  onNext: () => void;
}

export function QuizPhase({ question, questionNumber, totalQuestions, onAnswer, onNext }: QuizPhaseProps) {
  return (
    <div className={styles.container}>
      <h1 className={styles.heading}>Outfielder IQ Quiz</h1>
      <QuizQuestionCard
        key={question.id}
        question={question}
        questionNumber={questionNumber}
        totalQuestions={totalQuestions}
        onAnswer={onAnswer}
        onNext={onNext}
        isLastQuestion={questionNumber === totalQuestions}
      />
    </div>
  );
}
