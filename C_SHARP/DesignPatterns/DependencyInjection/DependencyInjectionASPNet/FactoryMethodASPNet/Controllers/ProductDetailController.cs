using Microsoft.AspNetCore.Mvc;
using System.Xml.Schema;
using Tools.Earn;

namespace FactoryMethodASPNet.Controllers
{
    public class ProductDetailController : Controller
    {
        private EarnFactory _localEarnFactory;
        private ForeignEarnFactory _foreignEarnFactory;
        public ProductDetailController(LocalEarnFactory localEarnFactory,
            ForeignEarnFactory foreignEarnFactory)
        {
            _localEarnFactory = localEarnFactory;
            _foreignEarnFactory = foreignEarnFactory;
        }

        public IActionResult Index(decimal total)
        {
            //factories
            //ForeignEarnFactory foreignEarnFactory = new ForeignEarnFactory(0.30m, 20);

            //products
            var localEarn = _localEarnFactory.GetEarn();
            var foreignEarn = _foreignEarnFactory.GetEarn();

            // total
            ViewBag.totalLocal = total + localEarn.Earn(total);
            ViewBag.totalForeign = total + foreignEarn.Earn(total);

            return View();
        }
    }
}
