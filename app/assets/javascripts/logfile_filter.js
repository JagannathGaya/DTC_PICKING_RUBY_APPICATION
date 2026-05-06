$(document).ready(function(){
    logfile_filter_change();
});

function logfile_filter_change() {
    $('#logfile_filter').on('change', function (e) { logfile_execute_filters(); });
}
function logfile_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {"logfile_filter": $('#logfile_filter option:selected').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

