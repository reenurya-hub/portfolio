using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_D
{
    public class Impresora
    {
        public void Imprimir(IImprimible imprimible)
        {
            imprimible.Imprimir();
        }

        /*
        public void Imprimir(Factura factura)
        {
           // Console.WriteLine($"Imprimiento factura {factura.Numero} del {factura.Fecha} por un valor de {factura.Importe}");

        }
        public void Imprimir(NotaCredito notaCredito)
        {
            //Console.WriteLine($"Imprimiento Nota de Crédito {notaCredito.Numero} del {notaCredito.Fecha} por un valor de {notaCredito.Importe}");
        }
        public void Imprimir(FacturaLuz facturaLuz)
        {
            //Console.WriteLine($"Imprimiento Factura de luz con codigo de pago No. {facturaLuz.CodigoPago} por un valor de {facturaLuz.Importe}");
        }
        public void Imprimir(Municipal municipal)
        {
            //Console.WriteLine($"Imprimiento impuesto municipal de partida {municipal.Partida} por un valor de {municipal.Importe}");
        }
        public void Imprimir(ReciboSueldo reciboSueldo)
        {
            //Console.WriteLine($"Imprimiento recibo de sueldo del legajo {reciboSueldo.Legajo} por un valor de {reciboSueldo.Total}");
        }
        public void Imprimir(Remito remito)
        {
            Console.WriteLine($"Imprimiento remito Nro. {remito.Numero} de fecha {remito.Fecha} por una cantidad de bultos {remito.CantBultos}");
        }

        */
    }
}
