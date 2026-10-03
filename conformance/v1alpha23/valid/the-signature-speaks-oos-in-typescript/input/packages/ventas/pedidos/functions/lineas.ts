import type { Integer, LocalDate, LocalDateTime, LocalTime, Money as Dinero } from "ore";
import type * as ore from "ore";

type Linea = {
  producto: string;
  precio: Dinero<"EUR", 2>;
  notas?: string | null;
};

interface Pedido {
  id: bigint;
  lineas: readonly Linea[];
  entrega: LocalTime;
}

/** Las líneas de un pedido que pesan. */
export default function lineas(
  pedido: Pedido,
  corte: Date,
  firma: Uint8Array,
  tasa: ore.Decimal<5, 4>,
  dia: LocalDate,
  visto: LocalDateTime | null,
  intentos: Integer,
  ratio: number,
  activo: boolean,
  peso?: ore.Quantity<"kg", 3>,
): Array<Linea> {
  return [...pedido.lineas];
}
