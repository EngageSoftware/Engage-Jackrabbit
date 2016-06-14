<%@ Control Language="C#" AutoEventWireup="false" CodeBehind="ViewJackrabbit.ascx.cs" Inherits="Engage.Dnn.Jackrabbit.ViewJackrabbit" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="Engage.Dnn.Jackrabbit" %>

<asp:PlaceHolder runat="server" Visible="<%#Model.HideView %>">
    <div class="dnnFormMessage dnnFormInfo">
        <%:LocalizeString("View Mode") %>
    </div>
</asp:PlaceHolder>
<asp:PlaceHolder runat="server" Visible="<%#!Model.HideView %>">
    <asp:Panel runat="server" ID="ScriptsEditPanel"></asp:Panel>
    <script>
        /*global jQuery, Elm */
        jQuery(function documentReady($) {
            'use strict';

            var sf = $.ServicesFramework(<%:ModuleContext.ModuleId%>);
            Elm.Views.Main.embed(
                document.getElementById(<%:EncodeJavaScriptString(ScriptsEditPanel.ClientID)%>),
                {
                    scripts: <%:GenerateScriptJson(Model.Scripts) %>,
                    defaultPathPrefix: <%:EncodeJavaScriptString(Model.DefaultPathPrefix) %>,
                    defaultProvider: <%:EncodeJavaScriptString(Model.DefaultProvider) %>,
                    defaultScriptPath: <%:EncodeJavaScriptString(Model.DefaultScriptPath) %>,
                    defaultPriority: <%:Model.DefaultPriority %>,
                    httpInfo: {
                        baseUrl: sf.getServiceRoot('Engage/Jackrabbit'),
                        headers: [
                            [ "ModuleId", <%:EncodeJavaScriptString(ModuleContext.ModuleId)%> ],
                            [ "TabId", <%:EncodeJavaScriptString(ModuleContext.TabId)%> ],
                            [ "RequestVerificationToken", sf.getAntiForgeryValue() ]
                        ]
                    },
                    localization: <%:EncodeJsonObject(LocalizationUtility.GetAllResources(this.LocalResourceFile))%>
                });
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

    private static IHtmlString GenerateScriptJson(IEnumerable<ViewJackrabbitViewModel.ScriptViewModel> scripts) {
        return EncodeJsonObject(from script in scripts
                                select new {
                                               id = script.Id,
                                               pathPrefixName = script.PathPrefixName,
                                               scriptPath = script.ScriptPath,
                                               provider = script.Provider,
                                               priority = script.Priority,
                                           });
    }

</script>