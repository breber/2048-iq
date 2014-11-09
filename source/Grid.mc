class Grid {
    const numRowsColumns = 4;

    function initialize() {
        Score.resetCurrentScore();

        for (var i = 0; i < tiles.size(); ++i) {
            tiles[i] = 0;
        }

        // Add the first two tiles
        addTile();
        addTile();
    }

    function getGrid() {
        return tiles;
    }

    function isGameOver() {
        return isFull() && !hasValidMoves();
    }

    function processMove(dir) {
        changeMade = false;

        if (dir == DIR_UP) {
            grid.slideUp(true);
        } else if (dir == DIR_RIGHT) {
            grid.slideRight(true);
        } else if (dir == DIR_DOWN) {
            grid.slideDown(true);
        } else if (dir == DIR_LEFT) {
            grid.slideLeft(true);
        }

        // If the board differs, add a tile and update score
        if (changeMade) {
            addTile();
        }
    }

    // Implementation

    hidden function addTile() {
        // Check to make sure we haven't filled the screen
        if (!isFull()) {
            var tilePos = 0;

            // If the entire screen isn't full, randomly
            // find an empty space and fill it with a tile
            var filled = true;
            while (filled) {
                tilePos = Math.rand() % 16;
                filled = (tiles[tilePos] != 0);
            }

            tiles[tilePos] = ((Math.rand() % 4) == 0) ? 4 : 2;
        }
    }

    hidden function isFull() {
        var filled = true;
        for (var i = 0; filled && (i < tiles.size()); ++i) {
            filled = (tiles[i] != 0);
        }

        return filled;
    }

    hidden function hasValidMoves() {
        var moves = false;

        for (var row = 0; !moves && (row < numRowsColumns); ++row) {
            for (var col = 0; !moves && (col < (numRowsColumns / 2)); ++col) {
                var curIdx = numRowsColumns * row + col;

                // Check above
                if (row != 0) {
                    var upIdx = numRowsColumns * (row - 1) + col;
                    moves = moves || (tiles[curIdx] == tiles[upIdx]);
                }

                // Check to the left
                if (col != 0) {
                    var leftIdx = numRowsColumns * row + (col - 1);
                    moves = moves || (tiles[curIdx] == tiles[leftIdx]);
                }

                // Check to the right
                if (col != (numRowsColumns - 1)) {
                    var rightIdx = numRowsColumns * row + (col + 1);
                    moves = moves || (tiles[curIdx] == tiles[rightIdx]);
                }

                // Check below
                if (row != (numRowsColumns - 1)) {
                    var downIdx = numRowsColumns * (row + 1) + col;
                    moves = moves || (tiles[curIdx] == tiles[downIdx]);
                }
            }
        }

        return moves;
    }

    hidden function rotateClockwise() {
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

    hidden function slideUp(combine) {
        // Slide up is the same as rotating the grid clockwise
        // 180 degrees, sliding down then rotating another 180 degrees
        rotateClockwise();
        rotateClockwise();

        slideDown(combine);

        rotateClockwise();
        rotateClockwise();
    }

    hidden function slideLeft(combine) {
        // Slide left is the same as rotating the grid clockwise
        // 270 degrees, sliding down then rotating another 90 degrees
        rotateClockwise();
        rotateClockwise();
        rotateClockwise();

        slideDown(combine);

        rotateClockwise();
    }

    hidden function slideRight(combine) {
        // Slide right is the same as rotating the grid clockwise
        // 90 degrees, sliding down then rotating another 270 degrees
        rotateClockwise();

        slideDown(combine);

        rotateClockwise();
        rotateClockwise();
        rotateClockwise();
    }

    hidden function slideDown(combine) {
        for (var col = 0; col < numRowsColumns; ++col) {
            for (var row = numRowsColumns - 1; row >= 0; --row) {
                var curIdx = numRowsColumns * row + col;
                if (tiles[curIdx] == 0) {
                    for (var subRow = row; subRow >= 0; --subRow) {
                        var subIdx = numRowsColumns * subRow + col;
                        if (tiles[subIdx] != 0) {
                            tiles[curIdx] = tiles[subIdx];
                            tiles[subIdx] = 0;
                            changeMade = true;
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
                        changeMade = true;
                    }
                }
            }
        }

        if (combine) {
            slideDown(false);
        }
    }

    hidden var changeMade = false;
    hidden var tiles = new [numRowsColumns * numRowsColumns];
}
