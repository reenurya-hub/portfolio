using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClaseACodigo
{
    public class Program
    {
        static void Main(string[] args)
        {
            DocumentoContable unaFactura = new Factura()
            {
                Importe = 1500
            };

            DocumentoContable unaNotaCredito = new NotaCredito()
            {
                Importe = 1500
            };

            Remito unRemito = new Remito()
            {
                CantidadBultos = 10
            };
            FacturaLuz unaFacturaLuz = new FacturaLuz()
            {
                CodigoPago = "1245544545"
            };
            Municipal unMunicipal = new Municipal()
            {
                Partida = "SDFG 443434-AAD"
            };
            ReciboSueldo unReciboSueldo = new ReciboSueldo()
            {
                Legajo = 2212
            };

            Impresora unaImpresora = new Impresora();

            unaImpresora.Imprimir(unMunicipal);
            unaImpresora.Imprimir(unaFactura);
            unaImpresora.Imprimir(unaNotaCredito);
            unaImpresora.Imprimir(unReciboSueldo);
            unaImpresora.Imprimir(unaFacturaLuz);
            unaImpresora.Imprimir(unRemito);
            Console.ReadKey();

        }
    }
}
