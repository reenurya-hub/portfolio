using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClaseACodigo
{
    public class Factura : DocumentoContable
    {
        public Factura()
        {
            _siglas = "FC-A";
        }
        //public DateTime Fecha { get; set; }
        //public double Importe { get; set; }
        //public string Siglas { get; }
        public override double Total()
        {
            return Importe * 1.21;
        }
    }
}
