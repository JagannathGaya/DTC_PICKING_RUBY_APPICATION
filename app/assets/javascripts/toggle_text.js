function toggle_text(text,tid) {
    var mytext = document.getElementById(text+tid);
    var displaySetting = mytext.style.display;
    if (displaySetting == 'block') {
        mytext.style.display = 'none';
    }
    else {
        mytext.style.display = 'block';
    }
}
