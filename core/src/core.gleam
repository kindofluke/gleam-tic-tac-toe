import input.{input}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import tic_tac_toe.{
  type Board, type Player, Draw, Empty, InProgress, O, Occupied, Win, X,
}

pub fn main() {
  io.println("Welcome to Tic Tac Toe!")
  let board = tic_tac_toe.initial_board()
  game_loop(board, X)
}

fn game_loop(board: Board, current_player: Player) {
  print_board(board)

  case tic_tac_toe.get_game_state(board) {
    Win(player) -> {
      io.println(player_to_string(player) <> " wins!")
    }
    Draw -> {
      io.println("It's a draw!")
    }
    InProgress -> {
      io.println("Player " <> player_to_string(current_player) <> "'s turn.")
      let new_board = get_move(board, current_player)
      let next_player = case current_player {
        X -> O
        O -> X
      }
      game_loop(new_board, next_player)
    }
  }
}

fn get_move(board: Board, player: Player) -> Board {
  case input(prompt: "Enter move (x y): ") {
    Ok(user_input) -> {
      let user_input = string.trim(user_input)
      case string.split(user_input, " ") {
        [x_str, y_str] -> {
          case int.parse(x_str), int.parse(y_str) {
            Ok(x), Ok(y) -> {
              case tic_tac_toe.play(board, player, x, y) {
                Ok(new_board) -> new_board
                Error(msg) -> {
                  io.println("Error: " <> msg)
                  get_move(board, player)
                }
              }
            }
            _, _ -> {
              io.println(
                "Invalid input. Please enter two numbers separated by a space.",
              )
              get_move(board, player)
            }
          }
        }
        _ -> {
          io.println("Invalid input format. Please enter 'x y'.")
          get_move(board, player)
        }
      }
    }
    Error(_) -> {
      io.println("Error reading input.")
      board
    }
  }
}

fn print_board(board: Board) {
  io.println("-------------")
  list.each([0, 1, 2], fn(y) {
    io.print("| ")
    list.each([0, 1, 2], fn(x) {
      let cell = list.find(board, fn(c) { c.square.x == x && c.square.y == y })
      case cell {
        Ok(c) -> {
          case c.state {
            Empty -> io.print("  | ")
            Occupied(p) -> io.print(player_to_string(p) <> " | ")
          }
        }
        Error(_) -> io.print("? | ")
      }
    })
    io.println("\n-------------")
  })
}

fn player_to_string(player: Player) -> String {
  case player {
    X -> "X"
    O -> "O"
  }
}
