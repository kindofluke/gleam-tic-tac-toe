import gleam/int
import gleam/list
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import tic_tac_toe.{
  type Board, type GameState, type Player, Draw, Empty, InProgress, O, Occupied,
  Win, X,
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(board: Board, current_player: Player, game_state: GameState)
}

fn init(_) -> #(Model, Effect(Msg)) {
  let board = tic_tac_toe.initial_board()
  let model = Model(board: board, current_player: X, game_state: InProgress)
  #(model, effect.none())
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  UserClickedSquare(x: Int, y: Int)
  UserClickedRestart
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserClickedSquare(x, y) -> {
      case model.game_state {
        InProgress -> {
          case tic_tac_toe.play(model.board, model.current_player, x, y) {
            Ok(new_board) -> {
              let new_state = tic_tac_toe.get_game_state(new_board)
              let next_player = case model.current_player {
                X -> O
                O -> X
              }
              #(
                Model(
                  board: new_board,
                  current_player: next_player,
                  game_state: new_state,
                ),
                effect.none(),
              )
            }
            Error(_) -> #(model, effect.none())
          }
        }
        _ -> #(model, effect.none())
      }
    }
    UserClickedRestart -> {
      let board = tic_tac_toe.initial_board()
      #(
        Model(board: board, current_player: X, game_state: InProgress),
        effect.none(),
      )
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.h1([], [html.text("Tic Tac Toe")]),
    view_board(model.board),
    view_status(model),
    html.button([event.on_click(UserClickedRestart)], [html.text("Restart")]),
  ])
}

fn view_board(board: Board) -> Element(Msg) {
  html.div(
    [attribute.class("board")],
    list.map([0, 1, 2], fn(y) {
      list.map([0, 1, 2], fn(x) {
        let cell =
          list.find(board, fn(c) { c.square.x == x && c.square.y == y })
        case cell {
          Ok(c) -> view_cell(c.state, x, y)
          Error(_) -> html.div([attribute.class("cell")], [])
        }
      })
    })
      |> list.flatten,
  )
}

fn view_cell(state: tic_tac_toe.CellState, x: Int, y: Int) -> Element(Msg) {
  let class_name = case state {
    Empty -> "cell"
    Occupied(X) -> "cell x"
    Occupied(O) -> "cell o"
  }

  let content = case state {
    Empty -> ""
    Occupied(X) -> "X"
    Occupied(O) -> "O"
  }

  html.div(
    [attribute.class(class_name), event.on_click(UserClickedSquare(x, y))],
    [html.text(content)],
  )
}

fn view_status(model: Model) -> Element(Msg) {
  let #(status_text, class_name) = case model.game_state {
    InProgress ->
      #("Player " <> player_to_string(model.current_player) <> "'s turn", "status")
    Win(player) -> #(player_to_string(player) <> " wins!", "status win")
    Draw -> #("It's a draw!", "status")
  }

  html.div([attribute.class(class_name)], [html.text(status_text)])
}

fn player_to_string(player: Player) -> String {
  case player {
    X -> "X"
    O -> "O"
  }
}
