$(document).ready(function () {
    binpick_size_filter_change();
});

function binpick_size_filter_change() {
    $('#binpick_order_seq_filter').on('change', function (e) {
        binpick_size_execute_filters();
    });
    $('#binpick_order_no_filter').on('change', function (e) {
        binpick_size_execute_filters();
    });
    $('#binpick_size_filter').on('change', function (e) {
        binpick_size_execute_filters();
    });
    $('#binpick_wave_filter').on('change', function (e) {
        binpick_size_execute_filters();
    });
    $('#binpick_shipping_status_filter').on('change', function (e) {
        binpick_size_execute_filters();
    });
}

function binpick_size_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {
            "binpick_order_seq_filter": $('#binpick_order_seq_filter').val(),
            "binpick_order_no_filter": $('#binpick_order_no_filter').val(),
            "binpick_size_filter": $('#binpick_size_filter option:selected').val(),
            "binpick_wave_filter": $('#binpick_wave_filter option:selected').val(),
            "binpick_shipping_status_filter": $('#binpick_shipping_status_filter option:selected').val(),
            "redirect_to": window.location.href
        },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

