<%@ Control Language="C#" AutoEventWireup="false" CodeBehind="ViewJackrabbit.ascx.cs" Inherits="Engage.Dnn.Jackrabbit.ViewJackrabbit" %>

<asp:PlaceHolder runat="server" Visible="<%#Model.HideView %>">
    <div class="dnnFormMessage dnnFormInfo">
        <%:LocalizeString("View Mode") %>
    </div>
</asp:PlaceHolder>
<asp:Panel runat="server" Visible="<%#!Model.HideView %>">
    <script>
        var data = {
            scripts: <%:new HtmlString(Model.Scripts.ToJson()) %>,
            defaultPathPrefix: <%:EncodeJavaScriptString(Model.DefaultPathPrefix) %>,
            defaultProvider: <%:EncodeJavaScriptString(Model.DefaultProvider) %>,
            defaultScriptPath: <%:EncodeJavaScriptString(Model.DefaultScriptPath) %>,
            defaultPriority: <%:Model.DefaultPriority %>
        };
    </script>
</asp:Panel>

<script runat="server">

    private static IHtmlString EncodeJavaScriptString(string value) {
        return new HtmlString(HttpUtility.JavaScriptStringEncode(value, true));
    }

</script>