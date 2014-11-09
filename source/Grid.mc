class Grid {
    static const GRID_SIZE = 4;

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
            grid.slideUp();
        } else if (dir == DIR_RIGHT) {
            grid.slideRight();
        } else if (dir == DIR_DOWN) {
            grid.slideDown(true);
        } else if (dir == DIR_LEFT) {
            grid.slideLeft();
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

        for (var row = 0; !moves && (row < GRID_SIZE); ++row) {
            for (var col = 0; !moves && (col < (GRID_SIZE / 2)); ++col) {
                var curIdx = GRID_SIZE * row + col;

                // Check above
                if (row != 0) {
                    var upIdx = GRID_SIZE * (row - 1) + col;
                    moves = moves || (tiles[curIdx] == tiles[upIdx]);
                }

                // Check to the left
                if (col != 0) {
                    var leftIdx = GRID_SIZE * row + (col - 1);
                    moves = moves || (tiles[curIdx] == tiles[leftIdx]);
                }

                // Check to the right
                if (col != (GRID_SIZE - 1)) {
                    var rightIdx = GRID_SIZE * row + (col + 1);
                    moves = moves || (tiles[curIdx] == tiles[rightIdx]);
                }

                // Check below
                if (row != (GRID_SIZE - 1)) {
                    var downIdx = GRID_SIZE * (row + 1) + col;
                    moves = moves || (tiles[curIdx] == tiles[downIdx]);
                }
            }
        }

        return moves;
    }

    hidden function rotateClockwise() {
        // Mirror across row
        for (var row = 0; row < GRID_SIZE; ++row) {
            for (var col = 0; col < (GRID_SIZE / 2); ++col) {
                var curIdx = GRID_SIZE * row + col;
                var newIdx = GRID_SIZE * row + (GRID_SIZE - col - 1);

                tiles[newIdx] ^= tiles[curIdx];
                tiles[curIdx] ^= tiles[newIdx];
                tiles[newIdx] ^= tiles[curIdx];
            }
        }

        // Copy all values to the temporary array and
        // reset the tiles array
        var tempArr = new [GRID_SIZE * GRID_SIZE];
        for (var i = 0; i < tempArr.size(); ++i) {
            tempArr[i] = tiles[i];
            tiles[i] = 0;
        }

        // Mirror across diagonal
        for (var row = 0; row < GRID_SIZE; ++row) {
            for (var col = 0; col < GRID_SIZE; ++col) {
                var curIdx = GRID_SIZE * row + col;
                var newIdx = tiles.size() - 1 - row - (GRID_SIZE * col);

                tiles[newIdx] = tempArr[curIdx];
            }
        }
    }

    hidden function slideUp() {
        // Slide up is the same as rotating the grid clockwise
        // 180 degrees, sliding down then rotating another 180 degrees
        rotateClockwise();
        rotateClockwise();

        slideDown(true);

        rotateClockwise();
        rotateClockwise();
    }

    hidden function slideLeft() {
        // Slide left is the same as rotating the grid clockwise
        // 270 degrees, sliding down then rotating another 90 degrees
        rotateClockwise();
        rotateClockwise();
        rotateClockwise();

        slideDown(true);

        rotateClockwise();
    }

    hidden function slideRight() {
        // Slide right is the same as rotating the grid clockwise
        // 90 degrees, sliding down then rotating another 270 degrees
        rotateClockwise();

        slideDown(true);

        rotateClockwise();
        rotateClockwise();
        rotateClockwise();
    }

    hidden function slideDown(combine) {
        for (var col = 0; col < GRID_SIZE; ++col) {
            for (var row = GRID_SIZE - 1; row >= 0; --row) {
                var curIdx = GRID_SIZE * row + col;
                if (tiles[curIdx] == 0) {
                    for (var subRow = row; subRow >= 0; --subRow) {
                        var subIdx = GRID_SIZE * subRow + col;
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
                for (var row = GRID_SIZE - 1; row > 0; --row) {
                    var curIdx = GRID_SIZE * row + col;
                    var nextIdx = GRID_SIZE * (row - 1) + col;

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
    hidden var tiles = new [GRID_SIZE * GRID_SIZE];
}
