using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Engage.Dnn.Jackrabbit.API
{
    using System.Net;
    using System.Net.Http;
    using System.Web.Http;

    using DotNetNuke.Framework.JavaScriptLibraries;
    using DotNetNuke.Services.Exceptions;
    using DotNetNuke.Services.Localization;
    using DotNetNuke.Web.Api;

    [AllowAnonymous]
    public class SearchController : DnnApiController
    {
        public HttpResponseMessage GetLibraries(PostFileRequest request)
        {
            try
            {
                var libraries = JavaScriptLibraryController.Instance.GetLibraries();
                return this.Request.CreateResponse(HttpStatusCode.OK, from library in libraries
                                                                      select new
                                                                             {
                                                                                 library.LibraryName,
                                                                                 Version = library.Version.ToString(),
                                                                             });
            }
            catch (Exception exc)
            {
                return this.HandleException(exc);
            }
        }

        private HttpResponseMessage HandleException(Exception exc)
        {
            Exceptions.LogException(exc);
            return this.Request.CreateResponse(
                           HttpStatusCode.InternalServerError,
                           new { errorMessage = LocalizeString("Unexpected Error"), exception = this.CreateExceptionResponse(exc), });
        }

        private static string LocalizeString(string key)
        {
            return Localization.GetString(key, "~/DesktopModules/Engage/Jackrabbit/API/App_LocalResources/SharedResources");
        }

        private object CreateExceptionResponse(Exception exc)
        {
            if (exc == null || !this.UserInfo.IsSuperUser)
            {
                return null;
            }

            return new { message = exc.Message, stackTrace = exc.StackTrace, innerException = this.CreateExceptionResponse(exc.InnerException), };
        }
    }
}