using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

const numRowsColumns = 4;
var tiles = new [numRowsColumns * numRowsColumns];
var gameOver = false;

function addTile() {
    // Check to make sure we haven't filled the screen
    var filled = true;
    for (var i = 0; i < tiles.size(); ++i) {
        if (tiles[i] == null) {
            tiles[i] = 0;
        }
        filled = filled && (tiles[i] != 0);
    }

    if (filled) {
        gameOver = true;
    } else {
        var tilePos = 0;

        // If the entire screen isn't full, randomly
        // find an empty space and fill it with a tile
        filled = true;
        while (filled) {
            tilePos = Math.rand() % 16;
            filled = (tiles[tilePos] != 0);
        }

        tiles[tilePos] = ((Math.rand() % 4) == 0) ? 4 : 2;
    }
}

class GameDelegate extends Ui.InputDelegate {
    function printGrid() {
        for (var row = 0; row < numRowsColumns; ++row) {
            for (var col = 0; col < numRowsColumns; ++col) {
                var curIdx = numRowsColumns * row + col;
                Sys.print(tiles[curIdx].format("%4d"));
            }
            Sys.println("");
        }
        Sys.println("");
    }

    function rotateClockwise() {
        // Mirror across row
        for (var row = 0; row < numRowsColumns; ++row) {
            for (var col = 0; col < (numRowsColumns / 2); ++col) {
                var curIdx = numRowsColumns * row + col;
                var newIdx = numRowsColumns * row + (numRowsColumns - col - 1);

                tiles[newIdx] ^= tiles[curIdx];
                tiles[curIdx] ^= tiles[newIdx];
                tiles[newIdx] ^= tiles[curIdx];
            }
        }

        // Copy all values to the temporary array and
        // reset the tiles array
        var tempArr = new [numRowsColumns * numRowsColumns];
        for (var i = 0; i < tempArr.size(); ++i) {
            tempArr[i] = tiles[i];
            tiles[i] = 0;
        }

        // Mirror across diagonal
        for (var row = 0; row < numRowsColumns; ++row) {
            for (var col = 0; col < numRowsColumns; ++col) {
                var curIdx = numRowsColumns * row + col;
                var newIdx = tiles.size() - 1 - row - (numRowsColumns * col);

                tiles[newIdx] = tempArr[curIdx];
            }
        }
    }

    function slideUp(combine) {
        rotateClockwise();
        rotateClockwise();

        slideDown(combine);

        rotateClockwise();
        rotateClockwise();
    }

    function slideLeft(combine) {
        rotateClockwise();
        rotateClockwise();
        rotateClockwise();

        slideDown(combine);

        rotateClockwise();
    }

    function slideRight(combine) {
        rotateClockwise();

        slideDown(combine);

        rotateClockwise();
        rotateClockwise();
        rotateClockwise();
    }

    function slideDown(combine) {
        for (var col = 0; col < numRowsColumns; ++col) {
            for (var row = numRowsColumns - 1; row >= 0; --row) {
                var curIdx = numRowsColumns * row + col;
                if (tiles[curIdx] == 0) {
                    for (var subRow = row; subRow >= 0; --subRow) {
                        var subIdx = numRowsColumns * subRow + col;
                        if (tiles[subIdx] != 0) {
                            tiles[curIdx] = tiles[subIdx];
                            tiles[subIdx] = 0;
                            break;
                        }
                    }
                }
            }

            if (combine) {
                for (var row = numRowsColumns - 1; row > 0; --row) {
                    var curIdx = numRowsColumns * row + col;
                    var nextIdx = numRowsColumns * (row - 1) + col;

                    if ((tiles[curIdx] != 0) &&
                        (tiles[curIdx] == tiles[nextIdx]))
                    {
                        tiles[curIdx] <<= 1;
                        Score.addToCurrentScore(tiles[curIdx]);
                        tiles[nextIdx] = 0;
                        row -= 2;
                    }
                }
            }
        }

        if (combine) {
            slideDown(false);
        }
    }

    function onTap(evt) {
        // Temporarily use tap for up swipe
        onSwipe(new Ui.SwipeEvent(Ui.SWIPE_UP));
    }

    function onHold(evt) {
        // Temporarily use hold for down swipe
        onSwipe(new Ui.SwipeEvent(Ui.SWIPE_DOWN));
    }

    function onSwipe(evt) {
        var dir = evt.getDirection();

        // Build a state of the game before this move
        var preMove = new [numRowsColumns * numRowsColumns];
        for (var i = 0; i < preMove.size(); ++i) {
            preMove[i] = tiles[i];
        }

        if (dir == Ui.SWIPE_UP) {
            slideUp(true);
        } else if (dir == Ui.SWIPE_RIGHT) {
            slideRight(true);
        } else if (dir == Ui.SWIPE_DOWN) {
            slideDown(true);
        } else if (dir == Ui.SWIPE_LEFT) {
            slideLeft(true);
        }

        // Check if the gameboard differs from the pre-move state
        var madeMove = false;
        for (var i = 0; !madeMove && (i < preMove.size()); ++i) {
            madeMove = (preMove[i] != tiles[i]);
        }

        // If the board differs, add a tile and update score
        if (madeMove) {
            addTile();
        }

        Ui.requestUpdate();
    }
}

class GameView extends Ui.View {
    function onLayout(dc) {
        Math.srand(35);
        Score.resetCurrentScore();

        // Add the first two tiles
        addTile();
        addTile();
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

        // Draw the tiles
        for (var i = 0; i < tiles.size(); ++i) {
            var row = i / numRowsColumns;
            var col = i % numRowsColumns;

            var rowPos = (row * cellSize);
            var colPos = (width / 2) - ((2 - col) * cellSize);

            var bgColor = getTileColor(tiles[i]);
            dc.setColor(bgColor, Gfx.COLOR_WHITE);
            dc.fillRectangle(colPos, rowPos, cellSize, cellSize);

            if (tiles[i] != 0) {
                dc.setColor(Gfx.COLOR_WHITE, bgColor);
                dc.drawText(colPos + cellSize / 2, rowPos + 3 * cellSize / 4,
                    Gfx.FONT_MEDIUM, tiles[i] + "", Gfx.TEXT_JUSTIFY_CENTER);
            }
        }

        if (gameOver) {
            dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_WHITE);
            dc.drawText(width / 2, height / 2,
                Gfx.FONT_LARGE, "GAME OVER!", Gfx.TEXT_JUSTIFY_CENTER);
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