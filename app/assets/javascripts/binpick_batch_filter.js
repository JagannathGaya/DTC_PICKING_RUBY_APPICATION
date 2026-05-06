$(document).ready(function () {
    binpick_batch_filter_change();
});

function binpick_batch_filter_change() {
    $('#batch_status_filter').on('change', function (e) {
        binpick_batch_execute_filters();
    });
    $('#binpick_batch_client_filter').on('change', function (e) {
        binpick_batch_execute_filters();
    });
    $('#binpick_batch_user_filter').on('change', function (e) {
        binpick_batch_execute_filters();
    });
}

function binpick_batch_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {
            "batch_status_filter": $('#batch_status_filter option:selected').val(),
            "binpick_batch_client_filter": $('#binpick_batch_client_filter option:selected').val(),
            "binpick_batch_user_filter": $('#binpick_batch_user_filter option:selected').val(),
            "redirect_to": window.location.href
        },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

