using Grid as Grid;
using Score as Score;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

var grid = null;
var screenHeight = 0;
var upDownMinX = 0;
var gameQuit = false;

class QuitDelegate extends Ui.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(value) {
        if (value == Ui.CONFIRM_YES) {
            if (grid != null) {
                grid.saveGame();
            }
            gameQuit = true;
            Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
    }
}

class GameDelegate extends Ui.InputDelegate {
    function initialize() {
        InputDelegate.initialize();
    }

    function onTap(evt) {
        if (!handleGameOver() && (grid != null)) {
            // Process taps on up/down arrows
            var coord = evt.getCoordinates();
            if (coord[0] > upDownMinX) {
                if (coord[1] < (screenHeight / 2)) {
                    grid.processMove(DIR_UP);
                } else {
                    grid.processMove(DIR_DOWN);
                }

                Ui.requestUpdate();
            }
        }
    }

    function onKey(evt) {
        if (evt.getKey() == Ui.KEY_MENU) {
            Ui.pushView(new Ui.Confirmation("Quit?"), new QuitDelegate(), Ui.SLIDE_IMMEDIATE);
            return true;
        } else if (!handleGameOver() && (grid != null)) {
            grid.processMove(getDirectionKey(evt.getKey()));
            Ui.requestUpdate();

            return true;
        }

        return false;
    }

    function onSwipe(evt) {
        if (!handleGameOver() && (grid != null)) {
            var dir = evt.getDirection();
            grid.processMove(getDirectionSwipe(dir));

            Ui.requestUpdate();
        }
    }

    function handleGameOver() {
        if (grid != null) {
            if (grid.isGameOver()) {
                grid = new Grid.Grid();
                Ui.requestUpdate();

                return true;
            }
        }

        return false;
    }
}

class GameView extends Ui.View {
    hidden var NEEDS_UP_DOWN_ARROWS = false;
    hidden var IS_CIRCULAR_SCREEN = false;

    function initialize(restore_game) {
        View.initialize();
        NEEDS_UP_DOWN_ARROWS = ("true".equals(Ui.loadResource(Rez.Strings.needs_up_down_arrows)));

        var deviceSettings = Sys.getDeviceSettings();
        if (deviceSettings) {
            var shape = deviceSettings.screenShape;
            IS_CIRCULAR_SCREEN = (shape == Sys.SCREEN_SHAPE_ROUND) || (shape == Sys.SCREEN_SHAPE_SEMI_ROUND);
        }
        gameQuit = false;
        grid = new Grid.Grid(restore_game);
    }

    function onLayout(dc) {
        screenHeight = dc.getHeight();
    }

    //! Update the view
    function onUpdate(dc) {
        if (gameQuit) {
            Ui.popView(Ui.SLIDE_IMMEDIATE);
        }

        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
        dc.clear();

        var height = dc.getHeight();
        var width = dc.getWidth();

        // Circle screen handling
        if (IS_CIRCULAR_SCREEN) {
            height = Math.sqrt(Math.pow(height, 2) / 2);
            width = height;
        }

        // Use min of width/height for determining cell size
        var minWidthHeight = height;
        if (width < height) {
            minWidthHeight = width;
        }

        // Draw the tiles
        var cellSize = minWidthHeight / Grid.GRID_SIZE;
        var centerWidth = NEEDS_UP_DOWN_ARROWS ? (cellSize * (Grid.GRID_SIZE / 2)) : (dc.getWidth() / 2);
        var centerHeight = (dc.getHeight() / 2);
        upDownMinX = (cellSize * Grid.GRID_SIZE);

        var tiles = grid.getGrid();
        for (var i = 0; i < tiles.size(); ++i) {
            var row = i / Grid.GRID_SIZE;
            var col = i % Grid.GRID_SIZE;

            var rowPos = centerHeight - ((2 - row) * cellSize);
            var colPos = centerWidth - ((2 - col) * cellSize);

            var bgColor = grid.isGameOver() ? Gfx.COLOR_LT_GRAY : getTileColor(tiles[i]);
            var textColor = grid.isGameOver() ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_WHITE;
            dc.setColor(bgColor, textColor);
            dc.fillRectangle(colPos, rowPos, cellSize, cellSize);

            if (tiles[i] != 0) {
                dc.setColor(textColor, bgColor);

                var text = tiles[i] + "";
                var font = Gfx.FONT_MEDIUM;

                // Choose the right font size for the text
                var textWidth = dc.getTextWidthInPixels(text, font);
                if (textWidth >= cellSize) {
                    font = Gfx.FONT_SMALL;
                }

                var centerCellX = colPos + cellSize / 2;
                var centerCellY = rowPos + cellSize / 2 - dc.getFontHeight(font) / 2;

                dc.drawText(centerCellX, centerCellY,
                    font, text, Gfx.TEXT_JUSTIFY_CENTER);
            }
        }

        // Draw the Grid
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_WHITE);
        for (var i = 1; i < Grid.GRID_SIZE; ++i) {
            var y = centerHeight - ((2 - i) * cellSize);
            dc.drawLine(centerWidth - (2 * cellSize), y, centerWidth + (2 * cellSize), y);
        }

        for (var i = -Grid.GRID_SIZE / 2; i < Grid.GRID_SIZE / 2 + 1; ++i) {
            var x = centerWidth - (i * cellSize);
            dc.drawLine(x, centerHeight - (2 * cellSize), x, centerHeight + (2 * cellSize));
        }

        // Draw up/down arrows
        if (NEEDS_UP_DOWN_ARROWS) {
            drawUpDownArrows(dc);
        }

        if (grid.isGameOver()) {
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - dc.getFontHeight(Gfx.FONT_LARGE),
                Gfx.FONT_LARGE, "GAME OVER!", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2,
                Gfx.FONT_SMALL, "Score: " + Score.getCurrentScore(), Gfx.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawUpDownArrows(dc) {
        var height = dc.getHeight();
        var width = dc.getWidth();

        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.fillRectangle(upDownMinX, 0, (width - upDownMinX), height);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);

        var arrowCenter = upDownMinX + (width - upDownMinX) / 2;
        var arrowHeight = height / 8;
        var arrowWidth = (width - upDownMinX) / 3;

        var arrow = new [3];
        arrow[0] = [arrowCenter, height / 4];
        arrow[1] = [arrowCenter - (arrowWidth / 2), arrow[0][1] + arrowHeight];
        arrow[2] = [arrowCenter + (arrowWidth / 2), arrow[0][1] + arrowHeight];
        dc.fillPolygon(arrow);

        arrow[0] = [arrowCenter, 3 * height / 4];
        arrow[1] = [arrowCenter - (arrowWidth / 2), arrow[0][1] - arrowHeight];
        arrow[2] = [arrowCenter + (arrowWidth / 2), arrow[0][1] - arrowHeight];
        dc.fillPolygon(arrow);
    }

    function getTileColor(tile) {
        if (tile) {
            if (tile == 2) {
                return Gfx.COLOR_LT_GRAY;
            } else if (tile == 4) {
                return Gfx.COLOR_DK_GRAY;
            } else if (tile == 8) {
                return Gfx.COLOR_ORANGE;
            } else if (tile == 16) {
                return Gfx.COLOR_PINK;
            } else if (tile == 32) {
                return Gfx.COLOR_RED;
            } else if (tile == 64) {
                return Gfx.COLOR_DK_RED;
            } else if (tile == 128) {
                return Gfx.COLOR_PURPLE;
            } else if (tile == 256) {
                return Gfx.COLOR_YELLOW;
            } else if (tile == 512) {
                return Gfx.COLOR_GREEN;
            } else if (tile == 1024) {
                return Gfx.COLOR_DK_GREEN;
            } else if (tile == 2048) {
                return Gfx.COLOR_BLUE;
            }
        }

        return Gfx.COLOR_WHITE;
    }
}
