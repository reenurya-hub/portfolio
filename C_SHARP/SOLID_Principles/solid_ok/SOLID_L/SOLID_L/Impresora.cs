using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_L
{
    public class Impresora
    {
        public void ImprimirRemito(Remito unRemito)
        {
            Console.WriteLine(unRemito.Imprimir());
        }

        public void Imprimir(Documento unaFactura)
        {
            Console.WriteLine(unaFactura.Imprimir());
        }

    }
}
