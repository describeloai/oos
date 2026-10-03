import type { Integer } from "ore";
import type { Repetido } from "./tipos.ts";

export default function repeat(text: string, times: Integer = 1): Repetido {
  return { texto: text };
}
