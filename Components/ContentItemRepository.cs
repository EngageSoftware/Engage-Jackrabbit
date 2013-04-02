// <copyright file="ContentItemRepository.cs" company="Engage Software">
// Engage: Jackrabbit
// Copyright (c) 2004-2013
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

    using DotNetNuke.Entities.Content;

    /// <summary>A repository backed by the DNN content item store</summary>
    public class ContentItemRepository : IRepository
    {
        /// <summary>The name of the Jackrabbit Script content type</summary>
        private const string JackrabbitScriptContentTypeName = FeaturesController.SettingsPrefix + "_Script";

        /// <summary>The content type controller</summary>
        private readonly IContentTypeController contentTypeController = new ContentTypeController();

        /// <summary>The content controller</summary>
        private readonly IContentController contentController = new ContentController();

        /// <summary>Backing field for <see cref="JackrabbitScriptContentType"/></summary>
        private readonly Lazy<ContentType> jackrabbitScriptContentType;

        /// <summary>Initializes a new instance of the <see cref="ContentItemRepository"/> class.</summary>
        public ContentItemRepository()
        {
            this.jackrabbitScriptContentType = new Lazy<ContentType>(this.InitializeContentType);
        }

        /// <summary>Gets the content type for jackrabbit scripts.</summary>
        private ContentType JackrabbitScriptContentType
        {
            get { return this.jackrabbitScriptContentType.Value; }
        }

        /// <summary>Gets the scripts.</summary>
        /// <param name="moduleId">The module ID.</param>
        /// <returns>A sequence of <see cref="JackrabbitScript"/> instances.</returns>
        public IEnumerable<JackrabbitScript> GetScripts(int moduleId)
        {
            return from ci in this.contentController.GetContentItemsByModuleId(moduleId)
                   where ci.ContentTypeId == this.JackrabbitScriptContentType.ContentTypeId
                   select
                       new JackrabbitScript(
                       ci.ContentItemId,
                       ci.Metadata["PathPrefixName"],
                       ci.Content,
                       ci.Metadata["Provider"],
                       ci.Metadata["Priority"].ParseNullableInt32());
        }

        /// <summary>Adds the script.</summary>
        /// <param name="moduleId">The module ID.</param>
        /// <param name="script">The script.</param>
        public void AddScript(int moduleId, JackrabbitScript script)
        {
            var contentItem = new ContentItem { ContentTypeId = this.JackrabbitScriptContentType.ContentTypeId, ModuleID = moduleId, };
            FillContentItem(script, contentItem);
            this.contentController.AddContentItem(contentItem);
        }

        /// <summary>Updates the script.</summary>
        /// <param name="script">The script.</param>
        public void UpdateScript(JackrabbitScript script)
        {
            var contentItem = this.contentController.GetContentItem(script.Id);
            if (contentItem == null)
            {
                return;
            }

            FillContentItem(script, contentItem);
            this.contentController.UpdateContentItem(contentItem);
        }

        /// <summary>Deletes the script.</summary>
        /// <param name="scriptId">The script's ID.</param>
        public void DeleteScript(int scriptId)
        {
            this.contentController.DeleteContentItem(scriptId);
        }

        /// <summary>Fills the <paramref name="contentItem"/> with the properties from the <paramref name="script"/>.</summary>
        /// <param name="script">The script.</param>
        /// <param name="contentItem">The content item.</param>
        private static void FillContentItem(JackrabbitScript script, ContentItem contentItem)
        {
            contentItem.Content = script.ScriptPath;
            contentItem.Metadata["PathPrefixName"] = script.PathPrefixName;
            contentItem.Metadata["Provider"] = script.Provider;
            contentItem.Metadata["Priority"] = script.Priority.ToString(CultureInfo.InvariantCulture);
        }

        /// <summary>Initializes the content type.</summary>
        /// <returns>A <see cref="ContentType"/> instance.</returns>
        private ContentType InitializeContentType()
        {
            var contentType = this.contentTypeController.GetContentTypes().SingleOrDefault(ct => ct.ContentType == JackrabbitScriptContentTypeName);
            if (contentType == null)
            {
                var typeId = this.contentTypeController.AddContentType(new ContentType(JackrabbitScriptContentTypeName));
                contentType = this.contentTypeController.GetContentTypes().Single(ct => ct.ContentTypeId == typeId);
            }

            return contentType;
        }
    }
}