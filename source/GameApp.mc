using Toybox.Application as App;

class GameApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new PlayView(), new PlayDelegate() ];
    }
}
