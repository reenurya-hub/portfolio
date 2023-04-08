using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_D
{
    public class FacturaLuz: Impuesto
    {
        public FacturaLuz(double importe, string codigoPago): base(importe)
        {
            CodigoPago = codigoPago;
        }
        public string CodigoPago { get; set; }

        public override void Imprimir()
        {
            Console.WriteLine($"Imprimiento Factura de luz con codigo de pago No. {CodigoPago} por un valor de {Importe}");
        }
    }
}
