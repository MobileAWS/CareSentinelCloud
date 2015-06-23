//Chart types
var LINE_CHART = "line";
var BAR_CHART = "bar";

var chart = null;
var chartType = null;

$(document).ready(function(){
    console.log("Load");

   $("#historicReportButton").click(function(){
       if($("#device_id").val() && $("#propertiesSelect").val()){
           chartType = LINE_CHART;
           historicExportHref($("#device_id").val(), $("#propertiesSelect").val());
           AppBase.doRequest("/device/"+$("#device_id").val()+"/properties_report/"+$("#propertiesSelect").val()+"", null, 'post', onDataReportLoaded, null, 'json');
       }
   });

   $("#averageReportButton").click(function(){
        if($("#device_id").val()){
            chartType = BAR_CHART;
            averageExportHref($("#device_id").val());
            AppBase.doRequest("/device/"+$("#device_id").val()+"/average_report", null, 'post', onDataReportLoaded, null, 'json');
        }
    });

    AppBase.initializeData();
});

function deviceSelect(deviceId){
    if(deviceId){
        AppBase.doRequest("/device/properties_suggestions?device_id="+deviceId, null, 'get', onPropertiesLoaded, null, 'json');
    }
}

function onPropertiesLoaded(data){
    var propertyOptions = '';

    if(data.response && data.count > 0){
        $(data.response).each(function(index, element){
            propertyOptions += "<option value='"+element.property_id+"'>"+element.key+"</option>";
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
                chart = new Chart(ctx).Line(data.response,{animation: false});
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