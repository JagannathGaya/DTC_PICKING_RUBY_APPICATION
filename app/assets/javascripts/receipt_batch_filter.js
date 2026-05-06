$(document).ready(function(){
    receipt_batch_filter_change();
});

function receipt_batch_filter_change() {
    $('#receipt_batch_status_filter').on('change', function (e) { receipt_batch_execute_filters(); });
    $('#receipt_batch_po_ref_filter').on('change', function (e) { receipt_batch_execute_filters(); });
    $('#receipt_batch_vendor_filter').on('change', function (e) { receipt_batch_execute_filters(); });
}

function receipt_batch_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {"receipt_batch_status_filter": $('#receipt_batch_status_filter option:selected').val(),
            "receipt_batch_po_ref_filter": $('#receipt_batch_po_ref_filter').val(),
            "receipt_batch_vendor_filter": $('#receipt_batch_vendor_filter option:selected').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}

