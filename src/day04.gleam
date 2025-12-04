import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/04.txt")
  io.println("part 1: " <> int.to_string(part1(input)))
}

fn get(array: BitArray, w: Int, x: Int, y: Int) -> Int {
  let h = bit_array.byte_size(array) / w
  case x < 0 || x >= w || y < 0 || y >= h {
    True -> 0
    False ->
      case bit_array.slice(array, w * y + x, 1) {
        Ok(<<0>>) -> 0
        Ok(<<1>>) -> 1
        _ -> panic
      }
  }
}

fn parse_input(input: String) -> #(BitArray, Int) {
  let lines = string.trim(input) |> string.split(on: "\n")
  let array =
    list.map(lines, fn(l) {
      string.to_graphemes(l)
      |> list.map(fn(c) {
        case c {
          "." -> <<0>>
          "@" -> <<1>>
          _ -> panic as "invalid input"
        }
      })
      |> bit_array.concat
    })
    |> bit_array.concat
  let line_size = bit_array.byte_size(array) / list.length(lines)
  #(array, line_size)
}

fn part1(input: String) -> Int {
  let #(array, w) = parse_input(input)
  let h = bit_array.byte_size(array) / w
  list.range(0, h)
  |> list.map(fn(y) {
    list.range(0, w)
    |> list.filter(fn(x) { get(array, w, x, y) == 1 })
    |> list.map(fn(x) {
      // starting from up, going clockwise 
      get(array, w, x, y - 1)
      + get(array, w, x + 1, y - 1)
      + get(array, w, x + 1, y)
      + get(array, w, x + 1, y + 1)
      + get(array, w, x, y + 1)
      + get(array, w, x - 1, y + 1)
      + get(array, w, x - 1, y)
      + get(array, w, x - 1, y - 1)
    })
    |> list.count(fn(n) { n < 4 })
  })
  |> list.fold(0, int.add)
}
