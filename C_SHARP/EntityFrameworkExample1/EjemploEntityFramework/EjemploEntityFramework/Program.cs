using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EjemploEntityFramework
{
    internal class Program
    {
        static void Main(string[] args)
        {
            using(SampleEntityFramework db = new SampleEntityFramework())
            {
                var lst = db.gente;

                /*
                // Insertar registro
                gente oGente = new gente();
                oGente.nombre = "Reinaldo Urquijo";
                oGente.edad = 38;
                oGente.idSexo = 1;
                db.gente.Add(oGente);
                db.SaveChanges();
                */

                /*
                //Actualizar registro
                gente oGente = db.gente.Where(d => d.nombre == "ana gomez").First();
                oGente.edad = 30;
                db.Entry(oGente).State = System.Data.Entity.EntityState.Modified;
                db.SaveChanges();
                */

                /*
                //Eliminar registro (si el find no devuelve nulo)
                gente oGente = db.gente.Find(3);
                db.gente.Remove(oGente);
                db.SaveChanges();
                */

                foreach (var oGente_ in lst)
                {
                    Console.WriteLine(oGente_.nombre);
                }


            }


            Console.Read();
        }
    }
}
