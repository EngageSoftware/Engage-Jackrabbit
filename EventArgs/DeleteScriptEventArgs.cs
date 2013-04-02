// <copyright file="DeleteScriptEventArgs.cs" company="Engage Software">
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
    using System;

    /// <summary>Contains information about a command to delete a script</summary>
    public class DeleteScriptEventArgs : EventArgs
    {
        /// <summary>Initializes a new instance of the <see cref="DeleteScriptEventArgs"/> class.</summary>
        /// <param name="id">The ID of the script.</param>
        public DeleteScriptEventArgs(int id)
        {
            this.Id = id;
        }

        /// <summary>Gets the script's ID.</summary>
        public int Id { get; private set; }
    }
}