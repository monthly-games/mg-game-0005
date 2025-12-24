import 'dart:math';

enum BlockType { sword, shield, potion, coin, mana }

class PuzzleBlock {
  BlockType type;
  bool isSelected = false;

  PuzzleBlock({required this.type});
}

class PuzzleBoard {
  static const int rows = 6;
  static const int cols = 6;
  final List<List<PuzzleBlock?>> grid;
  final Random _rng = Random();

  PuzzleBoard()
    : grid = List.generate(rows, (_) => List.generate(cols, (_) => null)) {
    _fillBoard();
  }

  void _fillBoard() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] == null) {
          grid[r][c] = PuzzleBlock(type: _getRandomType());
        }
      }
    }
  }

  BlockType _getRandomType() {
    return BlockType.values[_rng.nextInt(BlockType.values.length)];
  }

  // Interaction State
  Point<int>? _selectedIndex;

  // New method to handle logic for UI
  void selectBlock(int row, int col) {
    if (_selectedIndex == null) {
      // First selection
      _selectedIndex = Point(row, col);
      grid[row][col]?.isSelected = true;
    } else {
      // Second selection
      final prev = _selectedIndex!;
      if (prev.x == row && prev.y == col) {
        // Deselect
        grid[prev.x][prev.y]?.isSelected = false;
        _selectedIndex = null;
      } else if ((prev.x - row).abs() + (prev.y - col).abs() == 1) {
        // Adjacent -> Swap
        grid[prev.x][prev.y]?.isSelected = false;
        _selectedIndex = null;

        // Perform Swap
        _swapAndProcess(prev.x, prev.y, row, col);
      } else {
        // Too far -> Change selection
        grid[prev.x][prev.y]?.isSelected = false;
        _selectedIndex = Point(row, col);
        grid[row][col]?.isSelected = true;
      }
    }
  }

  /// Event callback for when matches occur (handled by DungeonManager)
  Function(List<BlockType> matchedTypes)? onMatch;

  void _swapAndProcess(int r1, int c1, int r2, int c2) {
    // 1. Swap
    final temp = grid[r1][c1];
    grid[r1][c1] = grid[r2][c2];
    grid[r2][c2] = temp;

    // 2. Check Matches
    final matches = _findMatches();

    if (matches.isNotEmpty) {
      // 3. Process Valid Swap
      _processMatches(matches);
    } else {
      // 4. Invalid Swap -> Revert
      final tempBack = grid[r1][c1];
      grid[r1][c1] = grid[r2][c2];
      grid[r2][c2] = tempBack;
    }
  }

  Set<Point<int>> _findMatches() {
    final matchedPoints = <Point<int>>{};

    // Horizontal
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols - 2; c++) {
        final t1 = grid[r][c]?.type;
        final t2 = grid[r][c + 1]?.type;
        final t3 = grid[r][c + 2]?.type;
        if (t1 != null && t1 == t2 && t1 == t3) {
          matchedPoints.add(Point(r, c));
          matchedPoints.add(Point(r, c + 1));
          matchedPoints.add(Point(r, c + 2));
        }
      }
    }

    // Vertical
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows - 2; r++) {
        final t1 = grid[r][c]?.type;
        final t2 = grid[r + 1][c]?.type;
        final t3 = grid[r + 2][c]?.type;
        if (t1 != null && t1 == t2 && t1 == t3) {
          matchedPoints.add(Point(r, c));
          matchedPoints.add(Point(r + 1, c));
          matchedPoints.add(Point(r + 2, c));
        }
      }
    }
    return matchedPoints;
  }

  void _processMatches(Set<Point<int>> matches) {
    final matchedTypes = <BlockType>[];

    // Collect types and Remove Blocks
    for (final p in matches) {
      if (grid[p.x][p.y] != null) {
        matchedTypes.add(grid[p.x][p.y]!.type);
        grid[p.x][p.y] = null;
      }
    }

    // Notify System
    onMatch?.call(matchedTypes);

    // Gravity & Refill
    _applyGravity();

    // Check Chain Reactions (Simplification: just one pass for MVP)
    // In full version, this would be recursive with delays
    final newMatches = _findMatches();
    if (newMatches.isNotEmpty) {
      _processMatches(newMatches);
    }
  }

  void _applyGravity() {
    for (int c = 0; c < cols; c++) {
      int writeRow = rows - 1;

      // Shift down
      for (int r = rows - 1; r >= 0; r--) {
        if (grid[r][c] != null) {
          grid[writeRow][c] = grid[r][c];
          if (writeRow != r) grid[r][c] = null;
          writeRow--;
        }
      }

      // Fill Top
      while (writeRow >= 0) {
        grid[writeRow][c] = PuzzleBlock(type: _getRandomType());
        writeRow--;
      }
    }
  }
}
