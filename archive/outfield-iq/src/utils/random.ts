export function pickRandom<T>(items: readonly T[]): T {
  return items[Math.floor(Math.random() * items.length)];
}

export function shuffle<T>(items: readonly T[]): T[] {
  const result = [...items];
  for (let i = result.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [result[i], result[j]] = [result[j], result[i]];
  }
  return result;
}

/** Builds a sequence of `count` items drawn from `bank`, reshuffling/looping if `count` exceeds bank size. */
export function buildSequence<T>(bank: readonly T[], count: number): T[] {
  if (bank.length === 0) return [];
  const sequence: T[] = [];
  while (sequence.length < count) {
    const remaining = count - sequence.length;
    const batch = shuffle(bank).slice(0, remaining);
    sequence.push(...batch);
  }
  return sequence;
}
