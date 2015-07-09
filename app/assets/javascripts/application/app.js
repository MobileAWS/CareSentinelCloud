var App = new Object();

$(document).ready(function(){
    $("[role='entityLink']").click(App.entityLinkClick);
    $("[role='entityLink']").get(0).click();
    $(".logout-button").click(App.logout);
});

App.logout = function(event){
    event.preventDefault();
    AppBase.callRestService($(this).attr("href"),"","GET",function(){ window.location.href = "/"});
}

App.entityLinkClick = function(event){
    event.preventDefault();
    AppBase.showLoadingDialog();
    $(this).closest(".navbar-nav").find(".active").removeClass("active");
    $(this).addClass("active");
    var entity = $(this).data("entity");
    AppBase.getPage("/"+user.role+"/view",{
                                entityName: entity
                            },App.loadEntityView);
}

App.posLoadEntityView = null;

App.loadEntityView = function(data){

    $("[role='contentIn']").empty();

    $(data).find("[role='contentFor']").each(function(index, element){
        var idFor = $(element).data("contentfor");
        $(element).removeAttr('role');
        if(idFor){
            $("#"+idFor).html(element);
        }
    });

    $(".body-content").empty();
    $(".body-content").html(data);
    $("[role='contentFor']").remove();

    var entityGrid = $(".entity-grid");
    var searchable = entityGrid.data("searchable");
    var columns = new Array();
    var columnDefs = new Array();
    var order = new Object();
    columnDefs.push({
            "targets":[0],
            "visible": false,
            "searchable": false
        });

    entityGrid.find("[data-field]").each(function(index,element){
        columns.push({"data":$(this).data("field")});
        var renderer = $(this).data("renderer");
        if(renderer != null && renderer != ""){
            columnDefs.push({
                "targets":[index],
                "render": AppBase[renderer]
            });
        }
        var columnOrder = $(this).data("columnorder");
        if(columnOrder != null && columnOrder != ""){
            order = [[index, columnOrder]]
        }

    });

    entityGrid.on("xhr.dt",function(e,settings,json){
        if(json.pagination){
            json["recordsTotal"] = json.pagination.count;
            json["recordsFiltered"] = json.pagination.count;
        }
    });

    entityGrid.on("preXhr.dt",function(e,settings,data){
        data.per_page = data.length;
        data.page = (data.start/data.length) + 1;
        data.token = user.token;
        data.site = user.site;
        var delFilter = $('#delete-filter:checked');
        if(delFilter.length > 0){
            data.show_deleted = delFilter.val();
        }
        $(".entity-buttons-section .selection-dependent").addClass("disabled");
    });

    var url = entityGrid.size() > 0 ? entityGrid.data("entity").toLowerCase() : '';

    if(jQuery.isEmptyObject(order)){
        order = [[0, "asc"]];
    }

    entityGrid.dataTable({
        "processing": true,
        "serverSide": true,
        "searching": searchable,
        "search":"",
        "bFilter": searchable,
        "order" : order,
        "columnDefs":columnDefs,
        "language":{
            "search": ""
        },
        "ajax":{
            "url": "/"+url+"/list",
            "data": function(d){
                d.filter = $("[role='entityLink'][data-entity='"+entityGrid.data("entity")+"']").data("filter");
            },
            "dataSrc": "response"
        },
        "columns": columns
    });

    //Tratar de anadir un evento para el td que se clickeo comparado al colNumber
    entityGrid.find("tbody").on("click","tr",function(){
        App.selectRow(this);
    });

    var buttonsSection = $(".entity-buttons-section");
    buttonsSection.find(".add").click(App.showAddView);
    buttonsSection.find(".edit").click(App.showEditView);
    buttonsSection.find(".details").click(App.showDetailsView);
    buttonsSection.find(".delete").click(App.deleteRecord);

    if(searchable){
        var searchControl = $(".dataTables_filter").find("[type='search']");
        searchControl.unbind("keyup.DT input.DT keypress.DT");
        var searchButton = $("<span>Search</span>");
        searchControl.after(searchButton);
        searchButton.click(function(event){
            event.preventDefault();
            $(".dataTables_filter").find("[type='search']").trigger("search.DT");
        });

        searchControl.on("keypress",function(e){
            if ( e.keyCode == 13 ) {
                $(this).trigger("search.DT");
                return false;
            }
        });

        /** Fix for a very weird bug in jquery. For some reason, it eats up the first event and it just
         *  puts an empty placeholder. After the second it does the job right. Triggering this here is harmless, since
         *  there's no search data, the search will just return without going to the server, within the data table.
         * */
        searchControl.trigger("search.DT");
    }

    var deleteSection = $(".delete-filter-section");
    if(deleteSection.length > 0){
        deleteSection.insertAfter($(".dataTables_length"));
    }

    $("#delete-filter").click(function(){
        entityGrid.api().ajax.reload();
    })

    AppBase.hideDialog(AppBase.loadingDialog);

    $("[role='entityLink'][data-entity='"+entityGrid.data("entity")+"']").data("filter", "");

    if(App.posLoadEntityView){
        eval(App.posLoadEntityView);
        App.posLoadEntityView = null;
    }
}

App.selectRow = function(row){
    if(!$(row).hasClass("selected")){
        $(".entity-grid").find(".selected").removeClass("selected");
        $(row).addClass("selected");
        $(".entity-buttons-section .disabled").removeClass("disabled");
    }
}

App.getSelectedRowId = function(){
    var entityGrid = $(".entity-grid");
    var selectedRow = entityGrid.find(".selected");
    entityGrid = entityGrid.dataTable();
    return entityGrid.fnGetData(selectedRow[0],0);

}

App.showAddEditView = function(id,title){
    var buttonsSection = $(".entity-buttons-section");
    var data = new Object();
    data["entityName"] =  buttonsSection.data("entity");
    if(id) data["entityId"] = id;

    if($("[role='entityLink'].active").data("title")){
        title = $("[role='entityLink'].active").data("title");
    }else{
        title += " "+buttonsSection.data("entityDisplay");
    }

    AppBase.showInputDialog("/"+user.role+"/add_edit",{
        data: data,
        okButton: "Save",
        title: title,
        success: App.saveEntity
    });
}

App.saveEntity = function(){
    if(!AppBase.inputDialog || App.checkRequiredHidden()) return;
    var form = AppBase.inputDialog.find(".entity-input-form");
    if(!form[0].checkValidity()){
        var hiddenSubmit = form.find(".hidden-submit");
        if(form.find(".hidden-submit").length <= 0){
            hiddenSubmit = $('<input type="submit" class="hidden-submit hidden-element">');
            form.append(hiddenSubmit);
        }
        hiddenSubmit.click();
        return;
    }
    AppBase.showInputDialogLoading("Saving");
    var idElement = form.find("[role='entity-id']");
    if(idElement.length == 0) {
        form.attr("action", "/" + form.data("entity").toLowerCase() + "/create");
    }
    else{
        form.attr("action", "/" + form.data("entity").toLowerCase() + "/update");
    }
    AppBase.submitRestService(form,App.entitySaved);
}

App.entitySaved = function(data){
    if(!data.response.error){
        App.reloadEntityView();
        AppBase.hideDialog(AppBase.inputDialog);
    }else{
        AppBase.hideInputDialogLoading();
        App.loadErrorMessage(data.response.message);
    }
}

App.showDetailsView = function(){
    if($(this).hasClass("disabled")){
        return;
    }

    var buttonsSection = $(".entity-buttons-section");
    var data = new Object();
    data["entityName"] =  buttonsSection.data("entity");
    data["entityId"] = App.getSelectedRowId();

    AppBase.showInputDialog("/"+user.role+"/details",{
        data: data,
        title: "Details for "+buttonsSection.data("entityDisplay"),
        cancelOnly: true
    });
}

App.showAddView = function(){
    App.showAddEditView(null,"Create");
}

App.showEditView = function(){
    if($(this).hasClass("disabled")){
        return;
    }
    App.showAddEditView(App.getSelectedRowId(),"Edit")
}

App.deleteRecord = function(){
    if($(this).hasClass("disabled")){
        return;
    }
    var buttonsSection = $(".entity-buttons-section");
    AppBase.showConfirmDialog("Are you sure you want to delete this "+buttonsSection.data("entityDisplay")+"?",{
        "title": "Confirm Delete",
        "success": App.deleteEntity
    });
}

App.deleteEntity = function(){
    var buttonsSection = $(".entity-buttons-section");
    AppBase.hideDialog(AppBase.confirmDialog);
    AppBase.showLoadingDialog("Deleting");
    var entity = buttonsSection.data("entity").toLowerCase();
    var data = new Object();
    data[entity+"_id"] = App.getSelectedRowId();
    AppBase.callRestService("/" + entity + "/delete",data,"POST",App.deleteSuccess,App.deleteFailed);
}

App.deleteSuccess = function(){
    App.reloadEntityView();
    AppBase.hideDialog(AppBase.loadingDialog);
    var buttonsSection = $(".entity-buttons-section");
    AppBase.showConfirmDialog("The "+buttonsSection.data("entityDisplay")+" was successfully removed",{title: "Sucess", cancelOnly: true});
}

App.deleteFailed = function(response){
    var data = response.responseJSON;
    AppBase.hideDialog(AppBase.loadingDialog)
    var buttonsSection = $(".entity-buttons-section");
    AppBase.showConfirmDialog("The "+buttonsSection.data("entityDisplay")+" cannot be deleted at this moment:<br/>"+data.message,{title: "Error",cancelOnly: true});
}

App.reloadEntityView = function(){
    $("[role='entityLink'].active").click();
}

App.loadErrorMessage = function(html_msg){
    App.hideSuccessMessage();
    $("#errorAlertMsg").html(html_msg);
    $("#errorAlert").show();
}

App.loadSuccessMessage = function(html_msg){
    App.hideErrorMessage();
    $("#successAlertMsg").html(html_msg);
    $("#successAlert").show();
}

App.hideErrorMessage = function(){
    $('#errorAlert').hide();
}

App.hideSuccessMessage = function(){
    $('#successAlert').hide();
}

App.reloadTable = function(){
    $(".entity-grid").dataTable().api().ajax.reload();
}

App.fireAction = function(element, action, title, isModal){
    App.selectRow(element.parentElement.parentElement);

    if(action){
        var buttonsSection = $(".entity-buttons-section");
        try{
            var id = App.getSelectedRowId();
        }catch(e){
            var id = App.getSelectedRowId();
        }
        action = action.replace(':id', id);
        var url = "/"+$(".entity-grid").data("entity")+action;

        if(isModal){
            AppBase.showInputDialog(url,{
                title: buttonsSection.data("entityDisplay")+" "+(title ? title : ''),
                cancelOnly: true
            });
        }else{
            AppBase.doRequest(url, null, "post", App.reloadTable, null, 'json');
        }
    }
}

App.showModalMessage = function(title, message){
    $("#modalMessageText").text(message);
    $("#modalMessageTitle").text(title);
    $("#modalMessage").modal('show');
}

App.checkRequiredHidden = function(){
    var requiredError = false;
    $("input[type=hidden]").each(function(index, element){
        if($(this).attr('required') && !$(this).val()){
            App.loadErrorMessage($(this).attr('for')+' must be provided');
            requiredError = true;
        }
    });

    return requiredError;
}