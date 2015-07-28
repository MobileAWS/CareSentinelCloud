$(document).ready(function(){
    $("#successMessage").hide(0);

    var config = configValue;
    var emails = emailsConfig;

    $("#emails_purge").val(emails);
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

    $("#btn_emails_purge").click(function(){
        updateEmailPurge();
    });

});

function updateEmailPurge(){
    if(validateEmails()){
        var data = new Object();
        data["emails"] = $("#emails_purge").val();
        AppBase.doRequest("/site_config/emails_purge", data, 'post', onPurgeSaved, null, 'json');
    }else{
        App.loadErrorMessage("Please verify the emails")
    }
}

function updateConfig(){
    var data = new Object();
    data["purge_days"] =  $("input[name=purge_days]:checked").val();
    data["purge_enable"] = $("#purge_enable").prop('checked');
    AppBase.showLoadingDialog("Updating");
    AppBase.doRequest("/site_config/purge_days", data, 'post', onPurgeSaved, null, 'json');
}

function onPurgeSaved(data){
    AppBase.hideDialog(AppBase.loadingDialog);
    App.loadSuccessMessage("Updated successfully!");
}

function validateEmails(){
    var isValid = true;

    if(!$("#emails_purge").val()){
        isValid = false;
    }else{
        $("#emails_purge").val().split(',').forEach(function(element, index){
            if(!AppBase.validateEmail(element)){
                isValid = false;
            }
        });
    }

    return isValid;
}