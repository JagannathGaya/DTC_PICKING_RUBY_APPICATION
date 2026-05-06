$(document).ready(function(){
    search_location_filter_change();
});

function search_location_filter_change() {
    $('#search_stock_area_filter').on('change', function (e) { search_location_execute_filters(); });
    $('#search_bin_loc_filter').on('change', function (e) { search_location_execute_filters(); });
}
function search_location_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {
            "search_stock_area_filter": $('#search_stock_area_filter').val(),
            "search_bin_loc_filter": $('#search_bin_loc_filter').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

