import type { CSSProperties } from "react";
import type { Scenario, ThrowTarget } from "../../types/game";
import { FIELDER_COORDS, PITCHER_MOUND_COORD, TARGET_COORDS, THROW_TARGETS } from "./positions";
import styles from "./FieldView.module.css";

interface FieldViewProps {
  scenario: Scenario;
  onThrow: (target: ThrowTarget) => void;
  disabled?: boolean;
}

function coordVars(x: number, y: number): CSSProperties {
  return { "--x": x, "--y": y } as CSSProperties;
}

export function FieldView({ scenario, onThrow, disabled = false }: FieldViewProps) {
  const fielderCoord = FIELDER_COORDS[scenario.fielderPosition];
  const occupiedBases = (["1B", "2B", "3B"] as const).filter((base) => scenario.runners[base]);

  return (
    <div className={styles.container}>
      <svg viewBox="0 0 100 100" className={styles.diamond} aria-hidden="true">
        <path d="M 50,90 L 88,52 A 54 54 0 0 0 12,52 Z" className={styles.outfieldGrass} />
        <polygon
          points={`${TARGET_COORDS.Home.x},${TARGET_COORDS.Home.y} ${TARGET_COORDS["1B"].x},${TARGET_COORDS["1B"].y} ${TARGET_COORDS["2B"].x},${TARGET_COORDS["2B"].y} ${TARGET_COORDS["3B"].x},${TARGET_COORDS["3B"].y}`}
          className={styles.infieldDirt}
        />
        <circle cx={PITCHER_MOUND_COORD.x} cy={PITCHER_MOUND_COORD.y} r="3.5" className={styles.mound} />

        {(["1B", "2B", "3B"] as const).map((base) => (
          <rect
            key={base}
            x={TARGET_COORDS[base].x - 2.2}
            y={TARGET_COORDS[base].y - 2.2}
            width="4.4"
            height="4.4"
            className={styles.base}
            transform={`rotate(45 ${TARGET_COORDS[base].x} ${TARGET_COORDS[base].y})`}
          />
        ))}
        <rect
          x={TARGET_COORDS.Home.x - 2.5}
          y={TARGET_COORDS.Home.y - 2.5}
          width="5"
          height="5"
          className={styles.homePlate}
        />

        {occupiedBases.map((base) => (
          <circle
            key={`runner-${base}`}
            cx={TARGET_COORDS[base].x}
            cy={TARGET_COORDS[base].y - 6}
            r="2.6"
            className={styles.runner}
          >
            <title>Runner on {base}</title>
          </circle>
        ))}

        <circle cx={fielderCoord.x} cy={fielderCoord.y} r="3" className={styles.fielder}>
          <title>{scenario.fielderPosition} fielder</title>
        </circle>
        <text x={fielderCoord.x} y={fielderCoord.y - 6} className={styles.fielderLabel}>
          {scenario.fielderPosition}
        </text>
      </svg>

      <div className={styles.targets}>
        {THROW_TARGETS.map((target) => {
          const coord = TARGET_COORDS[target.id];
          return (
            <button
              key={target.id}
              type="button"
              className={styles.target}
              style={coordVars(coord.x, coord.y)}
              onClick={() => onThrow(target.id)}
              disabled={disabled}
              aria-label={`Throw to ${target.label}`}
            >
              {target.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}
