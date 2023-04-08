using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_D
{
    public class Municipal : Impuesto
    {
        public Municipal(double importe, string partida) : base(importe) 
        {
            Partida = partida;
        }
        public string Partida { get; set; }

        public override void Imprimir()
        {
            Console.WriteLine($"Imprimiento impuesto municipal de partida {Partida} por un valor de {Importe}");
        }
    }
}
