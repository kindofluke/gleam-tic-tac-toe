import gleam/erlang/process
import gleam/http.{Get}
import lustre/attribute
import lustre/element
import lustre/element/html
import mist
import wisp.{type Request, type Response}
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(priv_directory) = wisp.priv_directory("server")
  let static_directory = priv_directory <> "/static"

  let assert Ok(_) =
    handle_request(static_directory, _)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start

  process.sleep_forever()
}

fn app_middleware(
  req: Request,
  static_directory: String,
  next: fn(Request) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: static_directory)

  next(req)
}

fn handle_request(static_directory: String, req: Request) -> Response {
  use req <- app_middleware(req, static_directory)

  case req.method, wisp.path_segments(req) {
    Get, [] -> {
      let game_id = wisp.random_string(8)
      wisp.redirect("/game/" <> game_id)
    }
    Get, ["game", _id] -> serve_index()
    _, _ -> wisp.not_found()
  }
}

fn serve_index() -> Response {
  let html =
    html.html([], [
      html.head([], [
        html.title([], "Tic Tac Toe"),
        html.script(
          [attribute.type_("module"), attribute.src("/static/client.js")],
          "",
        ),

        html.style(
          [],
          "
          :root {
            --lime-cream: #edf67dff;
            --pink-carnation: #f896d8ff;
            --mauve-magic: #ca7df9ff;
            --majorelle-blue: #724cf9ff;
            --dusty-grape: #564592ff;
          }
          body {
            background-color: black;
            color: var(--lime-cream);
            font-family: 'Courier New', Courier, monospace;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            text-shadow: 0 0 5px var(--lime-cream);
          }
          #app {
            text-align: center;
          }
          .board {
            display: grid;
            grid-template-columns: repeat(3, 100px);
            grid-template-rows: repeat(3, 100px);
            gap: 5px;
            margin: 20px auto;
            background-color: var(--majorelle-blue);
            padding: 5px;
            border-radius: 10px;
            box-shadow: 0 0 20px var(--majorelle-blue);
          }
          .cell {
            background-color: black;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 4rem;
            cursor: pointer;
            transition: all 0.2s;
            color: var(--pink-carnation);
            text-shadow: 0 0 10px var(--pink-carnation);
          }
          .cell:hover {
            background-color: var(--dusty-grape);
          }
          .cell.x {
            color: var(--lime-cream);
            text-shadow: 0 0 10px var(--lime-cream);
          }
          .cell.o {
            color: var(--mauve-magic);
            text-shadow: 0 0 10px var(--mauve-magic);
          }
          h1 {
            color: var(--pink-carnation);
            text-shadow: 0 0 10px var(--pink-carnation);
            text-transform: uppercase;
            letter-spacing: 5px;
          }
          .status {
            font-size: 1.5rem;
            margin-top: 20px;
            color: var(--lime-cream);
            transition: all 0.3s;
          }
          .status.win {
            font-size: 3rem;
            color: var(--pink-carnation);
            text-shadow: 0 0 20px var(--pink-carnation);
            animation: blink 1s infinite;
          }
          @keyframes blink {
            0% { opacity: 1; }
            50% { opacity: 0.3; }
            100% { opacity: 1; }
          }
          button {
            background-color: transparent;
            border: 2px solid var(--pink-carnation);
            color: var(--pink-carnation);
            padding: 10px 20px;
            font-size: 1.2rem;
            font-family: inherit;
            cursor: pointer;
            margin-top: 20px;
            text-transform: uppercase;
            transition: all 0.2s;
            box-shadow: 0 0 10px var(--pink-carnation) inset, 0 0 10px var(--pink-carnation);
          }
          button:hover {
            background-color: var(--pink-carnation);
            color: black;
          }
          ",
        ),
      ]),
      html.body([], [html.div([attribute.id("app")], [])]),
    ])

  html
  |> element.to_document_string
  |> wisp.html_response(200)
}
