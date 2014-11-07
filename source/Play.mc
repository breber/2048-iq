using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class PlayDelegate extends Ui.InputDelegate {
    function onTap() {
        Ui.pushView(new GameView(), new GameDelegate(), Ui.SLIDE_IMMEDIATE);
    }
}

class PlayView extends Ui.View {
    //! Update the view
    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.clear();

        var height = dc.getHeight();
        var width = dc.getWidth();

        dc.drawText(width / 2, height / 2,
            Gfx.FONT_MEDIUM, "Click to Play!", Gfx.TEXT_JUSTIFY_CENTER);

        dc.drawText(width / 2, height / 2 + 30,
            Gfx.FONT_SMALL, "High Score: " + Score.getHighScore(), Gfx.TEXT_JUSTIFY_CENTER);
    }
}