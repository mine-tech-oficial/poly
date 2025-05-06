import gleeunit/should
import poly
import poly/int as polyi

pub fn addition_test() {
  // x + 2
  let a = polyi.from_descending_list([1, 2])

  // 3x^2 + 4x + 5
  let b = polyi.from_descending_list([3, 4, 5])

  // 3x^2 + 5x + 7
  polyi.add(a, b)
  |> should.equal(polyi.from_descending_list([3, 5, 7]))
}

pub fn subtraction_test() {
  let a = polyi.from_descending_list([1, 2, 3])
  let b = polyi.from_descending_list([4, 5])

  polyi.subtract(a, b)
  |> should.equal(polyi.from_descending_list([1, -2, -2]))
}

pub fn multiplication_test() {
  let a = polyi.from_descending_list([1, 2, 3])
  let b = polyi.from_descending_list([4, 5, 6])

  polyi.multiply(a, b)
  |> poly.reverse
  |> should.equal(polyi.from_descending_list([4, 13, 28, 27, 18]))
}

pub fn long_division_test() {
  let a = polyi.from_descending_list([3, -5, -1])
  let b = polyi.from_descending_list([2, -3])

  let #(quotient, remainder) = should.be_ok(polyi.long_divide(a, b))

  should.equal(quotient, polyi.from_descending_list([1, -1]))
  should.equal(remainder, polyi.from_descending_list([1, 0, -4]))
}
