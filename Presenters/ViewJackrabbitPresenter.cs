// <copyright file="ViewJackrabbitPresenter.cs" company="Engage Software">
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
    using System.Linq;

    using DotNetNuke.Security.Permissions;
    using DotNetNuke.Web.Client;
    using DotNetNuke.Web.Mvp;

    using WebFormsMvp;

    /// <summary>Acts as a presenter for <see cref="IViewJackrabbitView"/></summary>
    public sealed class ViewJackrabbitPresenter : ModulePresenter<IViewJackrabbitView, ViewJackrabbitViewModel>
    {
        /// <summary>The data repository</summary>
        private readonly IRepository repository;

        /// <summary>Initializes a new instance of the <see cref="ViewJackrabbitPresenter"/> class.</summary>
        /// <param name="view">The view.</param>
        public ViewJackrabbitPresenter(IViewJackrabbitView view)
            : this(view, new ContentItemRepository())
        {
        }

        /// <summary>Initializes a new instance of the <see cref="ViewJackrabbitPresenter" /> class.</summary>
        /// <param name="view">The view.</param>
        /// <param name="repository">The repository.</param>
        internal ViewJackrabbitPresenter(IViewJackrabbitView view, IRepository repository)
            : base(view)
        {
            this.repository = repository;
            this.View.Initialize += this.View_Initialize;
            this.View.AddScript += this.View_AddScript;
            this.View.UpdateScript += this.View_UpdateScript;
        }

        /// <summary>Handles the <see cref="IModuleViewBase.Initialize"/> event of the <see cref="Presenter{TView}.View"/>.</summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void View_Initialize(object sender, EventArgs e)
        {
            try
            {
                this.View.Model.HideView = !ModulePermissionController.CanManageModule(this.ModuleInfo);
                this.View.Model.Scripts = this.repository.GetScripts(this.ModuleId).Select(s => new ViewJackrabbitViewModel.ScriptViewModel(s.Id, s.PathPrefixName, s.ScriptPath, s.Provider, s.Priority ?? (int)FileOrder.Js.DefaultPriority));
                this.View.Model.PathPrefixes = new[] { string.Empty, "SkinPath", "SharedScripts", }.AsEnumerable();
                this.View.Model.Providers = new[] { "DnnPageHeaderProvider", "DnnBodyProvider", "DnnFormBottomProvider", };
            }
            catch (Exception ex)
            {
                this.ProcessModuleLoadException(ex);
            }
        }

        /// <summary>Handles the <see cref="IViewJackrabbitView.AddScript"/> event of the <see cref="Presenter{TView}.View"/>.</summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="AddScriptEventArgs"/> instance containing the event data.</param>
        private void View_AddScript(object sender, AddScriptEventArgs e)
        {
            try
            {
                this.repository.AddScript(this.ModuleId, new JackrabbitScript(e.PathPrefixName, e.ScriptPath, e.Provider, e.Priority));
            }
            catch (Exception ex)
            {
                this.ProcessModuleLoadException(ex);
            }
        }

        /// <summary>Handles the <see cref="IViewJackrabbitView.UpdateScript"/> event of the <see cref="Presenter{TView}.View"/>.</summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="UpdateScriptEventArgs"/> instance containing the event data.</param>
        private void View_UpdateScript(object sender, UpdateScriptEventArgs e)
        {
            try
            {
                this.repository.UpdateScript(new JackrabbitScript(e.Id, e.PathPrefixName, e.ScriptPath, e.Provider, e.Priority));
            }
            catch (Exception ex)
            {
                this.ProcessModuleLoadException(ex);
            }
        }
    }
}
