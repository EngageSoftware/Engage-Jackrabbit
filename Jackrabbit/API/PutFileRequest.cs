// <copyright file="PutFileRequest.cs" company="Engage Software">
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

    /// <summary>Contains information about updating a file in this module</summary>
    public class PutFileRequest
    {
        /// <summary>Gets or sets the type of file.</summary>
        public FileType FileType { get; set; }

        /// <summary>Gets or sets the name of the path prefix.</summary>
        public string PathPrefixName { get; set; }

        /// <summary>Gets or sets the file path.</summary>
        public string FilePath { get; set; }

        /// <summary>Gets or sets the provider.</summary>
        public string Provider { get; set; }

        /// <summary>Gets or sets the priority.</summary>
        public int Priority { get; set; }

        public string LibraryName { get; set; }

        public Version Version { get; set; }

        public SpecificVersion VersionSpecificity { get; set; }
    }
}