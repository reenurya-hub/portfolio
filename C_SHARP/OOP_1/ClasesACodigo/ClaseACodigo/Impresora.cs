using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClaseACodigo
{
    public class Impresora
    {
        public void Imprimir(DocumentoContable unDocumento)
        {
            Console.WriteLine($"Imprimiento {unDocumento.Siglas} de {unDocumento.Importe} del dia {unDocumento.Fecha}");
        }
        /*
        public void Imprimir(Factura unaFactura)
        {
            Console.WriteLine($"Imprimiento una factura de {unaFactura.Importe}");
        }
        */
        public void Imprimir(Remito unRemito)
        {
            Console.WriteLine($"Imprimiento un remito con {unRemito.CantidadBultos} bultos");
        }

        public void Imprimir(ReciboSueldo unReciboSueldo)
        {
            Console.WriteLine($"Imprimiento un recibo de sueldo del legajo {unReciboSueldo.Legajo}");
        }

        public void Imprimir(Municipal unMunicipal)
        {
            Console.WriteLine($"Imprimiento el municipal de la partida {unMunicipal.Partida}");
        }

        public void Imprimir(FacturaLuz unaFacturaLuz)
        {
            Console.WriteLine($"Imprimiento la factura de luz de codigo de pago electronico {unaFacturaLuz.CodigoPago}");
        }



    }
}
