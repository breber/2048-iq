using Toybox.WatchUi as Ui;

enum
{
    DIR_LEFT,
    DIR_RIGHT,
    DIR_UP,
    DIR_DOWN
}

function getDirectionKey(key) {
    // FR920
    if (key == Ui.KEY_UP) {
        return DIR_UP;
    } else if (key == Ui.KEY_DOWN) {
        return DIR_DOWN;
    } else if (key == Ui.KEY_ENTER) {
        return DIR_RIGHT;
    } else if (key == Ui.KEY_ESC) {
        return DIR_LEFT;
    }

    return DIR_DOWN;
}

function getDirectionSwipe(swipe) {
    if (swipe == Ui.SWIPE_DOWN) {
        return DIR_DOWN;
    } else if (swipe == Ui.SWIPE_LEFT) {
        return DIR_LEFT;
    } else if (swipe == Ui.SWIPE_RIGHT) {
        return DIR_RIGHT;
    } else {
        return DIR_UP;
    }
}
