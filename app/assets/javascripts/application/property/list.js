$(document).ready(function(){
    AppBase.initializeData();
});

function deviceSelected(){
    if($("#device_id").val()){
        var entityGrid = $(".entity-grid");
        $("[role='entityLink'][data-entity='"+entityGrid.data("entity")+"']").data("filter", $("#device_id").val())
        entityGrid = entityGrid.dataTable();
        entityGrid.api().ajax.reload();
    }
}