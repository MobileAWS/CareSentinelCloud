var siteId = null;
var customerId = null;

$(document).ready(function(){
    $("#btnAddCustomer").click(function(){
        if($("#customer_number").val()){
            //Is add or edit
            if($("#user_id").val()){
                var data = new Object();
                data["customer_number"] =  $("#customer_number").val();
                data["user_id"] =  $("#user_id").val();
                AppBase.showLoadingDialog("Adding Customer ID");
                AppBase.doRequest("/user/addCustomerId", data, 'post', onCustomerAdded, null, 'json');
            }else{
                var data = new Object();
                if(!$("#customersUser").val().includes($("#customer_number").val()+",")){
                    data.response = 'done';
                    $("#customersUser").val($("#customersUser").val()+($("#customersUser").val() != '' ? ',' : '')+$("#customer_number").val());
                }else{
                    data.response = 'The customer id is already associated for this user';
                }
                onCustomerAdded(data);
            }
        }
    });

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

function removeCustomer(customer_id){
    customerId = customer_id;
    var data = new Object();

    if($("#user_id").val()){
        data["customer_id"] =  customerId;
        data["user_id"] = $("#user_id").val();
        AppBase.showLoadingDialog("Removing Customer ID");
        AppBase.doRequest("/user/removeCustomerId", data, 'post', onCustomerRemoved, null, 'json');
    }else{
        $("#customersUser").val($("#customersUser").val().replace(','+customer_id,'').replace(customer_id+',','').replace(customer_id, ''));
        var data = new Object();
        data.response = 'done';
        onCustomerRemoved(data);
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

function onCustomerAdded(data){
    AppBase.hideDialog(AppBase.loadingDialog);
    if(data && data.response && data.response == 'done'){
        $("#customerIdTable tr:last").after('<tr id="tr'+$("#customer_number").val()+'"><td>'+$("#customer_number").val()+'</td><td style="text-align: center;"><a href="#" onclick="removeCustomer(\''+$("#customer_number").val()+'\');"><span aria-hidden="true">&times;</span></a></td></tr>');
        $("#customer_number").val('');
        App.loadSuccessMessage('Customer ID associated successfully');
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

function onCustomerRemoved(data){
    AppBase.hideDialog(AppBase.loadingDialog);
    if(data && data.response && data.response == 'done'){
        $("#tr"+customerId).remove();
        App.loadSuccessMessage('Customer ID removed successfully');
    }else{
        App.loadErrorMessage(data.response);
    }
    customerId = null;
}