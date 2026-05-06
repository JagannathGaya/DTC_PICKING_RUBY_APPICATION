$(document).ready(function(){
    receipt_upload_filter_change();
});

function receipt_upload_filter_change() {
    $('#receipt_upload_status_filter').on('change', function (e) { receipt_upload_execute_filters(); });
    $('#receipt_upload_po_ref_filter').on('change', function (e) { receipt_upload_execute_filters(); });
    $('#receipt_upload_vendor_filter').on('change', function (e) { receipt_upload_execute_filters(); });
    $('#receipt_upload_delivery_type_filter').on('change', function (e) { receipt_upload_execute_filters(); });
    $('#rudt_expected_date2_filter').on('change', function (e) { receipt_upload_execute_filters(); });
}

function receipt_upload_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {"receipt_upload_status_filter": $('#receipt_upload_status_filter option:selected').val(),
            "receipt_upload_po_ref_filter": $('#receipt_upload_po_ref_filter').val(),
            "receipt_upload_vendor_filter": $('#receipt_upload_vendor_filter option:selected').val(),
            "receipt_upload_delivery_type_filter": $('#receipt_upload_delivery_type_filter option:selected').val(),
            "rudt_expected_date1_filter": $('#rudt_expected_date1_filter').val(),
            "rudt_expected_date2_filter": $('#rudt_expected_date2_filter').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

