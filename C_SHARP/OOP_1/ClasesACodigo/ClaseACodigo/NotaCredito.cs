using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClaseACodigo
{
    public class NotaCredito : DocumentoContable
    { 
        public NotaCredito()
        {
            _siglas = "NC-A";
        }
        //public string Siglas { get; }
        public override double Total()
        {
            return Importe * 1.21 * -1;
        }
    }
}
