$(document).ready(function(){
    auto_moved_item_filter_change();
});

function auto_moved_item_filter_change() {
    $('#auto_moved_item_from_stock_area_filter').on('change', function (e) { auto_moved_item_execute_filters(); });
    $('#auto_moved_item_processed_filter').on('change', function (e) { auto_moved_item_execute_processed(e); });

}
function auto_moved_item_execute_processed(e) {
    var target = $(e.target)
    var value = false;
    if (target.prop('checked')) {
        value = true;
    }
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {
            "auto_moved_item_processed_filter": value,
            "redirect_to": window.location.href
        },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}
function auto_moved_item_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {
            "auto_moved_item_from_stock_area_filter": $('#auto_moved_item_from_stock_area_filter').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}