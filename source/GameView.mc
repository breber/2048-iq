using Grid as Grid;
using Score as Score;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

var grid = null;
var screenHeight = 0;
var upDownMinX = 0;

class GameDelegate extends Ui.InputDelegate {
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
        if (!handleGameOver() && (grid != null)) {
            var key = evt.getKey();
            grid.processMove(getDirectionKey(key));

            Ui.requestUpdate();
        }
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
    hidden var TOUCHSCREEN = "false";

    function initialize() {
        TOUCHSCREEN = ("true".equals(Ui.loadResource(Rez.Strings.has_touchscreen)));
    }

    function onLayout(dc) {
        grid = new Grid.Grid();
        screenHeight = dc.getHeight();
    }

    //! Update the view
    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
        dc.clear();

        var height = dc.getHeight();
        var width = dc.getWidth();

        // Draw the tiles
        var cellSize = height / Grid.GRID_SIZE;
        var centerWidth = TOUCHSCREEN ? (cellSize * (Grid.GRID_SIZE / 2)) : (width / 2);
        upDownMinX = (cellSize * Grid.GRID_SIZE);

        var tiles = grid.getGrid();
        for (var i = 0; i < tiles.size(); ++i) {
            var row = i / Grid.GRID_SIZE;
            var col = i % Grid.GRID_SIZE;

            var rowPos = (row * cellSize);
            var colPos = centerWidth - ((2 - col) * cellSize);

            var bgColor = grid.isGameOver() ? Gfx.COLOR_LT_GRAY : getTileColor(tiles[i]);
            var textColor = grid.isGameOver() ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_WHITE;
            dc.setColor(bgColor, textColor);
            dc.fillRectangle(colPos, rowPos, cellSize, cellSize);

            if (tiles[i] != 0) {
                dc.setColor(textColor, bgColor);

                // Numbers with 4 characters need to be a bit smaller
                // to fit in the square
                if (tiles[i] > 1000) {
                    dc.drawText(colPos + cellSize / 2 + 1, rowPos + .65 * cellSize,
                        Gfx.FONT_SMALL,  tiles[i] + "", Gfx.TEXT_JUSTIFY_CENTER);
                } else {
                    dc.drawText(colPos + cellSize / 2, rowPos + 3 * cellSize / 4,
                        Gfx.FONT_MEDIUM, tiles[i] + "", Gfx.TEXT_JUSTIFY_CENTER);
                }
            }
        }

        // Draw the Grid
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_WHITE);
        for (var i = 1; i < Grid.GRID_SIZE; ++i) {
            var y = i * cellSize;
            dc.drawLine(centerWidth - (2 * cellSize), y, centerWidth + (2 * cellSize), y);
        }

        for (var i = -Grid.GRID_SIZE / 2; i < Grid.GRID_SIZE / 2 + 1; ++i) {
            var x = centerWidth - (i * cellSize);
            dc.drawLine(x, 0, x, height);
        }

        // Draw up/down arrows
        if (TOUCHSCREEN) {
            drawUpDownArrows(dc);
        }

        if (grid.isGameOver()) {
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height / 2,
                Gfx.FONT_LARGE, "GAME OVER!", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(width / 2, height / 2 + 20,
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
