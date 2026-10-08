import static ore.Ore.*;

import com.acme.Transform;

public class Resumen {
    static final String PEDIDOS = "ventas.pedidos";

    /**
     * El total por país.
     *
     * @return lo que escribe write()
     */
    @Transform(inputs = {PEDIDOS, "ventas.clientes"}, output = "ventas.resumen")
    public static Object resumen() throws Exception {
        return write("ventas.resumen", over(PEDIDOS));
    }
}
