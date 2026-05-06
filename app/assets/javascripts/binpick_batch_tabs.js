$(document).ready(function () {
    binpick_batch_tabs_change();
});

function binpick_batch_tabs_change() {
    $('#tab-bin').on('click', function (e) {
        binpick_batch_execute_tabs('bin');
    });
    $('#tab-ord').on('click', function (e) {
        binpick_batch_execute_tabs('ord');
    });
}

function binpick_batch_execute_tabs(param) {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {
            "batch_tabs": param,
            "redirect_to": window.location.href
        },
        dataType: "json",
        success: function (data) {
        }
    });
}

