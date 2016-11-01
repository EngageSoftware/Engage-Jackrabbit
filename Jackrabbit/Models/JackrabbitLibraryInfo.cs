// <copyright file="JackrabbitLibraryInfo.cs" company="Engage Software">
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
    public class JackrabbitLibraryInfo
    {
        public static JackrabbitLibraryInfo Null { get; } = new JackrabbitLibraryInfo("Library not found", "DnnFormBottomProvider", -1000000);

        /// <summary>Initializes a new instance of the <see cref="JackrabbitLibraryInfo" /> class.</summary>
        /// <param name="filePath">The file path.</param>
        /// <param name="provider">The provider.</param>
        /// <param name="priority">The priority.</param>
        public JackrabbitLibraryInfo(string filePath, string provider, int priority)
        {
            this.FilePath = filePath;
            this.Priority = priority;
            this.Provider = provider;
        }

        /// <summary>Gets the path to the file.</summary>
        public string FilePath { get; }

        /// <summary>Gets the priority of the file.</summary>
        public int Priority { get; }

        /// <summary>Gets the name of the provider.</summary>
        public string Provider { get; }

    }
}