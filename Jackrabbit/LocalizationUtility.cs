// <copyright file="LocalizationUtility.cs" company="Engage Software">
// Engage: Jackrabbit
// Copyright (c) 2004-2016
// by Engage Software ( http://www.engagesoftware.com )
// </copyright>
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
namespace Engage.Dnn.Jackrabbit
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Web.Hosting;
    using System.Xml.Linq;

    using DotNetNuke.Common;
    using DotNetNuke.Services.Localization;

    /// <summary>Utility class for localization stuff</summary>
    public static class LocalizationUtility
    {
        /// <summary>Gets all resources.</summary>
        /// <param name="resourceFileRoot">The local resource file.</param>
        /// <returns>Dictionary containing all requested resource values</returns>
        public static Dictionary<string, string> GetAllResources(string resourceFileRoot)
        {
            var fileName = HostingEnvironment.MapPath(Globals.ApplicationPath + GetResourceFileName(resourceFileRoot));
            if (!File.Exists(fileName))
            {
                return new Dictionary<string, string>(0);
            }

            IEnumerable<string> keys;
            using (var resxStream = new FileStream(fileName, FileMode.Open, FileAccess.Read))
            {
                var doc = XDocument.Load(resxStream);
                if (doc.Root == null)
                {
                    return new Dictionary<string, string>(0);
                }

                keys = doc.Root
                          .Elements("data")
                          .Attributes("name")
                          .Select(a => a.Value)
                          .ToArray();
            }

            const string defaultSuffix = ".Text";
            var defaultKeys = from key in keys
                              where key.EndsWith(defaultSuffix, StringComparison.Ordinal)
                              select key.Substring(0, key.Length - defaultSuffix.Length);

            var allKeys = keys.Concat(defaultKeys);
            return allKeys.ToDictionary(key => key, key => Localization.GetString(key, resourceFileRoot));
        }

        /// <summary>Gets the name of the resource file.</summary>
        /// <param name="resourceFileRoot">The resource file root.</param>
        /// <returns>The resource file path</returns>
        /// <remarks>Based on <see href="https://github.com/dnnsoftware/Dnn.Platform/blob/34bfd5c9431bb340a62edf046d485fe30c200d03/DNN%20Platform/Library/Services/Localization/LocalizationProvider.cs#L380-L394"/></remarks>
        private static string GetResourceFileName(string resourceFileRoot)
        {
            switch (resourceFileRoot.Substring(resourceFileRoot.Length - 5, 5).ToUpperInvariant())
            {
                case ".RESX":
                    return resourceFileRoot;
                case ".ASCX":
                case ".ASPX":
                    return resourceFileRoot + ".resx";
                default:
                    return resourceFileRoot + ".ascx.resx"; //a portal module
            }
        }
    }
}
