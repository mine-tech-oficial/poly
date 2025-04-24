import gleeunit
import gleeunit/should
import poly/int as polyi

pub fn main() {
  gleeunit.main()
}

pub fn integer_multiplication_test() {
  let a = polyi.from_list([1, 2, 3])
  let b = polyi.from_list([4, 5, 6])

  let result = polyi.multiply(a, b)

  should.equal(result, polyi.from_list([4, 13, 28, 27, 18]))
}

pub fn integer_long_division_test() {
  let a = polyi.from_list([2, -5, -1])
  let b = polyi.from_list([1, -3])

  let #(quotient, remainder) = polyi.long_divide(a, b)

  should.equal(quotient, polyi.from_list([2, 1]))
  should.equal(remainder, polyi.from_list([2]))
}
