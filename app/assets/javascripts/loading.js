$(document).on('page:fetch', function() {
    $(".loading-indicator").show();
});


$(window).load(function() {
    $(".loading-indicator").hide();
});

