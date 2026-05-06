$(document).ready(function(){
    client_setter_change();
});

function client_setter_change() {
    $('#client_setter').on('change', function (e) {
        client_id_execute_filters();
    });
}
function client_id_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {"client_id": $('#client_setter option:selected').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

