// <copyright file="ViewJackrabbitPresenter.cs" company="Engage Software">
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
    using System.Collections.Generic;
    using System.Linq;

    using ClientDependency.Core.Controls;

    using DotNetNuke.Security.Permissions;
    using DotNetNuke.Web.Client;
    using DotNetNuke.Web.Mvp;

    using WebFormsMvp;

    /// <summary>Acts as a presenter for <see cref="IViewJackrabbitView"/></summary>
    public sealed class ViewJackrabbitPresenter : ModulePresenter<IViewJackrabbitView, ViewJackrabbitViewModel>
    {
        /// <summary>The data repository</summary>
        private readonly IRepository repository;

        /// <summary>Backing field for <see cref="DependencyLoader" /></summary>
        private readonly Lazy<ClientDependencyLoader> dependencyLoader;

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
            this.dependencyLoader = new Lazy<ClientDependencyLoader>(() => ClientDependencyLoader.GetInstance(this.HttpContext));
            this.View.Initialize += this.View_Initialize;
        }

        /// <summary>Gets the client dependency loader</summary>
        private ClientDependencyLoader DependencyLoader
        {
            get { return this.dependencyLoader.Value; }
        }

        /// <summary>Handles the <see cref="IModuleViewBase.Initialize"/> event of the <see cref="Presenter{TView}.View"/>.</summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void View_Initialize(object sender, EventArgs e)
        {
            try
            {
                this.View.Model.HideContainer = !ModulePermissionController.CanManageModule(this.ModuleInfo);
                this.View.Model.HideView = !this.IsEditable;
                this.View.Model.Files = this.GetFiles();
                this.View.Model.Libraries = this.GetLibraries();
                this.View.Model.DefaultPathPrefix = string.Empty;
                this.View.Model.DefaultFilePath = "~/";
                this.View.Model.DefaultProvider = "DnnFormBottomProvider";
                this.View.Model.DefaultPriority = (int)FileOrder.Js.DefaultPriority;
            }
            catch (Exception ex)
            {
                this.ProcessModuleLoadException(ex);
            }
        }

        /// <summary>Gets the files.</summary>
        /// <returns>A sequence of <see cref="ViewJackrabbitViewModel.FileViewModel"/> instances.</returns>
        private IEnumerable<ViewJackrabbitViewModel.FileViewModel> GetFiles()
        {
            return this.repository.GetFiles(this.ModuleId).Select(this.CreateFileViewModel).OrderBy(s => s.Priority);
        }

        private IEnumerable<ViewJackrabbitViewModel.LibraryViewModel> GetLibraries()
        {
            return from library in this.repository.GetLibraries(this.ModuleId)
                   let libraryInfo = this.repository.GetLibraryInfo(library)
                   select
                   new ViewJackrabbitViewModel.LibraryViewModel(
                       library.FileType,
                       library.Id,
                       libraryInfo.FilePath,
                       "JS Library",
                       "JS Library" + libraryInfo.FilePath,
                       libraryInfo.Provider,
                       libraryInfo.Priority,
                       library.LibraryName,
                       library.Version.ToString(),
                       library.VersionSpecificity);
        }

        /// <summary>Creates the file view model.</summary>
        /// <param name="file">The file.</param>
        /// <returns>A new <see cref="ViewJackrabbitViewModel.FileViewModel" /> instance.</returns>
        private ViewJackrabbitViewModel.FileViewModel CreateFileViewModel(JackrabbitFile file)
        {
            var fullFilePath = file.FilePath;
            var prefixPath = string.IsNullOrEmpty(file.PathPrefixName) ? null : this.DependencyLoader.Paths.Find(p => p.Name == file.PathPrefixName);
            if (prefixPath != null)
            {
                fullFilePath = prefixPath.Path + file.FilePath;
            }

            var defaultPriority = file.FileType == FileType.CssFile ? (int)FileOrder.Css.DefaultPriority : (int)FileOrder.Js.DefaultPriority;
            return new ViewJackrabbitViewModel.FileViewModel(
                file.FileType,
                file.Id,
                file.PathPrefixName,
                file.FilePath,
                fullFilePath,
                file.Provider,
                file.Priority ?? defaultPriority);
        }
    }
}
