import gleeunit/should
import poly.{Descending}
import poly/int as polyi

pub fn addition_test() {
  // x + 2
  let a = Descending([1, 2])

  // 3x^2 + 4x + 5
  let b = Descending([3, 4, 5])

  // 3x^2 + 5x + 7
  polyi.add(a, b)
  |> should.equal(Descending([3, 5, 7]))
}

pub fn subtraction_test() {
  let a = Descending([1, 2, 3])
  let b = Descending([4, 5])

  polyi.subtract(a, b)
  |> should.equal(Descending([1, -2, -2]))
}

pub fn multiplication_test() {
  let a = Descending([1, 2, 3])
  let b = Descending([4, 5, 6])

  polyi.multiply(a, b)
  |> poly.reverse
  |> should.equal(Descending([4, 13, 28, 27, 18]))
}

pub fn long_division_test() {
  let a = Descending([3, -5, -1])
  let b = Descending([2, -3])

  let #(quotient, remainder) = polyi.long_divide(a, b)

  should.equal(quotient, Descending([1, -1]))
  should.equal(remainder, Descending([1, 0, -4]))
}
