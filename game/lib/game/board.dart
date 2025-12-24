import 'dart:math';

/// 2048 게임 보드
class Board {
  final int size;
  late List<List<int>> grid;
  int score = 0;
  bool isGameOver = false;
  bool hasWon = false;

  Board({this.size = 4}) {
    reset();
  }

  /// 게임 초기화
  void reset() {
    grid = List.generate(size, (_) => List.filled(size, 0));
    score = 0;
    isGameOver = false;
    hasWon = false;
    _addRandomTile();
    _addRandomTile();
  }

  /// 랜덤 위치에 타일 추가 (2 또는 4)
  void _addRandomTile() {
    final emptyCells = <({int row, int col})>[];
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (grid[row][col] == 0) {
          emptyCells.add((row: row, col: col));
        }
      }
    }

    if (emptyCells.isEmpty) return;

    final random = Random();
    final cell = emptyCells[random.nextInt(emptyCells.length)];
    grid[cell.row][cell.col] = random.nextDouble() < 0.9 ? 2 : 4;
  }

  /// 왼쪽으로 이동
  bool moveLeft() {
    return _move(_slideLeft);
  }

  /// 오른쪽으로 이동
  bool moveRight() {
    return _move(_slideRight);
  }

  /// 위로 이동
  bool moveUp() {
    return _move(_slideUp);
  }

  /// 아래로 이동
  bool moveDown() {
    return _move(_slideDown);
  }

  /// 이동 처리
  bool _move(void Function() slideFunc) {
    final oldGrid = _copyGrid();
    slideFunc();

    final hasMoved = !_gridsEqual(oldGrid, grid);
    if (hasMoved) {
      _addRandomTile();
      _checkGameState();
    }

    return hasMoved;
  }

  /// 왼쪽 슬라이드
  void _slideLeft() {
    for (int row = 0; row < size; row++) {
      final line = _mergeLine(grid[row]);
      grid[row] = line;
    }
  }

  /// 오른쪽 슬라이드
  void _slideRight() {
    for (int row = 0; row < size; row++) {
      final reversed = grid[row].reversed.toList();
      final merged = _mergeLine(reversed);
      grid[row] = merged.reversed.toList();
    }
  }

  /// 위로 슬라이드
  void _slideUp() {
    for (int col = 0; col < size; col++) {
      final column = List.generate(size, (row) => grid[row][col]);
      final merged = _mergeLine(column);
      for (int row = 0; row < size; row++) {
        grid[row][col] = merged[row];
      }
    }
  }

  /// 아래로 슬라이드
  void _slideDown() {
    for (int col = 0; col < size; col++) {
      final column = List.generate(size, (row) => grid[row][col]);
      final reversed = column.reversed.toList();
      final merged = _mergeLine(reversed);
      final result = merged.reversed.toList();
      for (int row = 0; row < size; row++) {
        grid[row][col] = result[row];
      }
    }
  }

  /// 한 줄 병합
  List<int> _mergeLine(List<int> line) {
    // 0이 아닌 값들만 추출
    final nonZero = line.where((n) => n != 0).toList();
    final result = <int>[];

    int i = 0;
    while (i < nonZero.length) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        // 병합
        final merged = nonZero[i] * 2;
        result.add(merged);
        score += merged;
        i += 2;
      } else {
        result.add(nonZero[i]);
        i++;
      }
    }

    // 나머지를 0으로 채움
    while (result.length < size) {
      result.add(0);
    }

    return result;
  }

  /// 게임 상태 확인
  void _checkGameState() {
    // 2048 달성 확인
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (grid[row][col] == 2048 && !hasWon) {
          hasWon = true;
          return;
        }
      }
    }

    // 게임 오버 확인
    if (!_canMove()) {
      isGameOver = true;
    }
  }

  /// 이동 가능 여부 확인
  bool _canMove() {
    // 빈 칸이 있는지 확인
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (grid[row][col] == 0) return true;
      }
    }

    // 인접한 같은 숫자가 있는지 확인
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        final value = grid[row][col];

        // 오른쪽 확인
        if (col < size - 1 && grid[row][col + 1] == value) return true;

        // 아래 확인
        if (row < size - 1 && grid[row + 1][col] == value) return true;
      }
    }

    return false;
  }

  /// 그리드 복사
  List<List<int>> _copyGrid() {
    return List.generate(
      size,
      (row) => List.from(grid[row]),
    );
  }

  /// 그리드 동일성 확인
  bool _gridsEqual(List<List<int>> a, List<List<int>> b) {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (a[row][col] != b[row][col]) return false;
      }
    }
    return true;
  }

  /// 최고 타일 값
  int get maxTile {
    int max = 0;
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (grid[row][col] > max) {
          max = grid[row][col];
        }
      }
    }
    return max;
  }
}
