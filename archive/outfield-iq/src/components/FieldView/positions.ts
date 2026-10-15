import type { FieldingPosition, ThrowTarget } from "../../types/game";

export interface Coord {
  x: number;
  y: number;
}

/** Percentage coordinates on a 0-100 viewBox, including the cutoff relay spot. */
export const TARGET_COORDS: Record<ThrowTarget, Coord> = {
  Home: { x: 50, y: 88 },
  "1B": { x: 74, y: 64 },
  "2B": { x: 50, y: 38 },
  "3B": { x: 26, y: 64 },
  Cutoff: { x: 50, y: 54 },
};

export const FIELDER_COORDS: Record<FieldingPosition, Coord> = {
  LF: { x: 20, y: 16 },
  CF: { x: 50, y: 11 },
  RF: { x: 80, y: 16 },
};

/** Where the fielder ends up and the ball lands for a gapper — deeper in the gap. */
export const GAPPER_COORDS: Record<FieldingPosition, Coord> = {
  LF: { x: 30, y: 8 },
  CF: { x: 50, y: 5 },
  RF: { x: 70, y: 8 },
};

/** Where the relay infielder stands for a gapper, keyed by which outfielder is throwing. */
export const CUTOFF_COORDS: Record<FieldingPosition, Coord> = {
  LF: { x: 35, y: 46 },
  CF: { x: 50, y: 42 },
  RF: { x: 65, y: 46 },
};

/** Which infield position acts as relay man for each outfield spot. */
export const CUTOFF_LABEL: Record<FieldingPosition, string> = {
  LF: "SS",
  CF: "SS",
  RF: "2B",
};

export const PITCHER_MOUND_COORD: Coord = { x: 50, y: 64 };

export const THROW_TARGETS: { id: ThrowTarget; label: string }[] = [
  { id: "1B", label: "1B" },
  { id: "2B", label: "2B" },
  { id: "3B", label: "3B" },
  { id: "Home", label: "Home" },
  { id: "Cutoff", label: "Cutoff Man" },
];
