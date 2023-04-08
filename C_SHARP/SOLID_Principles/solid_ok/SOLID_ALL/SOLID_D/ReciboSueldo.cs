using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_D
{
    public class ReciboSueldo : IImprimible
    {
        public ReciboSueldo(int legajo, double total)
        {
            Legajo = legajo;
            Total = total;
        }

        public double Total { get; set; }
        public int Legajo { get; set; }

        public void Imprimir()
        {
            Console.WriteLine($"Imprimiento recibo de sueldo del legajo {Legajo} por un valor de {Total}");
        }
    }
}
