$(document).ready(function () {
    line_picker_change();
});

function line_picker_change() {
    $('.line-picker').on('change', function (e) {
        line_picker_execute_change($(this));
    });
}

function line_picker_execute_change(sel) {
    if (sel.prop('checked')) {
        if (sel.closest('tr').find('.pick_actual_qty').val() == '0') {
            sel.closest('tr').find('.pick_actual_qty').val(sel.closest('tr').find('.pick_qty').text());
        }
    }
    else {
        sel.closest('tr').find('.pick_actual_qty').val(0);
    }
    jQuery.ajax({
        url: "/picks",
        type: "PUT",
        data: {
            "pick_id": sel.closest('tr').attr('id'),
            "pick": sel.prop('checked'),
            "actual_qty": sel.closest('tr').find('.pick_actual_qty').val(),
            "redirect_to": window.location.href
        },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

