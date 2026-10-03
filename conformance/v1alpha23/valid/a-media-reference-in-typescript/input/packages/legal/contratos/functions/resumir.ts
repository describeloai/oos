import type { Media } from "ore";

/** El resumen de un contrato. */
export default function resumir(contrato: Media<"legal.archivo.contratos">): string {
  return contrato.path;
}
