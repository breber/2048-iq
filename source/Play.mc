using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Score as Score;

class RestoreGameDelegate extends Ui.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(value) {
        Ui.pushView(new GameView(value == Ui.CONFIRM_YES), new GameDelegate(), Ui.SLIDE_IMMEDIATE);
    }
}

class PlayDelegate extends Ui.InputDelegate {
    function initialize() {
        InputDelegate.initialize();
    }

    function onTap(evt) {
        pushView();
    }

    function onKey(evt) {
        if (evt.getKey() == Ui.KEY_ENTER) {
            pushView();
        }
    }

    function pushView() {
        var app = App.getApp();
        var savedGame = app.getProperty("saved_game");
        if (savedGame != null) {
            Ui.pushView(new Ui.Confirmation("Restore Game?"), new RestoreGameDelegate(), Ui.SLIDE_IMMEDIATE);
        } else {
            Ui.pushView(new GameView(false), new GameDelegate(), Ui.SLIDE_IMMEDIATE);
        }
    }
}

class PlayView extends Ui.View {
    function initialize() {
        View.initialize();
    }

    //! Update the view
    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLUE);
        dc.clear();

        var height = dc.getHeight();
        var width = dc.getWidth();

        dc.drawText(width / 2, height / 2 - dc.getFontHeight(Gfx.FONT_LARGE),
            Gfx.FONT_LARGE, "2048", Gfx.TEXT_JUSTIFY_CENTER);

        dc.drawText(width / 2, height / 2,
            Gfx.FONT_SMALL, "High Score: " + Score.getHighScore(), Gfx.TEXT_JUSTIFY_CENTER);
    }
}
