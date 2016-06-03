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
    using System.Collections.Generic;
    using System.Diagnostics.CodeAnalysis;

    /// <summary>The view model for the Jackrabbit, to be displayed by <see cref="IViewJackrabbitView"/></summary>
    public class ViewJackrabbitViewModel
    {
        /// <summary>Gets or sets a value indicating whether module's container should be hidden (i.e. if the module should not have any display).</summary>
        public bool HideContainer { get; set; }

        /// <summary>Gets or sets a value indicating whether the view of the module should display or not (but the container might still display, to let editors know it's there).</summary>
        public bool HideView { get; set; }

        /// <summary>Gets or sets the scripts being included by this module.</summary>
        public IEnumerable<ScriptViewModel> Scripts { get; set; }

        /// <summary>Gets or sets the default path prefix.</summary>
        public string DefaultPathPrefix { get; set; }

        /// <summary>Gets or sets the default script path.</summary>
        public string DefaultScriptPath { get; set; }

        /// <summary>Gets or sets the default provider.</summary>
        public string DefaultProvider { get; set; }

        /// <summary>Gets or sets the default priority.</summary>
        public int DefaultPriority { get; set; }

        /// <summary>Represents a script included by this module</summary>
        [SuppressMessage("Microsoft.Design", "CA1034:NestedTypesShouldNotBeVisible", Justification = "I'm cool with nested classes in view models")]
        public class ScriptViewModel
        {
            /// <summary>Initializes a new instance of the <see cref="ScriptViewModel" /> class.</summary>
            /// <param name="id">The ID of the script.</param>
            /// <param name="pathPrefixName">Name of the path prefix.</param>
            /// <param name="scriptPath">The script path.</param>
            /// <param name="fullScriptPath">The script path combined with the prefix.</param>
            /// <param name="provider">The provider.</param>
            /// <param name="priority">The priority.</param>
            public ScriptViewModel(int id, string pathPrefixName, string scriptPath, string fullScriptPath, string provider, int priority)
            {
                this.Id = id;
                this.PathPrefixName = pathPrefixName;
                this.ScriptPath = scriptPath;
                this.FullScriptPath = fullScriptPath;
                this.Provider = provider;
                this.Priority = priority;
            }

            /// <summary>Gets the ID of the script.</summary>
            public int Id { get; private set; }

            /// <summary>Gets the name of the path prefix.</summary>
            public string PathPrefixName { get; private set; }

            /// <summary>Gets the script path.</summary>
            public string ScriptPath { get; private set; }

            /// <summary>Gets the script path combined with the prefix.</summary>
            public string FullScriptPath { get; private set; }

            /// <summary>Gets the provider.</summary>
            public string Provider { get; private set; }

            /// <summary>Gets the priority.</summary>
            public int Priority { get; private set; }
        }
    }
}