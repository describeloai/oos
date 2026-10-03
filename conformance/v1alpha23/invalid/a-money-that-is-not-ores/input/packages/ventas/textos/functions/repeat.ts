import type { Integer } from "ore";

type Money<U extends string, S extends number> = string;

export default function repeat(text: string, times: Integer = 1, precio: Money<"EUR", 2> = "0"): string {
  return text;
}
