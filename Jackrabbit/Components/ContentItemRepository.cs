// <copyright file="ContentItemRepository.cs" company="Engage Software">
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
    using System.Globalization;
    using System.Linq;

    using DotNetNuke.Common;
    using DotNetNuke.Entities.Content;
    using DotNetNuke.Entities.Controllers;
    using DotNetNuke.Entities.Host;
    using DotNetNuke.Framework.JavaScriptLibraries;
    using DotNetNuke.Web.Client;

    /// <summary>A repository backed by the DNN content item store</summary>
    public class ContentItemRepository : IRepository
    {
        /// <summary>The name of the Jackrabbit file content type</summary>
        private const string JackrabbitFileContentTypeName = FeaturesController.SettingsPrefix + "_Script";

        private static readonly Dictionary<ScriptLocation, string> ScriptLocationToProviderName = new Dictionary<ScriptLocation, string>(3)
                                                                                                  {
                                                                                                      { ScriptLocation.PageHead, "DnnPageHeaderProvider" },
                                                                                                      { ScriptLocation.BodyTop, "DnnBodyProvider" },
                                                                                                      { ScriptLocation.BodyBottom, "DnnFormBottomProvider" },
                                                                                                  };

        /// <summary>The content type controller</summary>
        private readonly IContentTypeController contentTypeController = new ContentTypeController();

        /// <summary>The content controller</summary>
        private readonly IContentController contentController = new ContentController();

        /// <summary>Backing field for <see cref="JackrabbitFileContentType"/></summary>
        private readonly Lazy<ContentType> jackrabbitFileContentType;

        /// <summary>Initializes a new instance of the <see cref="ContentItemRepository"/> class.</summary>
        public ContentItemRepository()
        {
            this.jackrabbitFileContentType = new Lazy<ContentType>(this.InitializeContentType);
        }

        /// <summary>Gets the content type for jackrabbit files.</summary>
        private ContentType JackrabbitFileContentType
        {
            get
            {
                return this.jackrabbitFileContentType.Value;
            }
        }

        /// <summary>Gets the files.</summary>
        /// <param name="moduleId">The module ID.</param>
        /// <returns>A sequence of <see cref="JackrabbitFile"/> instances.</returns>
        public IEnumerable<JackrabbitFile> GetFiles(int moduleId)
        {
            return from ci in this.contentController.GetContentItemsByModuleId(moduleId)
                   where ci.ContentTypeId == this.JackrabbitFileContentType.ContentTypeId
                   select
                       new JackrabbitFile(
                           ci.Metadata["FileType"].ParseNullableEnum<FileType>() ?? FileType.JavaScriptFile,
                           ci.ContentItemId,
                           ci.Metadata["PathPrefixName"],
                           ci.Content,
                           ci.Metadata["Provider"],
                           ci.Metadata["Priority"].ParseNullableInt32());
        }

        public IEnumerable<JackrabbitLibrary> GetLibraries(int moduleId)
        {
            return from ci in this.contentController.GetContentItemsByModuleId(moduleId)
                   where ci.ContentTypeId == this.JackrabbitFileContentType.ContentTypeId
                   select
                   new JackrabbitLibrary(
                       ci.Metadata["FileType"].ParseNullableEnum<FileType>() ?? FileType.JavaScriptLib,
                       ci.ContentItemId,
                       ci.Metadata["LibraryName"],
                       Version.Parse(ci.Metadata["Version"]),
                       ci.Metadata["VersionSpecificity"].ParseNullableEnum<SpecificVersion>() ?? SpecificVersion.Latest);
        }

        /// <summary>Adds the file.</summary>
        /// <param name="moduleId">The module ID.</param>
        /// <param name="file">The file.</param>
        public void AddFile(int moduleId, JackrabbitFile file)
        {
            var contentItem = new ContentItem { ContentTypeId = this.JackrabbitFileContentType.ContentTypeId, ModuleID = moduleId, };
            FillContentItem(file, contentItem);
            this.contentController.AddContentItem(contentItem);
        }

        public void AddLibrary(int moduleId, JackrabbitLibrary library)
        {
            var contentItem = new ContentItem() { ContentTypeId = this.JackrabbitFileContentType.ContentTypeId, ModuleID = moduleId, };
            FillContentItem(library, contentItem);
            this.contentController.AddContentItem(contentItem);
        }

        /// <summary>Updates the file.</summary>
        /// <param name="file">The file.</param>
        public void UpdateFile(JackrabbitFile file)
        {
            var contentItem = this.contentController.GetContentItem(file.Id);
            if (contentItem == null)
            {
                return;
            }

            FillContentItem(file, contentItem);
            this.contentController.UpdateContentItem(contentItem);
        }

        public void UpdateLibrary(JackrabbitLibrary library)
        {
            var contentItem = this.contentController.GetContentItem(library.Id);
            if (contentItem == null)
            {
                return;
            }
            FillContentItem(library, contentItem);
            this.contentController.UpdateContentItem(contentItem);
        }

        /// <summary>Deletes the file.</summary>
        /// <param name="fileId">The file's ID.</param>
        public void DeleteItem(int fileId)
        {
            this.contentController.DeleteContentItem(fileId);
        }

        public JackrabbitLibraryInfo GetLibraryInfo(JackrabbitLibrary library)
        {
            var libraries = from l in JavaScriptLibraryController.Instance.GetLibraries()
                            where l.LibraryName.Equals(library.LibraryName, StringComparison.OrdinalIgnoreCase)
                            where l.Version >= library.Version
                            where library.VersionSpecificity == SpecificVersion.Latest
                            || (library.VersionSpecificity == SpecificVersion.LatestMajor && l.Version.Major == library.Version.Major)
                            || (library.VersionSpecificity == SpecificVersion.LatestMinor && l.Version.Major == library.Version.Major && l.Version.Minor == library.Version.Minor)
                            || ((int)library.VersionSpecificity == 3 && l.Version == library.Version)
                            orderby l.Version descending 
                            select l;

            var matchingLibrary = libraries.FirstOrDefault();
            if (matchingLibrary == null)
            {
                return JackrabbitLibraryInfo.Null;
            }

            var path = GetLibraryPath(matchingLibrary);
            var provider = ScriptLocationToProviderName[matchingLibrary.PreferredScriptLocation];
            var priority = matchingLibrary.PackageID + (int)FileOrder.Js.DefaultPriority;

            return new JackrabbitLibraryInfo(path, provider, priority);
        }

        private static string GetLibraryPath(JavaScriptLibrary library)
        {
            if (Host.CdnEnabled)
            {
                var customUrl = HostController.Instance.GetString("CustomCDN_" + library.LibraryName);
                if (!string.IsNullOrEmpty(customUrl))
                {
                    return customUrl;
                }

                if (!string.IsNullOrEmpty(library.CDNPath))
                {
                    return library.CDNPath;
                }
            }

            var versionFolderName = Globals.FormatVersion(library.Version, "00", 3, "_");
            return $"~/Resources/libraries/{library.LibraryName}/{versionFolderName}/{library.FileName}";
        }

        /// <summary>Fills the <paramref name="contentItem"/> with the properties from the <paramref name="file"/>.</summary>
        /// <param name="file">The file.</param>
        /// <param name="contentItem">The content item.</param>
        private static void FillContentItem(JackrabbitFile file, ContentItem contentItem)
        {
            contentItem.Content = file.FilePath;
            contentItem.Metadata["FileType"] = file.FileType.ToString();
            contentItem.Metadata["PathPrefixName"] = file.PathPrefixName;
            contentItem.Metadata["Provider"] = file.Provider;
            contentItem.Metadata["Priority"] = file.Priority.ToString(CultureInfo.InvariantCulture);
        }

        private static void FillContentItem(JackrabbitLibrary library, ContentItem contentItem)
        {
            
            contentItem.Metadata["FileType"] = library.FileType.ToString();
            contentItem.Metadata["LibraryName"] = library.LibraryName;
            contentItem.Metadata["Version"] = library.Version.ToString();
            contentItem.Metadata["VersionSpecificity"] = library.VersionSpecificity.ToString();
        }

        /// <summary>Initializes the content type.</summary>
        /// <returns>A <see cref="ContentType"/> instance.</returns>
        private ContentType InitializeContentType()
        {
            var contentType = this.contentTypeController.GetContentTypes().SingleOrDefault(ct => ct.ContentType == JackrabbitFileContentTypeName);
            if (contentType == null)
            {
                var typeId = this.contentTypeController.AddContentType(new ContentType(JackrabbitFileContentTypeName));
                contentType = this.contentTypeController.GetContentTypes().Single(ct => ct.ContentTypeId == typeId);
            }

            return contentType;
        }
    }
}