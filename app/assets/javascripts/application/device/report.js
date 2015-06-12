//Chart types
var LINE_CHART = "line";
var BAR_CHART = "bar";

var chart = null;
var chartType = null;

$(document).ready(function(){
   $("#btnReport").click(function(){
       if($("#property_device_id").val()){
           chartType = LINE_CHART;
           var ids = $("#property_device_id").val().split(',');
           AppBase.doRequest("/device/"+ids[0]+"/properties_report/"+ids[1]+"", null, 'post', onDataReportLoaded, null, 'json');
       }
   });

   $("#btnAverageReport").click(function(){
        if($("#device_id").val()){
            chartType = BAR_CHART;
            AppBase.doRequest("/device/"+$("#device_id").val()+"/average_report", null, 'post', onDataReportLoaded, null, 'json');
        }
    });

    AppBase.initializeData();
});

function onDataReportLoaded(data){
    if(data.response){
        if(chart){
            chart.destroy();
        }

        var ctx = $("#myChart").get(0).getContext("2d");

        switch(chartType){
            case LINE_CHART:
                chart = new Chart(ctx).Line(data.response,{});
                break;
            case BAR_CHART:
                chart = new Chart(ctx).Bar(data.response,{});
                break;
        }
    }
}

function reportChanged(){
    $(".collapse.in").removeClass('in');
}