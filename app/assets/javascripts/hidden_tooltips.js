$(document).ready(function () {
    tab_fired();
});

function tab_fired() {
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        $(".bsTool").tooltip();
    });
}

