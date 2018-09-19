using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Calendar.Util.RNCalendarUtil
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNCalendarUtilModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNCalendarUtilModule"/>.
        /// </summary>
        internal RNCalendarUtilModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNCalendarUtil";
            }
        }
    }
}
