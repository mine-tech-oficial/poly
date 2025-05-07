import gleam/int
import poly/int as polyi
import qcheck
import qcheck/random
import qcheck/shrink
import qcheck/tree

pub fn int_poly_gen() {
  qcheck.generic_list(small_int(), qcheck.small_strictly_positive_int())
  |> qcheck.map(polyi.from_descending_list)
  |> qcheck.map(polyi.simplify)
}

pub fn non_null_int_poly_gen() {
  qcheck.generic_list(
    small_non_null_int(),
    qcheck.small_strictly_positive_int(),
  )
  |> qcheck.map(polyi.from_descending_list)
  |> qcheck.map(polyi.simplify)
}

pub fn small_int() {
  qcheck.generator(
    random.int(0, 100)
      |> random.then(fn(x) {
        case x < 75 {
          True -> random.int(-10, 10)
          False -> random.int(-100, 100)
        }
      }),
    fn(n) { tree.new(n, shrink.int_towards(0)) },
  )
}

pub fn small_non_null_int() {
  qcheck.generator(
    random.choose(0, 1)
      |> random.then(fn(x) {
        case x == 0 {
          True -> random.int(0, 100)
          False -> random.int(-100, 0)
        }
      })
      |> random.then(fn(x) {
        let upper_bound = case int.absolute_value(x) < 75 {
          True -> 10
          False -> 100
        }

        case x >= 0 {
          True -> random.int(1, upper_bound)
          False -> random.int(-upper_bound, -1)
        }
      }),
    fn(n) { tree.new(n, shrink.int_towards(0)) },
  )
}
