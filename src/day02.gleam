import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/02.txt")
  io.println("part 1: " <> int.to_string(part1(input)))
}

fn parse_input(input: String) -> List(#(Int, Int)) {
  string.split(string.trim(input), on: ",")
  |> list.map(fn(s) {
    let assert Ok(pair) = case string.split(s, on: "-") {
      [a, b] -> {
        use a <- result.try(int.parse(a))
        use b <- result.try(int.parse(b))
        Ok(#(a, b))
      }
      _ -> Error(Nil)
    }
    pair
  })
}

fn is_invalid(id: Int, factor: Int) -> Bool {
  let left = id / factor
  let right = id % factor

  // If the right-hand side has a leading 0, we might have false positive.
  // e.g. 1|01
  // Since the numbers are guaranteed to not have leading zeros, a right-hand
  // side with a leading 0 will never be equal to the left-hand side, so we
  // ignore it and keep going
  case right < factor / 10 {
    True -> is_invalid(id, factor * 10)
    False ->
      // In the general case, if the two sides are equal we found that the
      // ID is invalid. Also, since the rhs is always increasing and the lhs
      // decreasing, once lhs < rhs we know we can stop. Otherwise, we keep
      // going by increasing the factor
      case int.compare(left, right) {
        order.Eq -> True
        order.Gt -> is_invalid(id, factor * 10)
        order.Lt -> False
      }
  }
}

fn part1(input: String) -> Int {
  parse_input(input)
  |> list.flat_map(fn(pair) {
    let #(start, end) = pair
    list.range(from: start, to: end)
    |> list.filter(is_invalid(_, 10))
  })
  |> list.fold(0, int.add)
}
