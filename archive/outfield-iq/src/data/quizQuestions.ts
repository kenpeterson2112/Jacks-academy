import type { QuizQuestion } from "../types/quiz";

/**
 * Hand-authored quiz bank covering outfielder rules and runner-advancement logic.
 */
export const QUIZ_BANK: QuizQuestion[] = [
  {
    id: "q1",
    type: "multiple-choice",
    prompt:
      "There's one out and a runner on second. The batter hits a single to you in the outfield. What should you do?",
    choices: [
      "Throw behind the runner, back toward second base",
      "Throw ahead of the runner, to third base",
      "Throw all the way home no matter what",
      "Hold the ball and jog it back to the infield",
    ],
    correctChoiceIndex: 1,
    // PLACEHOLDER — verify rules accuracy before shipping real content
    explanation:
      "Throwing behind a runner who's already past a base rarely gets an out and lets other runners advance for free. With one out, the smart play is to throw ahead of the runner — to third base — to keep the lead runner from taking an extra bag.",
  },
  {
    id: "q2",
    type: "true-false",
    prompt:
      "True or False: An outfielder playing deep should always throw the ball all the way home, no matter how far away they are.",
    correctAnswer: false,
    // PLACEHOLDER — verify rules accuracy before shipping real content
    explanation:
      "False! From deep in the outfield, a direct throw home is often too slow and inaccurate. Hitting the cutoff man lets the infield relay the throw faster and keeps every runner in check.",
  },
  {
    id: "q3",
    type: "multiple-choice",
    prompt: "What is the cutoff man's main job on a relay throw from the outfield?",
    choices: [
      "Catch the ball and immediately throw it to whatever base looks open",
      "Line up between the outfielder and the target base, then redirect the throw based on what the runners do",
      "Stand at home plate and wait for the ball",
      "Run out to the outfield to help field the ball",
    ],
    correctChoiceIndex: 1,
    // PLACEHOLDER — verify rules accuracy before shipping real content
    explanation:
      "The cutoff man lines up between the outfielder and the target base. They catch the relay and decide — based on where the runners are — whether to continue the throw, hold it, or redirect it to a different base.",
  },
];
