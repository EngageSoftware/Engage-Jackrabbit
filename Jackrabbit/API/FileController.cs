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
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Net;
    using System.Net.Http;
    using System.Web.Hosting;
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
        [ActionName("default")]
        [ValidateAntiForgeryToken]
        public HttpResponseMessage PostFile(PostFileRequest request)
        {
            try
            {
                if (request.FileType == FileType.JavaScriptLib)
                {
                    var library = new JackrabbitLibrary(request.FileType, request.LibraryName, Version.Parse(request.Version), request.Specificity);
                    this.repository.AddLibrary(this.ActiveModule.ModuleID, library);

                    var libraryPath = this.repository.GetLibraryInfo(library).LocalFilePath;

                    return this.Request.CreateResponse(
                                   HttpStatusCode.OK,
                                   new { items = this.GetAllItems(this.ActiveModule.ModuleID), suggestions = FindCssFiles(libraryPath), });
                }
                else
                {
                    this.repository.AddFile(
                            this.ActiveModule.ModuleID,
                            new JackrabbitFile(request.FileType, request.PathPrefixName, request.FilePath, request.Provider, request.Priority));
                    return this.Request.CreateResponse(HttpStatusCode.OK, new { items = this.GetAllItems(this.ActiveModule.ModuleID) });
                }
            }
            catch (Exception exc)
            {
                return this.HandleException(exc);
            }
        }

        [HttpPut]
        [ActionName("default")]
        [ValidateAntiForgeryToken]
        public HttpResponseMessage PutFile(int id, PutFileRequest request)
        {
            try
            {
                if (request.FileType == FileType.JavaScriptLib)
                {
                    this.repository.UpdateLibrary(
                            new JackrabbitLibrary(request.FileType, request.LibraryName, request.Version, request.Specificity));
                    return this.Request.CreateResponse(HttpStatusCode.OK, new { items = this.GetAllItems(this.ActiveModule.ModuleID), });
                }
                else
                {
                    this.repository.UpdateFile(
                            new JackrabbitFile(request.FileType, id, request.PathPrefixName, request.FilePath, request.Provider, request.Priority));
                    return this.Request.CreateResponse(HttpStatusCode.OK, new { items = this.GetAllItems(this.ActiveModule.ModuleID), });
                }
            }
            catch (Exception exc)
            {
                return this.HandleException(exc);
            }
        }

        [HttpDelete]
        [ActionName("default")]
        [ValidateAntiForgeryToken]
        public HttpResponseMessage DeleteItem(int id)
        {
            try
            {
                this.repository.DeleteItem(id);
                return this.Request.CreateResponse(HttpStatusCode.OK, new { items = this.GetAllItems(this.ActiveModule.ModuleID), });
            }
            catch (Exception exc)
            {
                return this.HandleException(exc);
            }
        }

        [HttpPut]
        [ValidateAntiForgeryToken]
        public HttpResponseMessage UndeleteItem(int id)
        {
            try
            {
                this.repository.UndeleteItem(id);
                return this.Request.CreateResponse(HttpStatusCode.OK, new { items = this.GetAllItems(this.ActiveModule.ModuleID), });
            }
            catch (Exception exc)
            {
                return this.HandleException(exc);
            }
        }

        private static IEnumerable<string> FindCssFiles(string filePath)
        {
            var physicalFilePath = HostingEnvironment.MapPath(filePath);
            var physicalLibraryPath = Path.GetDirectoryName(physicalFilePath);
            var libraryDirectory = new DirectoryInfo(physicalLibraryPath);
            return from file in libraryDirectory.EnumerateFiles("*.css", SearchOption.AllDirectories) select file.FullName;
        }

        private static string LocalizeString(string key)
        {
            return Localization.GetString(key, "~/DesktopModules/Engage/Jackrabbit/API/App_LocalResources/SharedResources");
        }

        private IEnumerable<object> GetAllItems(int moduleId)
        {
            return this.repository.GetFiles(moduleId)
                       .Cast<object>()
                       .Concat(from library in this.repository.GetLibraries(moduleId)
                               let libraryInfo = this.repository.GetLibraryInfo(library)
                               select new
                                      {
                                          library.Id,
                                          library.FileType,
                                          library.LibraryName,
                                          Version = library.Version.ToString(),
                                          library.Specificity,
                                          PathPrefixName = "JS Library",
                                          libraryInfo.FilePath,
                                          libraryInfo.Provider,
                                          libraryInfo.Priority,
                                      });
        }

        private HttpResponseMessage HandleException(Exception exc)
        {
            Exceptions.LogException(exc);
            var errorResponse = new
                                {
                                    errorMessage = LocalizeString("Unexpected Error"),
                                    exception = this.CreateExceptionResponse(exc),
                                };
            return this.Request.CreateResponse(HttpStatusCode.InternalServerError, errorResponse);
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
    }
}
