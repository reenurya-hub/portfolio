using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_I
{
    public abstract class Documento : IImprimible
    {
        public Documento(int numero, DateTime fecha)
        {
           Numero = numero;
            Fecha = fecha;
        }

        public DateTime Fecha { get; set; }
        public int Numero { get; set; }
        public abstract void Imprimir();
        //public abstract void EnviarPorEmail();

        
       
    }
}
