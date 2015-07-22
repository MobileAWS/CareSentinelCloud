//Chart types
var LINE_CHART = "line";
var BAR_CHART = "bar";

var chart = null;
var chartType = null;

$(document).ready(function(){
   $("#historicReportButton").click(function(){
       if($("#device_id").val() && $("#propertiesSelect").val() && checkDates()){
           chartType = LINE_CHART;
           historicExportHref($("#device_id").val(), $("#propertiesSelect").val());
           AppBase.doRequest("/device/"+$("#device_id").val()+"/properties_report/"+$("#propertiesSelect").val()+"", appendDates(), 'post', onDataReportLoaded, null, 'json');
       }
   });

   $("#averageReportButton").click(function(){
        if($("#device_id").val() && $("#propertiesSelect").val() && checkDates()){
            chartType = BAR_CHART;
            averageExportHref($("#device_id").val());
            AppBase.doRequest("/device/"+$("#device_id").val()+"/average_report/"+$("#propertiesSelect").val(), appendDates(), 'post', onDataReportLoaded, null, 'json');
        }
    });

    $("#downloadLink").attr("disabled", true);

    AppBase.initializeData();
});

function appendDates(){
    data = new Object();
    data["start_date"] = $('#start_date').val();
    data["end_date"] = $('#end_date').val();

    return data;
}

function checkDates(){
    var isValid = true;

    if(!$('#start_date').val()){
        $('#start_date').focus();
        isValid = false;
    }else if(!$('#end_date').val()){
        $('#end_date').focus();
        isValid = false;
    }

    return isValid;
}

function deviceSelect(deviceId){
    if(deviceId){
        AppBase.doRequest("/devicemapping/properties_suggestions?device_id="+deviceId, null, 'get', onPropertiesLoaded, null, 'json');
    }
}

function onPropertiesLoaded(data){
    var propertyOptions = '';

    if(data.response && data.count > 0){
        $(data.response).each(function(index, element){
            propertyOptions += "<option value='"+element.property_id+"'>"+ AppBase.capitalize(element.key)+"</option>";
        });

        $("#historicReportButton").attr('disabled', false);
        $("#averageReportButton").attr('disabled', false);
    }else{
        propertyOptions = "<option value=''>Device must have properties</option>";

        $("#historicReportButton").attr('disabled', true);
        $("#averageReportButton").attr('disabled', true);
    }

    $("#propertiesSelect").html(propertyOptions);
}

function onDataReportLoaded(data){
    if(data.response){

        if(chart){
            chart.destroy();
        }

        var ctx = $("#myChart").get(0).getContext("2d");

        switch(chartType){
            case LINE_CHART:
                chart = new Chart(ctx).Line(data.response,{animation: false, multiTooltipTemplate: "<%= datasetLabel %> - <%= value %>"});
                break;
            case BAR_CHART:
                chart = new Chart(ctx).Bar(data.response,{animation: false});
                break;
        }
    }
}

function historicExportHref(deviceId, propertyId){

    if($("#linkExportHistoric").attr('old_href')){
        var href = $("#linkExportHistoric").attr('old_href');
    }else{
        var href = $("#linkExportHistoric").prop('href');
        $("#linkExportHistoric").attr('old_href', href);
    }

    $("#linkExportHistoric").attr('href', href+'&device_id='+deviceId+'&property_id='+propertyId);
}

function averageExportHref(deviceId){

    if($("#linkExportAverage").attr('old_href')){
        var href = $("#linkExportAverage").attr('old_href');
    }else{
        var href = $("#linkExportAverage").prop('href');
        $("#linkExportAverage").attr('old_href', href);
    }

    $("#linkExportAverage").attr('href', href+'&device_id='+deviceId);
}

function deviceNameSelected(deviceName, deviceId, entity){
    $("[role='entityLink'][data-entity='"+entity+"']").data("filter", deviceId);
    App.posLoadEntityView = "posLoadProperty('"+deviceName+"')";
    $("[role='entityLink'][data-entity='"+entity+"']").click();
}

function posLoadProperty(deviceName){
    $('#deviceSelect').val(deviceName);
}

function deviceDownloadCheck(id){
    checkDownloadslinks();
    if($("#downloadlink_"+id).is(':checked')){
        $("#download_ids").val(id+","+$("#download_ids").val());
    }else{
        $("#download_ids").val($("#download_ids").val().replace(id+',', ''));
    }

    if($("#download_ids").val()) {
        $("#downloadLink").attr("disabled", false);
    }else{
        $("#downloadLink").attr("disabled", true);
    }

    updateDownloadLinkHref();
}

function updateDownloadLinkHref(){
    if($("#downloadLink").attr('old_href')){
        var href = $("#downloadLink").attr('old_href');
    }else{
        var href = $("#downloadLink").prop('href');
        $("#downloadLink").attr('old_href', href);
    }

    var timeOffset = AppBase.getTimeZoneOffSet();

    $("#downloadLink").attr('href', href+'&device_ids='+$("#download_ids").val()+"&time_offset=" + timeOffset);
}

function checkDownloadslinks(){
    var ids = $("#download_ids").val();
    var arrayIds = ids.split(",");

    arrayIds.forEach(function(entry) {
        $("#downloadlink_"+entry).attr('checked', true);
    });
}