import type { Decimal } from "ore";

export const config = {
  over: "ventas.clientes",
  reads: ["ventas.pedidos"],
  models: ["extractor"],
  timeout: "60s",
} as const;

interface Riesgo {
  nivel: string;
  total: number;
  motivo?: string;
}

/**
 * El riesgo de un cliente por lo que ha comprado.
 *
 * @param umbral a partir de cuánto es alto
 */
export default async function riesgo(cliente: Record<string, unknown>, umbral: Decimal<12, 2>, moneda: string = "EUR"): Promise<Riesgo> {
  return { nivel: "bajo", total: 0 };
}
