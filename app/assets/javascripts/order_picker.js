$(document).ready(function(){
    order_picker_change();
});

function order_picker_change() {
    $('.order-picker').on('change', function (e) {
       order_picker_execute_change($(this));
    });
}
function order_picker_execute_change(sel) {
    jQuery.ajax({
        url: "/picker",
        type: "PUT",
        data: {"order_no": sel.attr('id'),
            "pick": sel.prop('checked'),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

