import gleeunit/should
import poly
import poly/int as polyi

pub fn addition_test() {
  // x + 2
  let a = poly.from_list([1, 2])

  // 3x^2 + 4x + 5
  let b = poly.from_list([3, 4, 5])

  // 3x^2 + 5x + 7
  polyi.add(a, b)
  |> should.equal(poly.from_list([3, 5, 7]))
}

pub fn subtraction_test() {
  let a = poly.from_list([1, 2, 3])
  let b = poly.from_list([4, 5])

  polyi.subtract(a, b)
  |> should.equal(poly.from_list([1, -2, -2]))
}

pub fn multiplication_test() {
  let a = poly.from_list([1, 2, 3])
  let b = poly.from_list([4, 5, 6])

  polyi.multiply(a, b)
  |> should.equal(poly.from_list([4, 13, 28, 27, 18]))
}

pub fn long_division_test() {
  let a = poly.from_list([3, -5, -1])
  let b = poly.from_list([2, -3])

  let #(quotient, remainder) = polyi.long_divide(a, b)

  should.equal(quotient, poly.from_list([1, -1]))
  should.equal(remainder, poly.from_list([1, 0, -4]))
}
