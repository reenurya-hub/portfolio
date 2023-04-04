using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace WebApplication5.Controllers
{
    public class EmpresaController : ApiController
    {
        [HttpPost]
        public IHttpActionResult Add(Models.Request.EmpresaRequest model)
        {
            using (Models.factoEntities db = new Models.factoEntities())
            {
                var oEmpresa = new Models.empresa();
                oEmpresa.emp_tipid = model.emp_tipid;  //"NIT";
                oEmpresa.emp_numid = model.emp_numid;  //"899001002";
                oEmpresa.emp_nom = model.emp_nom;      // "Empresa de prueba 2";
                oEmpresa.emp_dir = model.emp_dir;      // "Calle las flores 172";
                oEmpresa.emp_ciu = model.emp_ciu;       //"Cali";
                oEmpresa.emp_depto = model.emp_depto;   //"Valle";
                oEmpresa.emp_tel = model.emp_tel;       // "3001002001";
                db.empresa.Add(oEmpresa);
                db.SaveChanges();
            }
            return Ok("Empresa ingresada con éxito");
        }
    }
}
