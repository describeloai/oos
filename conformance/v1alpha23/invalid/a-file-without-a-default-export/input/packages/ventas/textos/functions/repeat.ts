import type { Integer } from "ore";

export function repeat(text: string, times: Integer = 1): string {
  return Array(times).fill(text).join(" ");
}
