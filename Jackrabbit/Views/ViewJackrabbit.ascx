<%@ Control Language="C#" AutoEventWireup="false" CodeBehind="ViewJackrabbit.ascx.cs" Inherits="Engage.Dnn.Jackrabbit.ViewJackrabbit" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="Engage.Dnn.Jackrabbit" %>
<%@ Import Namespace="DotNetNuke.Common.Utilities" %>

<asp:PlaceHolder runat="server" Visible="<%#Model.HideView %>">
    <div class="dnnFormMessage dnnFormInfo">
        <%:LocalizeString("View Mode") %>
    </div>
</asp:PlaceHolder>
<asp:PlaceHolder runat="server" Visible="<%#!Model.HideView %>">
    <asp:Panel runat="server" ID="FilesEditPanel"></asp:Panel>
    <script>
        /*global jQuery, Elm */
        jQuery(function documentReady($) {
            'use strict';

            var sf = $.ServicesFramework(<%:ModuleContext.ModuleId%>);
            var app = Elm.Views.Main.embed(
                document.getElementById(<%:EncodeJavaScriptString(this.FilesEditPanel.ClientID)%>),
                {
                    files: <%:GenerateScriptJson(this.Model.Files, Model.Libraries) %>,
                    httpInfo: {
                        baseUrl: sf.getServiceRoot('Engage/Jackrabbit'),
                        headers: [
                            [ "ModuleId", <%:EncodeJavaScriptString(ModuleContext.ModuleId)%> ],
                            [ "TabId", <%:EncodeJavaScriptString(ModuleContext.TabId)%> ],
                            [ "RequestVerificationToken", sf.getAntiForgeryValue() ]
                        ]
                    },
                    localization: <%:EncodeJsonObject(LocalizationUtility.GetAllResources(this.LocalResourceFile))%>,
                    pathAliases: <%:EncodeJsonObject(Model.PathAliases) %>
                });

          function onFocus(elementId) {
            setTimeout(() => 
            $('#' + elementId).focus(), [20]);
        }

          app.ports.focus.subscribe(onFocus);

          });
    </script>
</asp:PlaceHolder>

<script runat="server">

    private static IHtmlString EncodeJavaScriptString(IConvertible value) {
        return new HtmlString(HttpUtility.JavaScriptStringEncode(value.ToString(CultureInfo.InvariantCulture), true));
    }

    private static IHtmlString EncodeJavaScriptString(string value) {
        return new HtmlString(HttpUtility.JavaScriptStringEncode(value, true));
    }

    private static IHtmlString EncodeJsonObject(object value) {
        return new HtmlString(value.ToJson());
    }

    private static IHtmlString GenerateScriptJson(IEnumerable<ViewJackrabbitViewModel.FileViewModel> files, IEnumerable<ViewJackrabbitViewModel.LibraryViewModel> libraries) {
        var newEnumerable = files.Cast<object>().Concat(libraries);
        return EncodeJsonObject(newEnumerable);
    }
    
</script>
