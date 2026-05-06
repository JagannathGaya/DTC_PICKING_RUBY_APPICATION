$(document).ready(function(){
    search_trans_filter_change();
});

function search_trans_filter_change() {
    $('#search_trans_type_filter_').on('mouseleave', function (e) { search_trans_execute_filters(); });
    $('#search_area_bin_filter_').on('mouseleave', function (e) { search_trans_execute_filters(); });
    $('#search_qty_mod_filter').on('change', function (e) { search_trans_execute_filters(); });
    $('#search_quantity_filter').on('change', function (e) { search_trans_execute_filters(); });
    $('#search_loc_type_filter').on('change', function (e) { search_trans_execute_filters(); });
}
function search_trans_execute_filters() {
    var search_trans_type_filter = "";
    $( "#search_trans_type_filter_ option:selected" ).each(function() {
        search_trans_type_filter += $( this ).val() + " ";
    });
    var search_area_bin_filter = "";
    $( "#search_area_bin_filter_ option:selected" ).each(function() {
        search_area_bin_filter += $( this ).val() + " ";
    });
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {
            "search_trans_type_filter": search_trans_type_filter,
            "search_area_bin_filter": search_area_bin_filter,
            "search_qty_mod_filter": $('#search_qty_mod_filter option:selected').val(),
            "search_quantity_filter": $('#search_quantity_filter').val(),
            "search_loc_type_filter": $('#search_loc_type_filter option:selected').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

