// <copyright file="ServiceRouteMapper.cs" company="Engage Software">
// Engage: Jackrabbit
// Copyright (c) 2004-2016
// by Engage Software ( http://www.engagesoftware.com )
// </copyright>
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
namespace Engage.Dnn.Jackrabbit.Api
{
    using System;
    using System.Linq;

    using DotNetNuke.Web.Api;

    /// <summary>Maps the route to the files service</summary>
    /// <seealso cref="DotNetNuke.Web.Api.IServiceRouteMapper" />
    public class ServiceRouteMapper : IServiceRouteMapper
    {
        public void RegisterRoutes(IMapRoute mapRouteManager)
        {
            mapRouteManager.MapHttpRoute(
                routeName: "file controller ☹",
                moduleFolderName: "Engage/Jackrabbit",
                url: "file/{action}",
                namespaces: new[] { "Engage.Dnn.Jackrabbit.Api", },
                defaults: new { controller = "file", action = "default", });
            mapRouteManager.MapHttpRoute(
                routeName: "default",
                moduleFolderName: "Engage/Jackrabbit",
                url: "{controller}/",
                namespaces: new[] { "Engage.Dnn.Jackrabbit.Api", });
        }
    }
}
