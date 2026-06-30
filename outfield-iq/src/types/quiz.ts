export interface MultipleChoiceQuestion {
  id: string;
  type: "multiple-choice";
  prompt: string;
  choices: string[];
  correctChoiceIndex: number;
  explanation: string;
}

export interface TrueFalseQuestion {
  id: string;
  type: "true-false";
  prompt: string;
  correctAnswer: boolean;
  explanation: string;
}

export type QuizQuestion = MultipleChoiceQuestion | TrueFalseQuestion;

export interface QuizAnswerRecord {
  questionId: string;
  /** Index into choices for multiple-choice, or 0/1 (false/true) for true-false. */
  chosenIndex: number;
  correct: boolean;
}
