import static ore.Ore.*;

import ore.Transform;

public class Resumen {
    static final String PEDIDOS = "ventas.pedidos";

    /**
     * El total por país.
     *
     * @return lo que escribe write()
     */
    public static Object resumen() throws Exception {
        return write("ventas.resumen", over(PEDIDOS));
    }
}
