// <copyright file="IRepository.cs" company="Engage Software">
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
    using System.Collections.Generic;

    /// <summary>Represents the ability to get data</summary>
    public interface IRepository
    {
        /// <summary>Gets the scripts registered for the given module.</summary>
        /// <param name="moduleId">The module ID.</param>
        /// <returns>A sequence of <see cref="JackrabbitScript"/> instances.</returns>
        IEnumerable<JackrabbitScript> GetScripts(int moduleId);

        /// <summary>Adds the script.</summary>
        /// <param name="moduleId">The module ID.</param>
        /// <param name="script">The script.</param>
        void AddScript(int moduleId, JackrabbitScript script);

        /// <summary>Updates the script.</summary>
        /// <param name="script">The script.</param>
        void UpdateScript(JackrabbitScript script);
    }
}