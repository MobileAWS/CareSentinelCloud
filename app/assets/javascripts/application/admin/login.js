$(document).ready(function(){
    $("#signinForm").submit(function(event){
        event.preventDefault();
        AppBase.showLoadingDialog("Signing Into Application");
        AppBase.submitRestService($(this),AdminLogin.onLoginSuccess)
    });
});

var AdminLogin = new Object();
AdminLogin.onLoginSuccess = function(data){
    AppBase.hideDialog(AppBase.loadingDialog);
    if(!data.response || data.response.error || !data.response.token){
        $("#signinForm").find(".error-message").removeClass("hidden-element");
        return;
    }
    window.location.href = '/admin/home?token='+data.response.token;
};