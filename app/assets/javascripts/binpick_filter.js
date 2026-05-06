$(document).ready(function () {
    binpick_filter_change();
});

function binpick_filter_change() {
    $('#orderline_action_filter').on('change', function (e) {
        binpick_execute_filters();
    });
}

function binpick_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {
            "orderline_action_filter": $('#orderline_action_filter option:selected').val(),
            "redirect_to": window.location.href
        },
        dataType: "json",
        success: function (data) {
            window.location.reload();
        }
    });
}

