// <copyright file="FileController.cs" company="Engage Software">
// Engage: Jackrabbit
// Copyright (c) 2004-2016
// by Engage Software ( http://www.engagesoftware.com )
// </copyright>
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
namespace Engage.Dnn.Jackrabbit.Api
{
    using System;
    using System.Net;
    using System.Net.Http;
    using System.Web.Http;

    using DotNetNuke.Security;
    using DotNetNuke.Services.Exceptions;
    using DotNetNuke.Services.Localization;
    using DotNetNuke.Web.Api;

    /// <summary>Web API for Jackrabbit files</summary>
    /// <seealso cref="DotNetNuke.Web.Api.DnnApiController" />
    [DnnModuleAuthorize(AccessLevel = SecurityAccessLevel.Edit)]
    [SupportedModules("Engage: Jackrabbit")]
    public class FileController : DnnApiController
    {
        /// <summary>The data repository</summary>
        private readonly IRepository repository;

        /// <summary>Initializes a new instance of the <see cref="FileController"/> class.</summary>
        public FileController()
            : this(new ContentItemRepository())
        {
        }

        /// <summary>Initializes a new instance of the <see cref="FileController" /> class.</summary>
        /// <param name="repository">The repository.</param>
        internal FileController(IRepository repository)
        {
            this.repository = repository;
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public HttpResponseMessage PostFile(PostFileRequest request)
        {
            try
            {
                this.repository.AddFile(this.ActiveModule.ModuleID, new JackrabbitFile(request.FileType, request.PathPrefixName, request.FilePath, request.Provider, request.Priority));
                return this.Request.CreateResponse(HttpStatusCode.OK, this.repository.GetFiles(this.ActiveModule.ModuleID));
            }
            catch (Exception exc)
            {
                return this.HandleException(exc);
            }
        }

        [HttpPut]
        [ValidateAntiForgeryToken]
        public HttpResponseMessage PutFile(int id, PutFileRequest request)
        {
            try
            {
                this.repository.UpdateFile(new JackrabbitFile(request.FileType, id, request.PathPrefixName, request.FilePath, request.Provider, request.Priority));
                return this.Request.CreateResponse(HttpStatusCode.OK, this.repository.GetFiles(this.ActiveModule.ModuleID));
            }
            catch (Exception exc)
            {
                return this.HandleException(exc);
            }
        }

        [HttpDelete]
        [ValidateAntiForgeryToken]
        public HttpResponseMessage DeleteFile(int id)
        {
            try
            {
                this.repository.DeleteFile(id);
                return this.Request.CreateResponse(HttpStatusCode.OK, this.repository.GetFiles(this.ActiveModule.ModuleID));
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
                new
                {
                    errorMessage = LocalizeString("Unexpected Error"),
                    exception = this.CreateExceptionResponse(exc),
                });
        }

        private object CreateExceptionResponse(Exception exc)
        {
            if (exc == null || !this.UserInfo.IsSuperUser)
            {
                return null;
            }

            return new
                   {
                        message = exc.Message,
                        stackTrace = exc.StackTrace,
                        innerException = this.CreateExceptionResponse(exc.InnerException),
                   };
        }

        private static string LocalizeString(string key)
        {
            return Localization.GetString(key, "~/DesktopModules/Engage/Jackrabbit/API/App_LocalResources/SharedResources");
        }
    }
}
