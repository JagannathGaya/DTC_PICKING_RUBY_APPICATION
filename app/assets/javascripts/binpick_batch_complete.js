$(document).ready(function () {
    binpick_batch_cb_change();
});

function binpick_batch_cb_change() {
    $('#binpick_batch_complete_cb').on('change', function (e) {
        binpick_batch_execute_cb($(this));
    });
}

function binpick_batch_execute_cb(sel) {
    if (sel.prop('checked')) {
        $('#binpick_batch_complete_button').removeClass('disabled');
    }

}

