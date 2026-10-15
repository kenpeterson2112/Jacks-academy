import styles from "./WatchPlayLink.module.css";

interface WatchPlayLinkProps {
  url: string | undefined;
}

export function WatchPlayLink({ url }: WatchPlayLinkProps) {
  if (!url) return null;

  return (
    <a href={url} target="_blank" rel="noopener noreferrer" className={styles.link}>
      ▶ Watch the real play
    </a>
  );
}
