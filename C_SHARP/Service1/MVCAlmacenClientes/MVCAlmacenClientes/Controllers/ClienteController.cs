using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace MVCAlmacenClientes.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ClienteController : ControllerBase
    {
        [HttpGet]
        public IActionResult Get([FromBody] List<string> Ids)
        {
            using (var db = new Models.Almacen1Context())
            {
                var lst = from d in db.Clientes1s.ToList()
                          where Ids.Contains(d.CliId)
                          select d;

                return Ok(lst);
            }
        }
    }
}
