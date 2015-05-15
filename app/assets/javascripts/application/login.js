$(document).ready(function(){
    AppBase.showLoadingDialog();

    AppBase.doRequest("/sites", null, null, UserLogin.onLoadSites, null, 'json');

    $("#signinForm").submit(function(event){
        event.preventDefault();
        AppBase.showLoadingDialog("Signing Into Application");
        AppBase.submitRestService($(this),UserLogin.onLoginSuccess)
    });
});


var UserLogin = new Object();
UserLogin.onLoginSuccess = function(data){
    AppBase.hideDialog(AppBase.loadingDialog);
    if(!data.response || data.response.error || !data.response.token){
        $("#signinForm").find(".error-message").removeClass("hidden-element");
        return;
    }
    window.location.href = '/'+data.response.role+'/home?token='+data.response.token;
}

UserLogin.onLoadSites = function(data){
    if(data && data.response){
        html = '';
        data.response.forEach(function(element){
            html += "<option value=\""+element.id+"\">"+element.name+"</option>";
        });
        $("#site").html(html);
    }
    AppBase.hideDialog(AppBase.loadingDialog);
}