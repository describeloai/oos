import static ore.Ore.*;

import ore.*;

// Un comentario no es una anotación: @Transform(inputs = {}, output = "ventas.nada")
public final class Pedidos {
    static final String CLIENTES = "ventas.clientes";

    @Transform(inputs = "ventas.pedidos", output = "ventas.por_pais")
    public static Object porPais() throws Exception {
        return write("ventas.por_pais", sql("select 1 as n"));
    }

    @ore.Transform(inputs = {Pedidos.CLIENTES}, output = "ventas.activos")
    public static Object activos() throws Exception {
        String texto = "@Transform(inputs = {}, output = \"ventas.otra\")";
        return write("ventas.activos", over(CLIENTES));
    }

    static String ayuda() { return "no es un transform"; }
}
