using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_L
{
    public class NotaCredito : Documento
    {
        public NotaCredito(int numero, DateTime fecha): base(numero, fecha)
        {
            _sigla = "NC";
        }
    }
}
