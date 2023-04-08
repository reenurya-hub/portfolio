using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_D
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Impresora imprime = new Impresora();
            IImprimible fac = new Factura(32564, DateTime.Now, 5000);
            imprime.Imprimir(fac);

            IImprimible facluz = new FacturaLuz(3400, "FL-56789");
            imprime.Imprimir(facluz);

            IImprimible munip = new Municipal(4000, "PA-525678");
            imprime.Imprimir(munip);

            IImprimible recsue = new ReciboSueldo(3245, 5500);
            imprime.Imprimir(recsue);

            IImprimible rem = new Remito(32455, Convert.ToDateTime("2023-04-08"), 32);
            imprime.Imprimir(rem);

            Cobranza cob = new Cobranza()
            {
                Numero = 4441,
                Importe = 1343
            };
            imprime.Imprimir(cob);

            Console.ReadLine();
        }
    }
}