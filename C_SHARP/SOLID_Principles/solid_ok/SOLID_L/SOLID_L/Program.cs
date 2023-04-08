using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_L
{
    public class Program
    {
        static void Main(string[] args)
        {
            Impresora impresora = new Impresora();

            Remito rto = new Remito(3331, DateTime.Now, 10);
            Factura fc = new Factura(66423, DateTime.Now);
            NotaCredito nc = new NotaCredito(441, DateTime.Now);
            NotaDebito nd = new NotaDebito(456, DateTime.Now);

            impresora.ImprimirRemito(rto);
            impresora.Imprimir(fc);
            impresora.Imprimir(nc);
            impresora.Imprimir(nd);

            Console.ReadLine();

        }
    }
}
