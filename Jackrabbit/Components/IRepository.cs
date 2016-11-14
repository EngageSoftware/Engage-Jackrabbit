// <copyright file="IRepository.cs" company="Engage Software">
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
    using System.Collections.Generic;

    using DotNetNuke.Framework.JavaScriptLibraries;

    /// <summary>Represents the ability to get data</summary>
    public interface IRepository
    {
        /// <summary>Gets the files registered for the given module.</summary>
        /// <param name="moduleId">The module ID.</param>
        /// <returns>A sequence of <see cref="JackrabbitFile"/> instances.</returns>
        IEnumerable<JackrabbitFile> GetFiles(int moduleId);

        /// <summary>Adds the file.</summary>
        /// <param name="moduleId">The module ID.</param>
        /// <param name="file">The file.</param>
        void AddFile(int moduleId, JackrabbitFile file);

        /// <summary>Updates the file.</summary>
        /// <param name="file">The file.</param>
        void UpdateFile(JackrabbitFile file);

        /// <summary>Gets the libraries registered for the given module.</summary>
        /// <param name="moduleId">The module ID.</param>
        /// <returns>A sequence of <see cref="JackrabbitLibrary"/> instances.</returns>
        IEnumerable<JackrabbitLibrary> GetLibraries(int moduleId);

        /// <summary>Adds the library.</summary>
        /// <param name="moduleId">The module ID.</param>
        /// <param name="library">The library.</param>
        void AddLibrary(int moduleId, JackrabbitLibrary library);

        /// <summary>Updates the library.</summary>
        /// <param name="library">The library.</param>
        void UpdateLibrary(JackrabbitLibrary library);

        /// <summary>Deletes the file.</summary>
        /// <param name="fileId">The file's ID.</param>
        void DeleteItem(int fileId);

        /// <summary>Undeletes the file.</summary>
        /// <param name="fileId">The file's ID.</param>
        void UndeleteItem(int fileId);

        /// <summary>Gets the details of a <see cref="JackrabbitLibrary"/>.</summary>
        /// <param name="library">The library.</param>
        /// <returns>A new <see cref="JackrabbitLibraryInfo"/> instance</returns>
        JackrabbitLibraryInfo GetLibraryInfo(JackrabbitLibrary library);
    }
}