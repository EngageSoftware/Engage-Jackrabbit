// <copyright file="JackrabbitLibrary.cs" company="Engage Software">
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
    /// <summary>A library registered with this module</summary>
    public class JackrabbitLibrary
    {
        /// <summary>Initializes a new instance of the <see cref="JackrabbitLibrary" /> class.</summary>
        /// <param name="libraryName">The name of the library</param>
        /// <param name="version">The version of the library being requested.</param>
        /// <param name="specificity">The specificity of <param name="version" />.</param>
        public JackrabbitLibrary(string libraryName, Version version, Specific specificity)
        {
            this.LibraryName = libraryName;
            this.Version = version;
            this.Specificity = specificity;
        }

        /// <summary>Initializes a new instance of the <see cref="JackrabbitFile" /> class.</summary>
        /// <param name="id">The ID.</param>
        /// <param name="libraryName">The name of the library</param>
        /// <param name="version">The version of the library being requested.</param>
        /// <param name="specificity">The specificity of <param name="version" />.</param>
        public JackrabbitLibrary(int id, string libraryName, Version version, Specific specificity)
            : this(libraryName, version, specificity)
        {
            this.Id = id;
        }

        /// <summary>Gets the name of the library.</summary>
        public string LibraryName { get; }

        /// <summary>Gets the ID of the library request.</summary>
        public int Id { get; }

        /// <summary>Gets the version of the library request.</summary>
        public Version Version { get; }

        /// <summary>Gets the specificity of the <see cref="Version" />.</summary>
        public Specific Specificity { get; }
    }
}
