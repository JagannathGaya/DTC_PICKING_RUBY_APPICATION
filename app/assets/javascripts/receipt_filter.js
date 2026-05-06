$(document).ready(function(){
    receipt_filter_change();
});

function receipt_filter_change() {
    $('#rct_item_no_filter').on('change', function (e) { receipt_execute_filters(); });
    $('#rct_product_group_filter').on('change', function (e) { receipt_execute_filters(); });
    $('#rct_product_code_filter').on('change', function (e) { receipt_execute_filters(); });
    $('#rct_trans_date2_filter').on('change', function (e) { receipt_execute_filters(); });
    $('#rct_description_filter').on('change', function (e) { receipt_execute_filters(); });
    $('#rct_ref_remark_filter').on('change', function (e) { receipt_execute_filters(); });
    $('#rct_vendor_id_filter').on('change', function (e) { receipt_execute_filters(); });
    $('#rct_buyer_code_filter').on('change', function (e) { receipt_execute_filters(); });
    $('#rct_trans_type_filter').on('change', function (e) { receipt_execute_filters(); });
}
function receipt_execute_filters() {
    jQuery.ajax({
        url: "/filter",
        type: "PUT",
        data: {"rct_item_no_filter": $('#rct_item_no_filter option:selected').val(),
            "rct_product_group_desc_filter": $('#rct_product_group_filter option:selected').val(),
            "rct_product_code_desc_filter": $('#rct_product_code_filter option:selected').val(),
            "rct_trans_date1_filter": $('#rct_trans_date1_filter').val(),
            "rct_trans_date2_filter": $('#rct_trans_date2_filter').val(),
            "rct_description_filter": $('#rct_description_filter').val(),
            "rct_ref_remark_filter": $('#rct_ref_remark_filter').val(),
            "rct_vendor_id_filter": $('#rct_vendor_id_filter option:selected').val(),
            "rct_buyer_code_desc_filter": $('#rct_buyer_code_filter option:selected').val(),
            "rct_trans_type_filter": $('#rct_trans_type_filter option:selected').val(),
            "redirect_to": window.location.href },
        dataType: "json",
        success: function (data) {
            window.location.href = data.new_url;
        }
    });
}



