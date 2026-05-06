$(document).ready(function(){
    whouse_item_filter_change();
});

function whouse_item_filter_change() {
    $('#whouse_item_no_filter').on('change', function (e) { whouse_item_execute_filters(); });
    $('#whouse_description_filter').on('change', function (e) { whouse_item_execute_filters(); });
}
function whouse_item_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {
            "whouse_item_no_filter": $('#whouse_item_no_filter').val(),
            "whouse_description_filter": $('#whouse_description_filter').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

