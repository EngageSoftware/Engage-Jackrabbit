<%@ Control Language="C#" AutoEventWireup="false" CodeBehind="ViewJackrabbit.ascx.cs" Inherits="Engage.Dnn.Jackrabbit.ViewJackrabbit" %>
<%@ Register TagPrefix="dnn" Assembly="DotNetNuke.Web" Namespace="DotNetNuke.Web.UI.WebControls" %>

<asp:PlaceHolder runat="server" Visible="<%#!Model.HideView %>">
    <dnn:DnnGrid ID="ScriptsGrid" runat="server" AutoGenerateColumns="False" OnNeedDataSource="ScriptsGrid_NeedDataSource" OnInsertCommand="ScriptsGrid_InsertCommand" OnUpdateCommand="ScriptsGrid_UpdateCommand">
        <MasterTableView CommandItemDisplay="Top" DataKeyNames="Id">
            <Columns>
                <dnn:DnnGridEditColumn ButtonType="PushButton" />
                <dnn:DnnGridBoundColumn DataField="PathPrefixName" HeaderText="Path Prefix Name" />
                <dnn:DnnGridBoundColumn DataField="ScriptPath" HeaderText="Script Path" />
                <dnn:DnnGridBoundColumn DataField="Provider" HeaderText="Provider" />
                <dnn:DnnGridNumericColumn DataField="Priority" HeaderText="Priority" />
            </Columns>
        </MasterTableView>
    </dnn:DnnGrid>
</asp:PlaceHolder>