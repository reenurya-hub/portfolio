﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID_OCP
{
    public abstract class DocumentoContable
    {

        public DocumentoContable(/*TipoDocumentoContable tipo,*/ int numero)
        {
            //Tipo = tipo;
            Numero = numero;
        }

        public DateTime Fecha { get; set; }
        public double Importe { get; set; }
        public int Numero { get; set; }
        //public TipoDocumentoContable Tipo { get; set; }

        public abstract string Descripcion();

        /*
        public string Descripcion()
        {

            
            switch (Tipo)
            {
                case TipoDocumentoContable.Factura:
                    return $"FC-{Numero}";
                case TipoDocumentoContable.NotaCredito:
                    return $"NC-{Numero}";
                default:
                    return "N/D";
            }

        }*/

    }
}
