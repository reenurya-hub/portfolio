using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_D
{
    public class Factura : DocumentoContable
    {
        public Factura(int numero, DateTime fecha, double importe) : base(numero, fecha, importe)
        {
            _sigla = "FC";
        }

        public override double Total()
        {
            return Importe * 1.21;
        }

        public override void Imprimir()
        {
            Console.WriteLine($"Imprimiento factura {Numero} del {Fecha} por un valor de {Importe}");
        }
    }
}
