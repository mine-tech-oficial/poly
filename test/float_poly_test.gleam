import poly
import poly/float as polyf
import startest.{describe, it}
import startest/expect

pub fn float_tests() {
  describe("Float Polynomial Tests", [
    describe("Addition", [
      it("(x + 2) + (3x^2 + 4x + 5)", fn() {
        let a = polyf.from_descending_list([1.0, 2.0])
        let b = polyf.from_descending_list([3.0, 4.0, 5.0])
        polyf.add(a, b)
        |> expect.to_equal(polyf.from_descending_list([3.0, 5.0, 7.0]))
      }),
    ]),
    describe("Subtraction", [
      it("(x^2 + 2x + 3) - (4x + 5)", fn() {
        let a = polyf.from_descending_list([1.0, 2.0, 3.0])
        let b = polyf.from_descending_list([4.0, 5.0])

        polyf.subtract(a, b)
        |> expect.to_equal(polyf.from_descending_list([1.0, -2.0, -2.0]))
      }),
    ]),
    describe("Multiplication", [
      it("(x^2 + 2x + 3) * (4x^2 + 5x + 6)", fn() {
        let a = polyf.from_descending_list([1.0, 2.0, 3.0])
        let b = polyf.from_descending_list([4.0, 5.0, 6.0])

        polyf.multiply(a, b)
        |> poly.reverse
        |> expect.to_equal(
          polyf.from_descending_list([4.0, 13.0, 28.0, 27.0, 18.0]),
        )
      }),
    ]),
    describe("Division", [
      it("(3x^2 - 5x - 1) / (2x - 3)", fn() {
        let a = polyf.from_descending_list([3.0, -5.0, -1.0])
        let b = polyf.from_descending_list([2.0, -3.0])

        let #(quotient, remainder) = expect.to_be_ok(polyf.long_divide(a, b))

        expect.to_equal(quotient, polyf.from_descending_list([1.5, -0.25]))
        expect.to_equal(remainder, polyf.from_descending_list([-1.75]))
      }),
      it("Division by zero", fn() {
        let a = polyf.from_descending_list([1.0, 2.0, 3.0])
        let b = polyf.from_descending_list([0.0])

        expect.to_be_error(polyf.long_divide(a, b))

        Nil
      }),
    ]),
  ])
}
