// <copyright file="JackrabbitFile.cs" company="Engage Software">
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

    using DotNetNuke.Framework.JavaScriptLibraries;

    public class JackrabbitLibrary
    {
        /// <summary>Initializes a new instance of the <see cref="JackrabbitLibrary" /> class.</summary>
        /// <param name="fileType">The type of file</param>
        /// <param name="libraryName">The name of the library.</param>
        /// <param name="version">The version.</param>
        /// <param name="specificity">The version specificity.</param>
        public JackrabbitLibrary(FileType fileType, string libraryName, Version version, SpecificVersion specificity)
        {
            this.FileType = fileType;
            this.LibraryName = libraryName;
            this.Version = version;
            this.Specificity = specificity;
        }

        /// <summary>Initializes a new instance of the <see cref="JackrabbitLibrary" /> class.</summary>
        /// <param name="fileType">Type of the file.</param>
        /// <param name="id">The identifier.</param>
        /// <param name="libraryName">The name of the library.</param>
        /// <param name="version">The version.</param>
        /// <param name="specificity">The version specificity.</param>
        public JackrabbitLibrary(FileType fileType, int id, string libraryName, Version version, SpecificVersion specificity)
            : this(fileType, libraryName, version, specificity)
        {
            this.Id = id;
        }

        /// <summary>Gets the type of the file.</summary>
        public FileType FileType { get; }

        /// <summary>Gets the ID of the file.</summary>
        public int Id { get; }

        /// <summary>Gets the Library Name</summary>
        public string LibraryName { get; }

        ///<summary>Gets the version</summary>
        public Version Version { get; }

        ///<summary>Gets the version specificity</summary>
        public SpecificVersion Specificity { get; }

    }
}