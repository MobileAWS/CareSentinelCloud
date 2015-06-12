$(document).ready(function(){
    $("#successMessage").hide(0);

    var config = configValue;
    if(config){
        $("#purge_days_"+config).prop('checked', true);
    }

    $("input[name=purge_days]").click(function(){
        updateConfig();
    });

    $("#purge_enable").click(function(){
        updateConfig();
    });

    if(configChecked == 'true'){
        document.getElementById('purge_enable').checked = true;
    }

});

function updateConfig(){
    var data = new Object();
    data["purge_days"] =  $("input[name=purge_days]:checked").val();
    data["purge_enable"] = $("#purge_enable").prop('checked');
    console.log(data["purge_enable"]);
    AppBase.showLoadingDialog("Updating");
    AppBase.doRequest("/site_config/purge_days", data, 'post', onPurgeSaved, null, 'json');
}

function onPurgeSaved(data){
    AppBase.hideDialog(AppBase.loadingDialog);
    $("#successMessage").html("Updated successfully!");
    $("#successMessage").show(0);
}