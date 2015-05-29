$(document).ready(function(){
    $("#signinForm").submit(function(event){
        event.preventDefault();
        if(!$("#siteSelect").val()){$("#site_id").val('');}
        AppBase.showLoadingDialog("Signing Into Application");
        AppBase.submitRestService($(this),UserLogin.onLoginSuccess)
    });

    $("#resetpasswordForm").submit(function(event){
        event.preventDefault();
        AppBase.showLoadingDialog("Resetting password");
        AppBase.submitRestService($(this),UserLogin.onPasswordReset)
    });

    $("#siteSelect").autocomplete({
        serviceUrl: $("#siteSelect").data('service'),
        transformResult: function(data){
            var tmp = $.parseJSON(data);
            return { suggestions: tmp.response.suggestions}
        },
        onSelect: function (suggestion) {
            var target =  $(this).data("target");
            $("#"+target).val(suggestion.data);
        }
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

UserLogin.onPasswordReset = function(data){
    $("#modalResetOk").modal('show');
    AppBase.hideDialog(AppBase.loadingDialog);
}