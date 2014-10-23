using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class GameDelegate extends Ui.InputDelegate {

}

class GameView extends Ui.View {
    const numRowsColumns = 4;

    var tiles = new [16];

    function onLayout(dc) {
        for (var i = 0; i < 2; ++i) {
            var tilePos;

            var filled = true;
            while (filled) {
                tilePos = Math.rand() % 16;
                filled = (tiles[tilePos] != null);
            }

            tiles[tilePos] = ((Math.rand() % 4) == 0) ? 4 : 2;
        }
    }

    //! Update the view
    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_WHITE);
        dc.clear();

        var height = dc.getHeight();
        var width = dc.getWidth();

        // Draw the Grid
        var cellSize = height / numRowsColumns;

        for (var i = 1; i < numRowsColumns; ++i) {
            var y = i * cellSize;
            dc.drawLine(width / 2 - (2 * cellSize), y, width / 2 + (2 * cellSize), y);
        }

        for (var i = -numRowsColumns / 2; i < numRowsColumns / 2 + 1; ++i) {
            var x = (width / 2) - (i * cellSize);
            dc.drawLine(x, 0, x, height);
        }


        Sys.println(tiles);

        // Draw the tiles
        for (var i = 0; i < tiles.size(); ++i) {
            var row = i / numRowsColumns;
            var col = i % numRowsColumns;

            var rowPos = (row * cellSize);
            var colPos = (width / 2) - ((2 - col) * cellSize);

            var bgColor = getTileColor(tiles[i]);
            dc.setColor(bgColor, Gfx.COLOR_WHITE);
            dc.fillRectangle(colPos, rowPos, cellSize, cellSize);

            dc.setColor(Gfx.COLOR_WHITE, bgColor);
            dc.drawText(colPos + cellSize / 2, rowPos + 3 * cellSize / 4,
                Gfx.FONT_MEDIUM, tiles[i] + "", Gfx.TEXT_JUSTIFY_CENTER);
        }
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
                // TODO
            } else if (tile == 1024) {
                // TODO
            } else if (tile == 2048) {
                // TODO
            }
        }

        return Gfx.COLOR_TRANSPARENT;
    }
}