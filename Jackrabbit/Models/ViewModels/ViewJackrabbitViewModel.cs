// <copyright file="ViewJackrabbitViewModel.cs" company="Engage Software">
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
    using System.Diagnostics.CodeAnalysis;

    using DotNetNuke.Framework.JavaScriptLibraries;

    /// <summary>The view model for the Jackrabbit, to be displayed by <see cref="IViewJackrabbitView"/></summary>
    public class ViewJackrabbitViewModel
    {
        /// <summary>Gets or sets a value indicating whether module's container should be hidden (i.e. if the module should not have any display).</summary>
        public bool HideContainer { get; set; }

        /// <summary>Gets or sets a value indicating whether the view of the module should display or not (but the container might still display, to let editors know it's there).</summary>
        public bool HideView { get; set; }

        /// <summary>Gets or sets the files being included by this module.</summary>
        public IEnumerable<FileViewModel> Files { get; set; }

        public IEnumerable<LibraryViewModel> Libraries { get; set; }

        /// <summary>Gets or sets the default path prefix.</summary>
        public string DefaultPathPrefix { get; set; }

        /// <summary>Gets or sets the default file path.</summary>
        public string DefaultFilePath { get; set; }

        /// <summary>Gets or sets the default provider.</summary>
        public string DefaultProvider { get; set; }

        /// <summary>Gets or sets the default priority.</summary>
        public int DefaultPriority { get; set; }

        /// <summary>Represents a file included by this module</summary>
        [SuppressMessage("Microsoft.Design", "CA1034:NestedTypesShouldNotBeVisible", Justification = "I'm cool with nested classes in view models")]
        public class FileViewModel
        {
            /// <summary>Initializes a new instance of the <see cref="FileViewModel" /> class.</summary>
            /// <param name="fileType">Type of the file.</param>
            /// <param name="id">The ID of the file.</param>
            /// <param name="pathPrefixName">Name of the path prefix.</param>
            /// <param name="filePath">The file path.</param>
            /// <param name="fullFilePath">The file path combined with the prefix.</param>
            /// <param name="provider">The provider.</param>
            /// <param name="priority">The priority.</param>
            public FileViewModel(FileType fileType, int id, string pathPrefixName, string filePath, string fullFilePath, string provider, int priority)
            {
                this.FileType = fileType;
                this.Id = id;
                this.PathPrefixName = pathPrefixName;
                this.FilePath = filePath;
                this.FullFilePath = fullFilePath;
                this.Provider = provider;
                this.Priority = priority;
            }

            /// <summary>Gets the type of the file.</summary>
            public FileType FileType { get; }

            /// <summary>Gets the ID of the file.</summary>
            public int Id { get; }

            /// <summary>Gets the name of the path prefix.</summary>
            public string PathPrefixName { get; }

            /// <summary>Gets the file path.</summary>
            public string FilePath { get; }

            /// <summary>Gets the file path combined with the prefix.</summary>
            public string FullFilePath { get; }

            /// <summary>Gets the provider.</summary>
            public string Provider { get; }

            /// <summary>Gets the priority.</summary>
            public int Priority { get; }
        }

        public class LibraryViewModel
        {
            /// <summary>Initializes a new instance of the <see cref="LibraryViewModel" /> class.</summary>
            /// <param name="fileType">Type of the file.</param>
            /// <param name="id">The ID of the file.</param>
            /// <param name="pathPrefixName">Name of the path prefix.</param>
            /// <param name="filePath">The file path.</param>
            /// <param name="fullFilePath">The file path combined with the prefix.</param>
            /// <param name="provider">The provider.</param>
            /// <param name="priority">The priority.</param>
            public LibraryViewModel(FileType fileType, int id, string pathPrefixName, string filePath, string fullFilePath, string provider, int priority, string libraryName, string version, SpecificVersion versionSpecificity)
            {
                this.FileType = fileType;
                this.Id = id;
                this.PathPrefixName = pathPrefixName;
                this.FilePath = filePath;
                this.FullFilePath = fullFilePath;
                this.Provider = provider;
                this.Priority = priority;
                this.LibraryName = libraryName;
                this.Version = version;
                this.VersionSpecificity = versionSpecificity;
            }

            /// <summary>Gets the type of the file.</summary>
            public FileType FileType { get; }

            /// <summary>Gets the ID of the file.</summary>
            public int Id { get; }

            /// <summary>Gets the name of the path prefix.</summary>
            public string PathPrefixName { get; }

            /// <summary>Gets the file path.</summary>
            public string FilePath { get; }

            /// <summary>Gets the file path combined with the prefix.</summary>
            public string FullFilePath { get; }

            /// <summary>Gets the provider.</summary>
            public string Provider { get; }

            /// <summary>Gets the priority.</summary>
            public int Priority { get; }

            public string LibraryName { get; }

            public string Version { get; }

            public SpecificVersion VersionSpecificity { get; }
        }
    }
}