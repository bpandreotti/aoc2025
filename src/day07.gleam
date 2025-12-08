import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/07.txt")
  let #(start, manifold) = parse_input(input)
  io.println("part 1: " <> int.to_string(part1(start, manifold)))
}

fn parse_input(input: String) -> #(Int, List(BitArray)) {
  let assert [first, ..lines] = string.trim(input) |> string.split(on: "\n")
  let assert Ok(#(_, start)) =
    string.to_graphemes(first)
    |> list.index_map(fn(c, i) { #(c, i) })
    |> list.find(fn(pair) {
      let #(c, _) = pair
      c == "S"
    })

  let manifold =
    list.map(lines, fn(l) {
      string.to_graphemes(l)
      |> list.map(fn(c) {
        case c {
          "." -> <<0>>
          "^" -> <<1>>
          _ -> panic as "invalid input"
        }
      })
      |> bit_array.concat
    })

  #(start, manifold)
}

fn dedup(list: List(a)) -> List(a) {
  case list {
    [] -> []
    [a, b, ..rest] if a == b -> dedup([a, ..rest])
    [a, ..rest] -> [a, ..dedup(rest)]
  }
}

fn simulate_row(beams: List(Int), row: BitArray) -> #(Int, List(Int)) {
  case beams {
    [] -> #(0, [])
    [b, ..rest] -> {
      let #(count, rest) = simulate_row(rest, row)
      case bit_array.slice(row, b, 1) {
        Ok(<<1>>) -> #(count + 1, [b - 1, b + 1, ..rest])
        _ -> #(count, [b, ..rest])
      }
    }
  }
}

fn simulate(beams: List(Int), manifold: List(BitArray)) -> Int {
  case manifold {
    [] -> 0
    [row, ..rest] -> {
      let #(splits, new_beams) = simulate_row(beams, row)
      splits + simulate(dedup(new_beams), rest)
    }
  }
}

fn part1(start: Int, manifold: List(BitArray)) -> Int {
  simulate([start], manifold)
}
