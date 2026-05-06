$(document).ready(function () {
    binpick_replenishment_change();
});

function binpick_replenishment_change() {
    $('.binpick_replenishment_scan').on('change', function (e) {
        binpick_replenishment_execute_change($(this));
    });
    $('.pick_actual_qty').on('change', function (e) {
        color_change_one($(this));
    });
}

function binpick_replenishment_execute_change(sel) {
    jQuery.ajax({
        url: "/binpick_replenishments/move_it",
        type: "PUT",
        data: {
            "binpick_replenishment_id": sel.closest('tr').attr('id'),
            "trans_qty": sel.closest('tr').find('.pick_actual_qty').val(),
            "row_type": sel.closest('tr').find('.binpick_row_type').html(),
            "scanner_entry": sel.closest('tr').find('.binpick_replenishment_scan').val(),
            "redirect_to": window.location.href
        },
        dataType: "json",
        success: function (data) {
            window.location.reload(true);
        }
    });
}
function color_change_one(sel) {
    sel.closest('td').removeClass('table-warning');
    sel.closest('tr').find('.binpick_replenishment_scan').closest('td').addClass('table-warning');
    sel.closest('tr').find('.binpick_move_from').closest('td').addClass('table-warning');
}

