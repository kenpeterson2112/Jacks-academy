import { useState } from "react";
import type { QuizAnswerRecord, QuizQuestion } from "../../types/quiz";
import styles from "./QuizQuestionCard.module.css";

interface QuizQuestionCardProps {
  question: QuizQuestion;
  questionNumber: number;
  totalQuestions: number;
  onAnswer: (record: QuizAnswerRecord) => void;
  onNext: () => void;
  isLastQuestion: boolean;
}

function getChoices(question: QuizQuestion): string[] {
  return question.type === "multiple-choice" ? question.choices : ["False", "True"];
}

function isCorrectChoice(question: QuizQuestion, chosenIndex: number): boolean {
  return question.type === "multiple-choice"
    ? chosenIndex === question.correctChoiceIndex
    : (chosenIndex === 1) === question.correctAnswer;
}

export function QuizQuestionCard({
  question,
  questionNumber,
  totalQuestions,
  onAnswer,
  onNext,
  isLastQuestion,
}: QuizQuestionCardProps) {
  const [chosenIndex, setChosenIndex] = useState<number | null>(null);
  const choices = getChoices(question);

  function handleChoose(index: number) {
    if (chosenIndex !== null) return;
    setChosenIndex(index);
    onAnswer({
      questionId: question.id,
      chosenIndex: index,
      correct: isCorrectChoice(question, index),
    });
  }

  return (
    <div className={styles.card}>
      <p className={styles.progress}>
        Question {questionNumber} of {totalQuestions}
      </p>
      <h2 className={styles.prompt}>{question.prompt}</h2>

      <div className={styles.choices}>
        {choices.map((choice, index) => {
          const answered = chosenIndex !== null;
          const isChosen = chosenIndex === index;
          const isCorrect = answered && isCorrectChoice(question, index);
          const stateClass = !answered
            ? ""
            : isCorrect
              ? styles.correct
              : isChosen
                ? styles.incorrect
                : "";

          return (
            <button
              key={choice}
              type="button"
              className={`${styles.choice} ${stateClass}`}
              onClick={() => handleChoose(index)}
              disabled={answered}
            >
              {choice}
            </button>
          );
        })}
      </div>

      {chosenIndex !== null && (
        <div className={styles.feedback}>
          <p className={styles.explanation}>{question.explanation}</p>
          <button type="button" className={styles.nextButton} onClick={onNext}>
            {isLastQuestion ? "See My Results" : "Next Question"}
          </button>
        </div>
      )}
    </div>
  );
}
