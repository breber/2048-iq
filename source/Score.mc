using Toybox.Application as App;

enum
{
    CURRENT_SCORE_KEY,
    HIGH_SCORE_KEY
}

class Score {
    static function getHighScore() {
        var app = App.getApp();
        var highScore = app.getProperty(HIGH_SCORE_KEY);
        return (highScore == null) ? 0 : highScore;
    }

    static function getCurrentScore() {
        var app = App.getApp();
        var currentScore = app.getProperty(CURRENT_SCORE_KEY);

        return (currentScore == null) ? 0 : currentScore;
    }

    static function addToCurrentScore(value) {
        var app = App.getApp();
        var newScore = getCurrentScore() + value;
        app.setProperty(CURRENT_SCORE_KEY, newScore);

        if (newScore > getHighScore()) {
            app.setProperty(HIGH_SCORE_KEY, newScore);
        }
    }

    static function resetCurrentScore() {
        var app = App.getApp();
        app.setProperty(CURRENT_SCORE_KEY, 0);
    }
}
