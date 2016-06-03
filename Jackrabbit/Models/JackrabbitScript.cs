// <copyright file="JackrabbitScript.cs" company="Engage Software">
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
    /// <summary>A script registered with this module</summary>
    public class JackrabbitScript
    {
        /// <summary>Initializes a new instance of the <see cref="JackrabbitScript" /> class.</summary>
        /// <param name="pathPrefixName">Name of the path prefix.</param>
        /// <param name="scriptPath">The script path.</param>
        /// <param name="provider">The provider.</param>
        /// <param name="priority">The priority.</param>
        public JackrabbitScript(string pathPrefixName, string scriptPath, string provider, int? priority)
        {
            this.PathPrefixName = pathPrefixName;
            this.ScriptPath = scriptPath;
            this.Provider = provider;
            this.Priority = priority;
        }

        /// <summary>Initializes a new instance of the <see cref="JackrabbitScript" /> class.</summary>
        /// <param name="id">The ID.</param>
        /// <param name="pathPrefixName">Name of the path prefix.</param>
        /// <param name="scriptPath">The script path.</param>
        /// <param name="provider">The provider.</param>
        /// <param name="priority">The priority.</param>
        public JackrabbitScript(int id, string pathPrefixName, string scriptPath, string provider, int? priority)
        {
            this.Id = id;
            this.PathPrefixName = pathPrefixName;
            this.ScriptPath = scriptPath;
            this.Provider = provider;
            this.Priority = priority;
        }

        /// <summary>Gets the ID of the script.</summary>
        public int Id { get; private set; }

        /// <summary>Gets the name of the path prefix.</summary>
        public string PathPrefixName { get; private set; }

        /// <summary>Gets the script path.</summary>
        public string ScriptPath { get; private set; }

        /// <summary>Gets the provider.</summary>
        public string Provider { get; private set; }

        /// <summary>Gets the priority.</summary>
        public int? Priority { get; private set; }
    }
}