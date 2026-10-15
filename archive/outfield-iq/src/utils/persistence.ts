import type { GameSummary } from "../types/game";

const STORAGE_KEY = "outfield-iq:last-summary";

export function saveLastSummary(summary: GameSummary): void {
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(summary));
  } catch {
    // localStorage unavailable (private browsing, storage full, etc.) — non-fatal.
  }
}

export function loadLastSummary(): GameSummary | null {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw) as GameSummary;
  } catch {
    return null;
  }
}
