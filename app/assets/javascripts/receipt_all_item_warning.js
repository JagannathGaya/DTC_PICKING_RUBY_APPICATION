$(document).ready(function(){
    receipt_all_item_warning_change();
});

function receipt_all_item_warning_change() {
    $('#receipt_location_receipt_item_id').on('change', function (e) { receipt_receipt_all_item_warning_change_execute(); });
}

function receipt_receipt_all_item_warning_change_execute() {
    if ($('#receipt_location_receipt_item_id').val() == '-1') {
        alert('You are selecting all remaining items to go to one location, please verify before pressing save.');
    }
}

