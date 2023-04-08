using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_D
{
    public class Cobranza : IImprimible
    {
        public double Importe { get; set; }

        public int Numero { get; set; }
    
        public void Imprimir()
        {
            Console.WriteLine($"Imprimiento cobranza No. {Numero} con un importe de {Importe}");
        }
    }
}
