var chart = null;

$(document).ready(function(){
   $("#btnReport").click(function(){
       if($("#property_device_id").val()){
           var ids = $("#property_device_id").val().split(',')
           AppBase.doRequest("/device/"+ids[0]+"/properties_report/"+ids[1]+"", null, 'post', onDataReportLoaded, null, 'json');
       }
   });
    AppBase.initializeData();
});

function onDataReportLoaded(data){
    console.log(data);
    if(data.response){
        if(!chart){
            var ctx = $("#myChart").get(0).getContext("2d");
            chart = new Chart(ctx).Line(data.response,{});
        }else{
            chart.destroy();
            var ctx = $("#myChart").get(0).getContext("2d");
            chart = new Chart(ctx).Line(data.response,{});
        }
    }else{
        //raise message
    }
}