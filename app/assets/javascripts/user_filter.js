$(document).ready(function(){
    user_filter_change();
});

function user_filter_change() {
    $('#user_email_filter').on('change', function (e) { user_execute_filters(); });
    $('#user_empno_filter').on('change', function (e) { user_execute_filters(); });
    $('#user_client_filter').on('change', function (e) { user_execute_filters(); });
    $('#user_type_filter').on('change', function (e) { user_execute_filters(); });
}
function user_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {"user_email_filter": $('#user_email_filter').val(),
            "user_empno_filter": $('#user_empno_filter').val(),
            "user_client_filter": $('#user_client_filter option:selected').val(),
            "user_type_filter": $('#user_type_filter option:selected').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

