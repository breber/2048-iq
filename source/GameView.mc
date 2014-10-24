using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

const numRowsColumns = 4;
var tiles = new [numRowsColumns * numRowsColumns];

function addTile() {
    var tilePos;

    var filled = true;
    while (filled) {
        tilePos = Math.rand() % 16;
        filled = (tiles[tilePos] != null);
    }

    tiles[tilePos] = ((Math.rand() % 4) == 0) ? 4 : 2;
}

class GameDelegate extends Ui.InputDelegate {
    function onSwipe(evt) {
        var dir = evt.getDirection();

        if (dir == Ui.SWIPE_UP) {
            Sys.println("up");
            // TODO

            for (var col = 0; col < numRowsColumns; ++col) {
                for (var row = 0; row < numRowsColumns; ++row) {
                    var curIdx = numRowsColumns * row + col;
                    if (tiles[curIdx] == null) {
                        for (var subRow = row + 1; subRow < numRowsColumns; ++subRow) {
                            var subIdx = numRowsColumns * subRow + col;
                            if (tiles[subIdx] != null) {
                                tiles[curIdx] = tiles[subIdx];
                                tiles[subIdx] = null;
                                break;
                            }
                        }
                    }
                }
            }
        } else if (dir == Ui.SWIPE_RIGHT) {
            Sys.println("right");
            // TODO

            for (var row = 0; row < numRowsColumns; ++row) {
                for (var col = numRowsColumns - 1; col >= 0; --col) {
                    var curIdx = numRowsColumns * row + col;
                    if (tiles[curIdx] == null) {
                        for (var subCol = col - 1; subCol >= 0; --subCol) {
                            var subIdx = numRowsColumns * row + subCol;
                            if (tiles[subIdx] != null) {
                                tiles[curIdx] = tiles[subIdx];
                                tiles[subIdx] = null;
                                break;
                            }
                        }
                    }
                }
            }
        } else if (dir == Ui.SWIPE_DOWN) {
            Sys.println("down");
            // TODO

            for (var col = 0; col < numRowsColumns; ++col) {
                for (var row = numRowsColumns - 1; row >= 0; --row) {
                    var curIdx = numRowsColumns * row + col;
                    if (tiles[curIdx] == null) {
                        for (var subRow = row; subRow >= 0; --subRow) {
                            var subIdx = numRowsColumns * subRow + col;
                            if (tiles[subIdx] != null) {
                                tiles[curIdx] = tiles[subIdx];
                                tiles[subIdx] = null;
                                break;
                            }
                        }
                    }
                }
            }
        } else if (dir == Ui.SWIPE_LEFT) {
            Sys.println("left");
            // TODO

            for (var row = 0; row < numRowsColumns; ++row) {
                for (var col = 0; col < numRowsColumns; ++col) {
                    var curIdx = numRowsColumns * row + col;
                    if (tiles[curIdx] == null) {
                        for (var subCol = col + 1; subCol < numRowsColumns; ++subCol) {
                            var subIdx = numRowsColumns * row + subCol;
                            if (tiles[subIdx] != null) {
                                tiles[curIdx] = tiles[subIdx];
                                tiles[subIdx] = null;
                                break;
                            }
                        }
                    }
                }
            }
        }

        addTile();

        Ui.requestUpdate();
    }
}

class GameView extends Ui.View {
    function onLayout(dc) {
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