using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Empresa.Models.Request
{
    public class EmpresaRequest
    {
        public string emp_tipid { get; set; }
        public string emp_numid { get; set; }
        public string emp_nom { get; set; }
        public string emp_dir { get; set; }
        public string emp_ciu { get; set; }
        public string emp_depto { get; set; }
        public string emp_tel { get; set; }
    }
}
