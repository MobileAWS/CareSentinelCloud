var AppBase = new Object();

AppBase.callRestService = function (url, formData, method, success, failure) {
    AppBase.doRequest(url, formData, method, success, failure, 'json');
};

AppBase.getPage = function (url, formData, success, failure) {
    AppBase.doRequest(url, formData, "GET", success, failure, 'html');
};

AppBase.doRequest = function (url, formData, method, success, failure, dataType) {
    method = method ? method : "GET";
    success = success ? success : function () {
    };
    failure = failure ? failure : AppBase.defaultFailure;
    formData = formData ? formData : new Object();

    if (typeof user != "undefined" && user.token) {
        if (typeof formData == "string") {
            if (formData != "") {
                formData += "&";
            }
            formData += "token=" + user.token
        }
        else {
            formData["token"] = user.token;
        }
    }

    if (typeof user != "undefined" && user.site) {
        if (typeof formData == "string") {
            if (formData != "") {
                formData += "&";
            }
            formData += "site=" + user.site
        }
        else {
            formData["site"] = user.site;
        }
    }

    if (typeof user != "undefined" && user.customer) {
        if (typeof formData == "string") {
            if (formData != "") {
                formData += "&";
            }
            formData += "customer_id=" + user.customer;
        }
        else {
            formData["customer_id"] = user.customer;
        }
    }

    var now = new Date();
    var timeOffset = now.getTimezoneOffset();

    if (typeof formData == "string") {
        if (formData != "") {
            formData += "&";
        }
        formData += "time_offset=" + timeOffset;
    }
    else {
        formData["time_offset"] = timeOffset;
    }

    $.ajax(url, {
        data: formData,
        dataType: dataType,
        method: method,
        success: success,
        error: failure
    });
};

AppBase.submitRestService = function (form, success, failure) {
    var method = form.attr("method");
    method = method ? method : "POST";
    AppBase.callRestService(form.attr("action"), form.serialize(), method, success, failure);
};

AppBase.defaultFailure = function () {
    AppBase.hideDialog(AppBase.loadingDialog);
    AppBase.showConfirmDialog("An error occurred, please try again", {title: "Error", cancelOnly: true});
};

AppBase.showLoadingDialog = function (message) {
    message = message ? message : "Loading ..."
    if (!AppBase.loadingDialog) {
        var tmpDialog = $('<div id="appLoadingDialog" class="modal" data-backdrop="static" role="dialog" style="z-index: 9999 !important;"><div class="modal-dialog"><div class="modal-content loading-dialog"><div class="modal-body "><p class="loading-message"></p><div class="loading-panel"></div></div></div></div></div></div>');
        $("body").append(tmpDialog);
        AppBase.loadingDialog = $("#appLoadingDialog");
    }
    AppBase.loadingDialog.find(".loading-message").html(message);
    AppBase.loadingDialog.modal('show');
};

AppBase.processDialogOptions = function (dialog, options) {

    options = options ? options : new Object();
    options.okButton = options.okButton ? options.okButton : "Yes";
    options.cancelButton = options.cancelButton ? options.cancelButton : (options.cancelOnly ? "Close" : "No");
    options.title = options.title ? options.title : "No Title";

    var buttonsPanel = dialog.find(".dialog-buttons");
    buttonsPanel.empty();
    dialog.find(".modal-title").html(options.title);

    if (!options.cancelOnly) {
        var tmpButton = $("<span class='confirm'>" + options.okButton + "</span>");
        if (options.success) {
            tmpButton.click(options.success)
        }
        tmpButton.appendTo(buttonsPanel);
    }

    tmpButton = $("<span class='cancel'>" + options.cancelButton + "</span>");
    if (options.cancel) {
        tmpButton.click(options.cancel)
    }
    else {
        tmpButton.click(AppBase.closeParentDialog);
    }

    tmpButton.appendTo(buttonsPanel);
}


AppBase.closeParentDialog = function () {
    $(this).closest("[role='dialog']").modal("hide");
}

AppBase.hideDialog = function (dialog) {
    if (!dialog) return;
    dialog.modal("hide");
}

AppBase.showInputDialog = function (url, options) {
    if (!AppBase.inputDialog) {
        var tmpDialog = $('<div id="appInputDialog" class="modal input-dialog" data-backdrop="static" role="dialog"><div class="modal-dialog"><div class="modal-content"><div class="modal-header"><div class="modal-title"></div> </div><div class="modal-body"><div class="loading-overlay"><p class="loading-message">Loading</p><div class="loading-panel"></div></div><div class="container"></div><div class="input-dialog-buttons dialog-buttons row"></div><div class="input-dialog-content"></div></div></div></div></div></div>');
        $("body").append(tmpDialog);
        AppBase.inputDialog = $("#appInputDialog");
    }

    AppBase.showInputDialogLoading();
    AppBase.processDialogOptions(AppBase.inputDialog, options);
    AppBase.getPage(url, options.data, AppBase.inputDataLoaded)
    AppBase.inputDialog.modal('show');
}

AppBase.initializeData = function () {
    $("[role='datetime-picker']").datetimepicker({format: 'YYYY-MM-DD'});


    $("[role='autocomplete']").each(function (index, element) {
        $(element).autocomplete({
            serviceUrl: $(element).data('service'),
            params: {
                token: user.token
            },
            transformResult: function (data) {
                var tmp = $.parseJSON(data);
                return {suggestions: tmp.response.suggestions}
            },
            onSelect: function (suggestion) {
                var target = $(this).data("target");
                $("#" + target).val(suggestion.data);
                if ($(this).data("onselect")) {
                    eval($(this).data("onselect") + "('" + suggestion.data + "')");
                }
            }
        });
    });
}

AppBase.inputDataLoaded = function (data) {
    if (!AppBase.inputDialog) return;

    var content = AppBase.inputDialog.find(".input-dialog-content");
    content.empty();
    content.html(data);
    AppBase.initializeData();
    AppBase.hideInputDialogLoading();

}


AppBase.hideInputDialogLoading = function () {
    if (!AppBase.inputDialog) return;
    AppBase.inputDialog.find(".loading-overlay").addClass("hidden-element")
}

AppBase.showInputDialogLoading = function (message) {
    if (!AppBase.inputDialog) return;
    message = message ? message : "Loading";
    var overlay = AppBase.inputDialog.find(".loading-overlay");
    overlay.find(".loading-message").html(message);
    overlay.removeClass("hidden-element");
    $('#successAlert').hide();
    $('#errorAlert').hide();
}

AppBase.showConfirmDialog = function (message, options) {

    if (!AppBase.confirmDialog) {
        var tmpDialog = $('<div id="appConfirmDialog" class="modal" data-backdrop="static" role="dialog"><div class="modal-dialog"><div class="modal-content"><div class="modal-header"><div class="modal-title"></div></div><div class="modal-body"><div class="container"></div><p class="confirm-dialog-message"></p><div class="confirm-dialog-buttons dialog-buttons row"></div></div></div></div></div></div>');
        $("body").append(tmpDialog);
        AppBase.confirmDialog = $("#appConfirmDialog");
    }

    AppBase.confirmDialog.find(".confirm-dialog-message").html(message);
    AppBase.processDialogOptions(AppBase.confirmDialog, options);
    AppBase.confirmDialog.modal('show');
}

AppBase.emailRenderer = function (data, type, full, meta) {
    if (data == null || data == "") {
        return "";
    }

    return "<a href='mailto:" + data + "'>" + data + "</a>";
}

AppBase.actionDialogRender = function (data, type, full, meta) {
    if (data == null || data == "") {
        return "";
    }

    return AppBase.processActionRender(data, meta.col, true);
}

AppBase.actionRender = function (data, type, full, meta) {
    if ((data == null || data == "") && data !== false) {
        return "";
    }

    return AppBase.processActionRender(data, meta.col, false);
}

AppBase.javaScriptRender = function (data, type, full, meta) {
    if ((data == null || data == "") && data !== false) {
        return "";
    }

    var col = meta.col;

    var template = $("#colActionHtmlTemplate" + col).val();
    var action = $("#colAction" + col).val();
    var entity = $("#colActionTitle" + col).val();

    if (action && template) {
        action = action.replace('{data}', data).replace('{id}', full.id).replace('{entity}', entity);
        var elementTemplate = template.replace('{action}', action).replace('{data}', data).replace('{id}', full.id);
        return elementTemplate;
    }

    return data;
}

AppBase.processActionRender = function (data, col, isModal) {
    var template = $("#colActionHtmlTemplate" + col).val();
    var action = $("#colAction" + col).val();

    if (action && template) {
        var title = $("#colActionTitle" + col).val();
        var elementTemplate = template.replace('{onclick}', 'App.fireAction(this, \'' + action + '\', \'' + title + '\', ' + isModal + ');');
        if ($(elementTemplate).prop("type") == 'checkbox') {
            elementTemplate = elementTemplate.replace('{data}', (data ? 'checked' : ''))
        } else {
            elementTemplate = elementTemplate.replace('{data}', data);
        }
        return elementTemplate;
    }

    return data;
}


AppBase.phoneRenderer = function (data) {
    if (data == null || data == "") {
        return "";
    }

    return "<a href='tel:" + data + "'>" + data + "</a>";
}

AppBase.urlRenderer = function (data) {
    if (data == null || data == "" || data.trim().toLowerCase() == "none") {
        return "";
    }
    var url = data;
    if (url.indexOf("http") != 0) {
        url = "http://" + url;
    }
    return "<a href='" + url + "' target='_blank'>" + data + "</a>";
}

AppBase.dateRenderer = function (data) {
    if (data == null || data == "" || data.trim().toLowerCase() == "none") {
        return "";
    }
    return moment(data).format("ddd Do, MMM YYYY hh:mm A")
}

AppBase.statusRenderer = function (data) {
    if (data == null || data == "" || data == 0) {
        return "Pending";
    }

    if (data == 2) return "Completed & Paid"

    return "Unknown";
}

AppBase.booleanRenderer = function (data) {
    if (data == null || data == "" || data == 0 || data == false) {
        return "No";
    }

    return "Yes";
}

AppBase.camelCaseRenderer = function(data){
    if (data == null || data == "" || data.trim().toLowerCase() == "none") {
        return "";
    }

    return AppBase.capitalize(data);
}

AppBase.capitalize = function (string) {
    var splitStr = string.split(' ')
    var fullStr = '';

    $.each(splitStr, function (index) {
        var currentSplit = splitStr[index].charAt(0).toUpperCase() + splitStr[index].slice(1);
        fullStr += currentSplit + " "
    });

    return fullStr;
}