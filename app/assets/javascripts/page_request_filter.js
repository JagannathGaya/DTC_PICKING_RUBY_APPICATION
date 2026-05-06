$(document).ready(function(){
    page_request_filter_change();
});

function page_request_filter_change() {
    $('#pr_controller_filter').on('change', function (e) { page_request_execute_filters(); });
    $('#pr_action_filter').on('change', function (e) { page_request_execute_filters(); });
    $('#pr_format_filter').on('change', function (e) { page_request_execute_filters(); });
    $('#pr_method_filter').on('change', function (e) { page_request_execute_filters(); });
    $('#pr_status_filter').on('change', function (e) { page_request_execute_filters(); });
    $('#pr_page_runtime_filter').on('change', function (e) { page_request_execute_filters(); });
    $('#pr_view_runtime_filter').on('change', function (e) { page_request_execute_filters(); });
    $('#pr_db_runtime_filter').on('change', function (e) { page_request_execute_filters(); });
}
function page_request_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {"pr_controller_filter": $('#pr_controller_filter option:selected').val(),
            "pr_action_filter": $("#pr_action_filter option:selected").val(),
            "pr_format_filter": $('#pr_format_filter option:selected').val(),
            "pr_method_filter": $('#pr_method_filter option:selected').val(),
            "pr_status_filter": $('#pr_status_filter option:selected').val(),
            "pr_page_runtime_filter": $('#pr_page_runtime_filter').val(),
            "pr_view_runtime_filter": $('#pr_view_runtime_filter').val(),
            "pr_db_runtime_filter": $('#pr_db_runtime_filter').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}
