using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Tools.Earn
{
    public abstract class EarnFactory
    {
        public abstract IEarn GetEarn();
    }
}
