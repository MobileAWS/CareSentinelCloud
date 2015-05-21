var siteId = null;

$(document).ready(function(){
    $("#btnAddSite").click(function(){
        if($("#site_id").val()){
            if($("#user_id").val()){
                var data = new Object();
                data["site_id"] =  $("#site_id").val();
                data["user_id"] =  $("#user_id").val();
                AppBase.showLoadingDialog("Adding Site");
                AppBase.doRequest("/user/addSiteUser", data, 'post', onSiteAdded, null, 'json');
            }else{
                var data = new Object();
                if(!$("#sitesUser").val().includes($("#site_id").val()+",")){
                    data.response = 'done';
                    $("#sitesUser").val($("#sitesUser").val()+($("#sitesUser").val() != '' ? ',' : '')+$("#site_id").val());
                }else{
                    data.response = 'The site is already associated for this user';
                }
                onSiteAdded(data);
            }
        }else{
            $("#errorAlertMsg").html("A site must be selected");
            $("#errorAlert").show();
        }
    });
});

function removeSite(site_id){
    siteId = site_id;
    var data = new Object();

    if($("#user_id").val()){
        data["site_id"] =  site_id;
        data["user_id"] = $("#user_id").val();
        AppBase.showLoadingDialog("Removing Site");
        AppBase.doRequest("/user/removeSiteUser", data, 'post', onSiteRemove, null, 'json');
    }else{
        $("#sitesUser").val($("#sitesUser").val().replace(','+site_id,'').replace(site_id+',','').replace(site_id, ''));
        var data = new Object();
        data.response = 'done';
        onSiteRemove(data);
    }

}

function onSiteAdded(data){
    AppBase.hideDialog(AppBase.loadingDialog);
    if(data && data.response && data.response == 'done'){
        $("#siteNameTable tr:last").after('<tr id="tr'+$("#site_id").val()+'"><td>'+$("#siteSelect").val()+'</td><td style="text-align: center;"><a href="#" onclick="removeSite(\''+$("#site_id").val()+'\');"><span aria-hidden="true">&times;</span></a></td></tr>');
        $("#site_id").val('');
        $("#siteSelect").val('');
        App.loadSuccessMessage('Site associated successfully');
    }else{
        App.loadErrorMessage(data.response);
    }
}

function onSiteRemove(data){
    AppBase.hideDialog(AppBase.loadingDialog);
    if(data && data.response && data.response == 'done'){
        $("#tr"+siteId).remove();
        App.loadSuccessMessage('Site removed successfully');
    }else{
        App.loadErrorMessage(data.response);
    }
    siteId = null;
}