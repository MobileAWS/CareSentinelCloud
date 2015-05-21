$(document).ready(function(){
    var config = configValue;
    if(config){
        $("#purge_days_"+config).prop('checked', true);
    }
    $("input[name=purge_days]").click(function(){
        var data = new Object();
        data["purge_days"] =  $(this).val();
        AppBase.showLoadingDialog("Updating");
        AppBase.doRequest("/site_config/purge_days", data, 'post', onPurgeSaved, null, 'json');
    });
});

function onPurgeSaved(data){
    AppBase.hideDialog(AppBase.loadingDialog);
    App.showModalMessage('Success', 'Updated successfully!');

}