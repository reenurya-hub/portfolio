using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_D
{
    public class NotaCredito : DocumentoContable
    {
        public NotaCredito(int numero, DateTime fecha, double importe) : base(numero, fecha, importe)
        {
            _sigla = "NC";
        }

        public override double Total()
        {
            return Importe = 1.21 * -1; //Ejemplo
        }

        public override void Imprimir()
        {
            Console.WriteLine($"Imprimiento Nota de Crédito {Numero} del {Fecha} por un valor de {Importe}");
        }


    }
}
