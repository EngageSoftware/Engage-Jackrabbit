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
    /// <summary>A file registered with this module</summary>
    public class JackrabbitFile
    {
        /// <summary>Initializes a new instance of the <see cref="JackrabbitFile" /> class.</summary>
        /// <param name="fileType">The type of file</param>
        /// <param name="pathPrefixName">Name of the path prefix.</param>
        /// <param name="filePath">The file path.</param>
        /// <param name="provider">The provider.</param>
        /// <param name="priority">The priority.</param>
        public JackrabbitFile(FileType fileType, string pathPrefixName, string filePath, string provider, int? priority)
        {
            this.FileType = fileType;
            this.PathPrefixName = pathPrefixName;
            this.FilePath = filePath;
            this.Provider = provider;
            this.Priority = priority;
        }

        /// <summary>Initializes a new instance of the <see cref="JackrabbitFile" /> class.</summary>
        /// <param name="fileType">The type of file</param>
        /// <param name="id">The ID.</param>
        /// <param name="pathPrefixName">Name of the path prefix.</param>
        /// <param name="filePath">The file path.</param>
        /// <param name="provider">The provider.</param>
        /// <param name="priority">The priority.</param>
        public JackrabbitFile(FileType fileType, int id, string pathPrefixName, string filePath, string provider, int? priority)
            : this(fileType, pathPrefixName, filePath, provider, priority)
        {
            this.Id = id;
        }

        /// <summary>Gets the type of the file.</summary>
        public FileType FileType { get; }

        /// <summary>Gets the ID of the file.</summary>
        public int Id { get; }

        /// <summary>Gets the name of the path prefix.</summary>
        public string PathPrefixName { get; }

        /// <summary>Gets the file path.</summary>
        public string FilePath { get; }

        /// <summary>Gets the provider.</summary>
        public string Provider { get; }

        /// <summary>Gets the priority.</summary>
        public int? Priority { get; }
    }
}