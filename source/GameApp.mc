using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class GameApp extends App.AppBase {
    function getInitialView() {
        return [ new GameView(), new GameDelegate() ];
    }
}
