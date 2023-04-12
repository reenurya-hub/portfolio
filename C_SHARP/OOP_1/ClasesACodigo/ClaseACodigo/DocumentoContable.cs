using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClaseACodigo
{
    public abstract class DocumentoContable
    {
        protected string _siglas;
        public DateTime Fecha { get; set; }
        public int Numero { get; set; }

        public double Importe { get; set; }

        public string Siglas { get { return _siglas; } }

        public abstract double Total();

    }
}
