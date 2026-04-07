import gleam/list
import gleam/int

pub type Player {
  X
  O
}

pub type Square {
  Square(x: Int, y: Int, value: Int)
}

pub type CellState {
  Empty
  Occupied(Player)
}

pub type Cell {
  Cell(square: Square, state: CellState)
}

pub type Board =
  List(Cell)

pub type GameState {
  InProgress
  Win(Player)
  Draw
}

pub fn initial_board() -> Board {
  [
    Cell(Square(0, 0, 8), Empty),
    Cell(Square(1, 0, 1), Empty),
    Cell(Square(2, 0, 6), Empty),
    Cell(Square(0, 1, 3), Empty),
    Cell(Square(1, 1, 5), Empty),
    Cell(Square(2, 1, 7), Empty),
    Cell(Square(0, 2, 4), Empty),
    Cell(Square(1, 2, 9), Empty),
    Cell(Square(2, 2, 2), Empty),
  ]
}

pub fn play(board: Board, player: Player, x: Int, y: Int) -> Result(Board, String) {
  let is_valid_move =
    list.any(board, fn(cell) {
      cell.square.x == x && cell.square.y == y && cell.state == Empty
    })

  case is_valid_move {
    True -> {
      let new_board =
        list.map(board, fn(cell) {
          case cell.square.x == x && cell.square.y == y {
            True -> Cell(..cell, state: Occupied(player))
            False -> cell
          }
        })
      Ok(new_board)
    }
    False -> Error("Invalid move")
  }
}

fn combinations_of_3(items: List(Int)) -> List(List(Int)) {
  case items {
    [] -> []
    [x, ..rest] -> {
      let pairs = combinations_of_2(rest)
      let with_x = list.map(pairs, fn(pair) { [x, ..pair] })
      list.append(with_x, combinations_of_3(rest))
    }
  }
}

fn combinations_of_2(items: List(Int)) -> List(List(Int)) {
  case items {
    [] -> []
    [x, ..rest] -> {
      let with_x = list.map(rest, fn(y) { [x, y] })
      list.append(with_x, combinations_of_2(rest))
    }
  }
}

pub fn check_win(board: Board, player: Player) -> Bool {
  let player_values =
    list.filter_map(board, fn(cell) {
      case cell.state {
        Occupied(p) if p == player -> Ok(cell.square.value)
        _ -> Error(Nil)
      }
    })

  let combos = combinations_of_3(player_values)
  list.any(combos, fn(combo) { int.sum(combo) == 15 })
}

pub fn get_game_state(board: Board) -> GameState {
  let x_wins = check_win(board, X)
  let o_wins = check_win(board, O)

  let is_full =
    list.all(board, fn(cell) {
      case cell.state {
        Empty -> False
        Occupied(_) -> True
      }
    })

  case x_wins, o_wins, is_full {
    True, _, _ -> Win(X)
    _, True, _ -> Win(O)
    False, False, True -> Draw
    False, False, False -> InProgress
  }
}
