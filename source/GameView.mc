using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time;

var grid = new Grid();
var screenHeight = 0;
var upDownMinX = 0;
var gameOver = false;

class GameDelegate extends Ui.InputDelegate {
    function onTap(evt) {
        // Temporarily use tap for up/down swipe
        var coord = evt.getCoordinates();
        if (coord[0] > upDownMinX) {
            if (coord[1] < (screenHeight / 2)) {
                onSwipe(new Ui.SwipeEvent(Ui.SWIPE_UP));
            } else {
                onSwipe(new Ui.SwipeEvent(Ui.SWIPE_DOWN));
            }
        }
    }

    function onSwipe(evt) {
        var dir = evt.getDirection();

        grid.startMove();

        if (dir == Ui.SWIPE_UP) {
            grid.slideUp();
        } else if (dir == Ui.SWIPE_RIGHT) {
            grid.slideRight();
        } else if (dir == Ui.SWIPE_DOWN) {
            grid.slideDown();
        } else if (dir == Ui.SWIPE_LEFT) {
            grid.slideLeft();
        }

        // If the board differs, add a tile and update score
        if (grid.hasChanges()) {
            grid.addTile();
        }

        // If the grid is full, check to make sure
        // that there are still moves that can be made
        if (grid.isFull()) {
            gameOver = !grid.containsValidMoves();
        }

        Ui.requestUpdate();
    }
}

class GameView extends Ui.View {
    function onLayout(dc) {
        Math.srand(Time.now().value());
        Score.resetCurrentScore();

        screenHeight = dc.getHeight();

        // Add the first two tiles
        grid.addTile();
        grid.addTile();
    }

    //! Update the view
    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_WHITE);
        dc.clear();

        var height = dc.getHeight();
        var width = dc.getWidth();

        // Draw the tiles
        var cellSize = height / grid.numRowsColumns;
        var centerWidth = cellSize * (grid.numRowsColumns / 2);
        upDownMinX = (cellSize * grid.numRowsColumns);

        var tiles = grid.getGrid();
        for (var i = 0; i < tiles.size(); ++i) {
            var row = i / grid.numRowsColumns;
            var col = i % grid.numRowsColumns;

            var rowPos = (row * cellSize);
            var colPos = centerWidth - ((2 - col) * cellSize);

            var bgColor = getTileColor(tiles[i]);
            dc.setColor(bgColor, Gfx.COLOR_WHITE);
            dc.fillRectangle(colPos, rowPos, cellSize, cellSize);

            if (tiles[i] != 0) {
                dc.setColor(Gfx.COLOR_WHITE, bgColor);
                dc.drawText(colPos + cellSize / 2, rowPos + 3 * cellSize / 4,
                    Gfx.FONT_MEDIUM, tiles[i] + "", Gfx.TEXT_JUSTIFY_CENTER);
            }
        }

        // Draw up/down arrows
        drawUpDownArrows(dc);

        // Draw the Grid
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_WHITE);
        for (var i = 1; i < grid.numRowsColumns; ++i) {
            var y = i * cellSize;
            dc.drawLine(centerWidth - (2 * cellSize), y, centerWidth + (2 * cellSize), y);
        }

        for (var i = -grid.numRowsColumns / 2; i < grid.numRowsColumns / 2 + 1; ++i) {
            var x = centerWidth - (i * cellSize);
            dc.drawLine(x, 0, x, height);
        }

        if (gameOver) {
            dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_WHITE);
            dc.drawText(width / 2, height / 2,
                Gfx.FONT_LARGE, "GAME OVER!", Gfx.TEXT_JUSTIFY_CENTER);
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
                return Gfx.COLOR_DK_ORANGE;
            } else if (tile == 32) {
                return Gfx.COLOR_RED;
            } else if (tile == 64) {
                return Gfx.COLOR_DK_RED;
            } else if (tile == 128) {
                return Gfx.COLOR_YELLOW;
            } else if (tile == 256) {
                return Gfx.COLOR_DK_YELLOW;
            } else if (tile == 512) {
                return Gfx.COLOR_GREEN;
            } else if (tile == 1024) {
                return Gfx.COLOR_DK_GREEN;
            } else if (tile == 2048) {
                return Gfx.COLOR_BLUE;
            }
        }

        return Gfx.COLOR_TRANSPARENT;
    }
}
