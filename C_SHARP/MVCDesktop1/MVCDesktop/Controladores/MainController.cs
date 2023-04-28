using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;

namespace Controladores
{
    public class MainController
    {
            public IEnumerable<Modelos.UserViewModel> GetList()
            {
                using (Modelos.EF.pruebaEntities db = new Modelos.EF.pruebaEntities())
                {
                    IEnumerable<Modelos.UserViewModel> lst = (from d in db.user
                                                                select new Modelos.UserViewModel
                                                                {
                                                                    Id = d.id,
                                                                    Email = d.email
                                                                }).ToList();
                return lst;
                }
            }
    }
}
