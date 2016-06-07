// <copyright file="ViewJackrabbit.ascx.cs" company="Engage Software">
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
    using System.Linq;
    using System.Web.UI;

    using DotNetNuke.Services.Exceptions;
    using DotNetNuke.UI.Containers;
    using DotNetNuke.Web.Client;
    using DotNetNuke.Web.Client.ClientResourceManagement;
    using DotNetNuke.Web.Mvp;

    using WebFormsMvp;

    /// <summary>Includes the scripts</summary>
    [PresenterBinding(typeof(ViewJackrabbitPresenter))]
    public partial class ViewJackrabbit : ModuleView<ViewJackrabbitViewModel>, IViewJackrabbitView
    {
        /// <summary>Raises the <see cref="Control.Load" /> event.</summary>
        /// <param name="e">The <see cref="EventArgs" /> object that contains the event data.</param>
        protected override void OnLoad(EventArgs e)
        {
            try
            {
                base.OnLoad(e);

                // NOTE: loading scripts before PreRender fixes a bug where sometimes scripts don't load on postback
                this.RegisterScripts();

                if (!this.Model.HideView)
                {
                    this.RegisterEditScript();
                }
            }
            catch (Exception exc)
            {
                Exceptions.ProcessModuleLoadException(this, exc);
            }
        }

        /// <summary>Raises the <see cref="Control.PreRender" /> event.</summary>
        /// <param name="e">The <see cref="EventArgs" /> object that contains the event data.</param>
        protected override void OnPreRender(EventArgs e)
        {
            try
            {
                base.OnPreRender(e);

                this.AutoDataBind = false;

                if (this.Model.HideContainer)
                {
                    this.HideContainer();
                }
                else
                {
                    this.DataBind();
                }
            }
            catch (Exception exc)
            {
                Exceptions.ProcessModuleLoadException(this, exc);
            }
        }

        /// <summary>Registers the edit script.</summary>
        private void RegisterEditScript()
        {
            ClientResourceManager.RegisterScript(this.Page, "~/DesktopModules/Engage/Jackrabbit/elm.min.js", FileOrder.Js.DefaultPriority, "DnnFormBottomProvider");
        }

        /// <summary>Registers the scripts.</summary>
        private void RegisterScripts()
        {
            foreach (var script in this.Model.Scripts)
            {
                ClientResourceManager.RegisterScript(this.Page, script.FullScriptPath, script.Priority, script.Provider);
            }
        }

        /// <summary>Hides the module's container.</summary>
        private void HideContainer()
        {
            var container = this.Parent;
            while (!(container is Container) && container.Parent != null)
            {
                container = container.Parent;
            }

            if (container.Parent != null)
            {
                container.Visible = false;
            }
        }
    }
}