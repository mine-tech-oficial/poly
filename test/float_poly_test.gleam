import gleeunit/should
import poly.{Descending}
import poly/float as polyf

pub fn addition_test() {
  let a = Descending([1.0, 2.0])
  let b = Descending([3.0, 4.0, 5.0])

  polyf.add(a, b)
  |> should.equal(Descending([3.0, 5.0, 7.0]))
}

pub fn subtraction_test() {
  let a = Descending([1.0, 2.0, 3.0])
  let b = Descending([4.0, 5.0])

  polyf.subtract(a, b)
  |> should.equal(Descending([1.0, -2.0, -2.0]))
}

pub fn multiplication_test() {
  let a = Descending([1.0, 2.0, 3.0])
  let b = Descending([4.0, 5.0, 6.0])

  polyf.multiply(a, b)
  |> poly.reverse
  |> should.equal(Descending([4.0, 13.0, 28.0, 27.0, 18.0]))
}

pub fn long_division_test() {
  let a = Descending([3.0, -5.0, -1.0])
  let b = Descending([2.0, -3.0])

  let #(quotient, remainder) = polyf.long_divide(a, b)

  should.equal(quotient, poly.Descending([1.5, -0.25]))
  should.equal(remainder, Descending([-1.75]))
}
