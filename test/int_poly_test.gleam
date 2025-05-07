import helpers
import non_empty_list.{NonEmptyList}
import poly
import poly/int as polyi
import qcheck
import startest.{describe, it}
import startest/expect

pub fn integer_tests() {
  describe("Integer Polynomial Tests", [
    describe("Addition", [
      it("(x + 2) + (3x^2 + 4x + 5)", fn() {
        let a = polyi.from_descending_list([1, 2])
        let b = polyi.from_descending_list([3, 4, 5])
        polyi.add(a, b)
        |> expect.to_equal(polyi.from_descending_list([3, 5, 7]))
      }),
    ]),
    describe("Subtraction", [
      it("(x^2 + 2x + 3) - (4x + 5)", fn() {
        let a = polyi.from_descending_list([1, 2, 3])
        let b = polyi.from_descending_list([4, 5])

        polyi.subtract(a, b)
        |> expect.to_equal(polyi.from_descending_list([1, -2, -2]))
      }),
    ]),
    describe("Multiplication", [
      it("(x^2 + 2x + 3) * (4x^2 + 5x + 6)", fn() {
        let a = polyi.from_descending_list([1, 2, 3])
        let b = polyi.from_descending_list([4, 5, 6])

        polyi.multiply(a, b)
        |> poly.reverse
        |> expect.to_equal(polyi.from_descending_list([4, 13, 28, 27, 18]))
      }),
    ]),
    describe("Division", [
      it("(3x^2 - 5x - 1) / (2x - 3)", fn() {
        let a = polyi.from_descending_list([3, -5, -1])
        let b = polyi.from_descending_list([2, -3])

        let #(quotient, remainder) = expect.to_be_ok(polyi.long_divide(a, b))

        expect.to_equal(quotient, polyi.from_descending_list([1, -1]))
        expect.to_equal(remainder, polyi.from_descending_list([1, 0, -4]))
      }),
      it("Division by zero", fn() {
        let a = polyi.from_descending_list([1, 2, 3])
        let b = polyi.from_descending_list([0])

        expect.to_be_error(polyi.long_divide(a, b))
        Nil
      }),
    ]),
    describe("Property Testing", [
      it("Addition and Subtraction", fn() {
        use #(first, second) <- qcheck.given(
          qcheck.map2(helpers.int_poly_gen(), helpers.int_poly_gen(), fn(a, b) {
            #(a, b)
          }),
        )
        expect.to_equal(
          first,
          first
            |> polyi.add(second)
            |> polyi.subtract(second),
        )
      }),
      it("Reverse Addition and Subtraction", fn() {
        use #(first, second) <- qcheck.given(
          qcheck.map2(helpers.int_poly_gen(), helpers.int_poly_gen(), fn(a, b) {
            #(a, b)
          }),
        )
        expect.to_equal(
          first,
          first
            |> polyi.subtract(second)
            |> polyi.add(second),
        )
      }),
      it("Multiplication and Division", fn() {
        use #(first, second) <- qcheck.given(
          qcheck.map2(helpers.int_poly_gen(), helpers.int_poly_gen(), fn(a, b) {
            #(a, b)
          }),
        )
        let result =
          first
          |> polyi.multiply(second)
          |> polyi.long_divide(second)
        case second.coefficients == NonEmptyList(0, []) {
          True -> {
            result
            |> expect.to_be_error
            Nil
          }
          False -> {
            let #(quotient, remainder) =
              result
              |> expect.to_be_ok

            expect.to_equal(first, quotient)
            expect.to_equal(remainder, polyi.from_descending_list([0]))
          }
        }
      }),
    ]),
  ])
}
