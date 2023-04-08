using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID
{
    public class Factura
    {
        public Factura(int numero, Cliente cliente)
        {
            Numero = numero;
            //Apellido = apellido;
            //Nombre = nombre;
            Cliente = cliente;
            Items = new List<Item>();
        }
        public int Numero { get; set; }
        //public string Apellido { get; set; }
        //public string Nombre { get; set; }
        public Cliente Cliente { get; set; }
        public List<Item> Items { get; set; }

        public double Total()
        {
            double total = 0;
            foreach(var item in Items)
            {
                //total += item.Cantidad + item.Producto.Precio;
                total += item.Subtotal();
            }

            return total;
        }

    }
}
