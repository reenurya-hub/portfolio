//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace EjemploEntityFramework
{
    using System;
    using System.Collections.Generic;
    
    public partial class gente
    {
        public int id { get; set; }
        public string nombre { get; set; }
        public Nullable<byte> edad { get; set; }
        public Nullable<int> idSexo { get; set; }
    
        public virtual sexo sexo { get; set; }
    }
}
