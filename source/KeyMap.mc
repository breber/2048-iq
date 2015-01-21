using Toybox.WatchUi as Ui;

enum
{
    DIR_LEFT,
    DIR_RIGHT,
    DIR_UP,
    DIR_DOWN,
    DIR_UNKNOWN
}

function getDirectionKey(key) {
    var device = Ui.loadResource(Rez.Strings.device);

    // FR920
    if ("fr920xt".equals(device)) {
        if (key == Ui.KEY_UP) {
            return DIR_UP;
        } else if (key == Ui.KEY_DOWN) {
            return DIR_DOWN;
        } else if (key == Ui.KEY_ENTER) {
            return DIR_RIGHT;
        } else if (key == Ui.KEY_ESC) {
            return DIR_LEFT;
        }
    }
    // epix
    if ("epix".equals(device)) {
        if (key == Ui.KEY_UP) {
            return DIR_UP;
        } else if (key == Ui.KEY_DOWN) {
            return DIR_DOWN;
        }
        // Remove these for now, since they don't
        // have a clear mapping
        //else if (key == Ui.KEY_ENTER) {
        //    return DIR_RIGHT;
        //} else if (key == Ui.KEY_ESC) {
        //    return DIR_LEFT;
        //}
    }
    // fenix3
    if ("fenix3".equals(device)) {
        if (key == Ui.KEY_UP) {
            return DIR_UP;
        } else if (key == Ui.KEY_DOWN) {
            return DIR_DOWN;
        } else if (key == Ui.KEY_ENTER) {
            return DIR_RIGHT;
        } else if (key == Ui.KEY_ESC) {
            return DIR_LEFT;
        }
    }

    return DIR_UNKNOWN;
}

function getDirectionSwipe(swipe) {
    if (swipe == Ui.SWIPE_UP) {
        return DIR_UP;
    } else if (swipe == Ui.SWIPE_LEFT) {
        return DIR_LEFT;
    } else if (swipe == Ui.SWIPE_RIGHT) {
        return DIR_RIGHT;
    } else {
        return DIR_DOWN;
    }
}
