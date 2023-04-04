using Empresa.Models.Request;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using System.Windows.Forms;

namespace Empresa
{
    public partial class tbtipid : Form
    {
        public tbtipid()
        {
            InitializeComponent();
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void btnguardar_Click(object sender, EventArgs e)
        {
            string url = "https://localhost:44324/api/Empresa";

            EmpresaRequest oEmpresa = new EmpresaRequest();
            oEmpresa.emp_tipid = tbemptipid.Text;
            oEmpresa.emp_numid = tbnumid.Text;
            oEmpresa.emp_nom = tbnomemp.Text;
            oEmpresa.emp_dir = tbdiremp.Text;
            oEmpresa.emp_ciu = tbciuemp.Text;
            oEmpresa.emp_depto = tbdeptoemp.Text;
            oEmpresa.emp_tel = tbtelemp.Text;

           string resultado = Send<EmpresaRequest>(url, oEmpresa, "POST");

        }

        public string Send<T>(string url, T objectRequest, string method = "POST")
        {

            string result = "";

            try
            {
                
                JavaScriptSerializer js = new JavaScriptSerializer();

                //serializamos el objeto
                string json = Newtonsoft.Json.JsonConvert.SerializeObject(objectRequest);

                //peticion
                WebRequest request = WebRequest.Create(url);
                //headers
                request.Method = method;
                request.PreAuthenticate = true;
                request.ContentType = "application/json;charset=utf-8'";
                request.Timeout = 10000; //esto es opcional

                using (var streamWriter = new StreamWriter(request.GetRequestStream()))
                {
                    streamWriter.Write(json);
                    streamWriter.Flush();
                }

                var httpResponse = (HttpWebResponse)request.GetResponse();
                using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
                {
                    result = streamReader.ReadToEnd();
                }
                
            }
            catch (Exception e)
            {

                result = e.Message;

            }

            return result;
        }
    }
}
