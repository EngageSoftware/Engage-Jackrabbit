<%@ Control Language="C#" AutoEventWireup="false" CodeBehind="ViewJackrabbit.ascx.cs" Inherits="Engage.Dnn.Jackrabbit.ViewJackrabbit" %>
<%@ Import Namespace="System.Globalization" %>

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
                    scripts: <%:new HtmlString(Model.Scripts.ToJson()) %>,
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
                    }
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

</script>