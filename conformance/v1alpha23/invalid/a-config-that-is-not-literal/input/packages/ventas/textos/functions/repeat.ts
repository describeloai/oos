import type { Integer } from "ore";

const PLAZO = "30s";

export const config = { timeout: PLAZO };

export default function repeat(text: string, times: Integer = 1): string {
  return text;
}
