using Toybox.Application as App;

class GameApp extends App.AppBase {
    function getInitialView() {
        return [ new PlayView(), new PlayDelegate() ];
    }
}
