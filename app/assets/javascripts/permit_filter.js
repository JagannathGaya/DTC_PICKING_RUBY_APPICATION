$(document).ready(function(){
    permit_filter_change();
});

function permit_filter_change() {
    $('#permit_report_filter').on('change', function (e) { permit_execute_filters(); });
    $('#permit_client_filter').on('change', function (e) { permit_execute_filters(); });
    $('#permit_user_filter').on('change', function (e) { permit_execute_filters(); });
}
function permit_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {"permit_report_filter": $('#permit_report_filter option:selected').val(),
            "permit_client_filter": $('#permit_client_filter option:selected').val(),
            "permit_user_filter": $('#permit_user_filter option:selected').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

