import type { Integer } from "ore";
import { unir } from "./unir.ts";

export default function repeat(text: string, times: Integer = 1): string {
  return unir(Array(times).fill(text));
}
