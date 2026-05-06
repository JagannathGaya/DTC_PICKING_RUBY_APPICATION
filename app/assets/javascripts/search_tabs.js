$(document).ready(function () {
    search_tabs_change();
});

function search_tabs_change() {
    $('#tab-item_info').on('click', function (e) {
        search_execute_tabs('I');
    });
    $('#tab-item_locs').on('click', function (e) {
        search_execute_tabs('L');
    });
    $('#tab-item_trans').on('click', function (e) {
        search_execute_tabs('T');
    });
}

function search_execute_tabs(param) {
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

