$(document).ready(function () {
    binpick_summary_filter_change();
});

function binpick_summary_filter_change() {
    $('#bin_summary_status_filter').on('change', function (e) {
        binpick_summary_execute_filters();
    });
    $('#binpick_pick_type_filter').on('change', function (e) {
        binpick_summary_execute_filters();
    });
}

function binpick_summary_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {
            "binpick_pick_type_filter": $('#binpick_pick_type_filter option:selected').val(),
            "bin_summary_status_filter": $('#bin_summary_status_filter option:selected').val(),
            "redirect_to": window.location.href
        },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

