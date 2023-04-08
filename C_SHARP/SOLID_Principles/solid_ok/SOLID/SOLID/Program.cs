using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOLID
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Cliente c  = new Cliente();
            c.Apellido = "Urquijo";
            c.Nombre   = "Reinaldo";

            Factura f = new Factura(21332, c);

            Item i1 = new Item(new Producto("Cafe", 5500),1);
            Item i2 = new Item(new Producto("Queso", 9550), 1);
            Item i3 = new Item(new Producto("Pan", 500), 4);

            f.Items.Add(i1);
            f.Items.Add(i2);
            f.Items.Add(i3);


            Console.WriteLine("Factura No         : {0}", f.Numero);
            Console.WriteLine("Nombre cliente     : {0} {1}", f.Cliente.Nombre, f.Cliente.Apellido);
            Console.WriteLine("Total de la factura: {0}", f.Total());
            Console.ReadKey();
        }
    }
}
