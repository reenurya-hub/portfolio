#pragma checksum "C:\Users\User\source\repos\DependencyInjectionASPNet\FactoryMethodASPNet\Views\ProductDetail\Index.cshtml" "{ff1816ec-aa5e-4d10-87f7-6f4963833460}" "dd44c8fcfe182d82416e154698961a0b64aafbcf"
// <auto-generated/>
#pragma warning disable 1591
[assembly: global::Microsoft.AspNetCore.Razor.Hosting.RazorCompiledItemAttribute(typeof(AspNetCore.Views_ProductDetail_Index), @"mvc.1.0.view", @"/Views/ProductDetail/Index.cshtml")]
namespace AspNetCore
{
    #line hidden
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Mvc.Rendering;
    using Microsoft.AspNetCore.Mvc.ViewFeatures;
#nullable restore
#line 1 "C:\Users\User\source\repos\DependencyInjectionASPNet\FactoryMethodASPNet\Views\_ViewImports.cshtml"
using FactoryMethodASPNet;

#line default
#line hidden
#nullable disable
#nullable restore
#line 2 "C:\Users\User\source\repos\DependencyInjectionASPNet\FactoryMethodASPNet\Views\_ViewImports.cshtml"
using FactoryMethodASPNet.Models;

#line default
#line hidden
#nullable disable
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"dd44c8fcfe182d82416e154698961a0b64aafbcf", @"/Views/ProductDetail/Index.cshtml")]
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"40afdf153fc44dcb38b99c3693380ab3b2a5da83", @"/Views/_ViewImports.cshtml")]
    #nullable restore
    public class Views_ProductDetail_Index : global::Microsoft.AspNetCore.Mvc.Razor.RazorPage<dynamic>
    #nullable disable
    {
        #pragma warning disable 1998
        public async override global::System.Threading.Tasks.Task ExecuteAsync()
        {
#nullable restore
#line 1 "C:\Users\User\source\repos\DependencyInjectionASPNet\FactoryMethodASPNet\Views\ProductDetail\Index.cshtml"
  
    decimal totalLocal = (decimal)ViewBag.totalLocal;
    decimal totalForeign = (decimal)ViewBag.totalForeign;

#line default
#line hidden
#nullable disable
            WriteLiteral("\r\n<div class=\"row\">\r\n    <div class=\"col-12\">\r\n        <label>Total local</label>\r\n        <b>");
#nullable restore
#line 9 "C:\Users\User\source\repos\DependencyInjectionASPNet\FactoryMethodASPNet\Views\ProductDetail\Index.cshtml"
      Write(totalLocal);

#line default
#line hidden
#nullable disable
            WriteLiteral("</b></br>\r\n        <label>Total extranjero</label>\r\n        <b>");
#nullable restore
#line 11 "C:\Users\User\source\repos\DependencyInjectionASPNet\FactoryMethodASPNet\Views\ProductDetail\Index.cshtml"
      Write(totalForeign);

#line default
#line hidden
#nullable disable
            WriteLiteral("</b>\r\n\r\n    </div>\r\n\r\n</div>");
        }
        #pragma warning restore 1998
        #nullable restore
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.ViewFeatures.IModelExpressionProvider ModelExpressionProvider { get; private set; } = default!;
        #nullable disable
        #nullable restore
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IUrlHelper Url { get; private set; } = default!;
        #nullable disable
        #nullable restore
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IViewComponentHelper Component { get; private set; } = default!;
        #nullable disable
        #nullable restore
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IJsonHelper Json { get; private set; } = default!;
        #nullable disable
        #nullable restore
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IHtmlHelper<dynamic> Html { get; private set; } = default!;
        #nullable disable
    }
}
#pragma warning restore 1591
