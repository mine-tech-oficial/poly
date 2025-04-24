//// A module for working with polynomials with generic coefficients.
//// Can be used to define operations for specific coefficient types (as an example, see polynomial/int).
//// 
//// To use the operations, you need to construct a `Operations` variable, which holds the operations
//// between each coefficient, and a "zero" value (the additive identity)

import gleam/bool
import gleam/list

pub type Ascending

pub type Descending

/// A type representing the operations of the coefficient.
/// 
/// The divide function just has to return a number that, when multiplied by the divisor,
/// is smaller than or equal to the dividend, although if it returns the largest number
/// satisfying such property, the division will be faster.
/// 
/// Zero is the additive identity
pub type Operations(a) {
  Operations(
    zero: a,
    add: fn(a, a) -> a,
    subtract: fn(a, a) -> a,
    multiply: fn(a, a) -> a,
    divide: fn(a, a) -> Result(a, Nil),
  )
}

/// A polynomial with coefficients of type `coefficient`.
/// 
/// The `order` type parameter is a phantom type representing the order.
pub opaque type Polynomial(coefficient, order) {
  Polynomial(coefficients: List(coefficient))
}

/// Convert the polynomial to an ascending order of the coefficients.
pub fn to_ascending(
  polynomial: Polynomial(a, Descending),
) -> Polynomial(a, Ascending) {
  Polynomial(list.reverse(polynomial.coefficients))
}

/// Convert the polynomial to a descending order of the coefficients.
pub fn to_descending(
  polynomial: Polynomial(a, Ascending),
) -> Polynomial(a, Descending) {
  Polynomial(list.reverse(polynomial.coefficients))
}

/// Create a descending polynomial from a list of coefficients.
pub fn from_list(coefficients: List(a)) -> Polynomial(a, Descending) {
  Polynomial(coefficients)
}

/// Create an ascending polynomial from a list of coefficients.
pub fn from_list_ascending(coefficients: List(a)) -> Polynomial(a, Ascending) {
  Polynomial(coefficients)
}

/// Get the list of coefficients from the polynomial.
pub fn coefficients(polynomial: Polynomial(a, b)) -> List(a) {
  polynomial.coefficients
}

/// Get the degree of a descending polynomial.
pub fn degree(polynomial: Polynomial(a, Descending), zero: a) -> Int {
  list.length(simplify(polynomial, zero).coefficients)
}

/// Get the degree of an ascending polynomial.
pub fn degree_ascending(polynomial: Polynomial(a, Ascending), zero: a) -> Int {
  degree(to_descending(polynomial), zero)
}

/// Simplify a descending polynomial.
pub fn simplify(
  polynomial: Polynomial(a, Descending),
  zero: a,
) -> Polynomial(a, Descending) {
  case polynomial.coefficients {
    [v, ..rest] if v == zero -> simplify(Polynomial(rest), zero)
    rest -> Polynomial(rest)
  }
}

/// Simplify an ascending polynomial.
pub fn simplify_ascending(
  polynomial: Polynomial(a, Ascending),
  zero: a,
) -> Polynomial(a, Ascending) {
  to_ascending(simplify(to_descending(polynomial), zero))
}

/// Add two polynomials, using the operations passed.
pub fn add(
  first a: Polynomial(a, b),
  second b: Polynomial(a, b),
  with operations: Operations(a),
) -> Polynomial(a, b) {
  Polynomial(do_add(a.coefficients, b.coefficients, operations.add, []))
}

fn do_add(a: List(a), b: List(a), add: fn(a, a) -> a, acc: List(a)) -> List(a) {
  case a, b {
    [c1, ..a], [c2, ..b] -> do_add(a, b, add, [add(c1, c2), ..acc])
    [c, ..a], [] -> do_add(a, b, add, [c, ..acc])
    [], [c, ..b] -> do_add(a, b, add, [c, ..acc])
    [], [] -> list.reverse(acc)
  }
}

/// Subtract two polynomials, using the operations passed.
pub fn subtract(
  first a: Polynomial(a, b),
  second b: Polynomial(a, b),
  with operations: Operations(a),
) -> Polynomial(a, b) {
  Polynomial(
    do_subtract(a.coefficients, b.coefficients, operations.subtract, []),
  )
}

fn do_subtract(
  a: List(a),
  b: List(a),
  subtract: fn(a, a) -> a,
  acc: List(a),
) -> List(a) {
  case a, b {
    [c1, ..a], [c2, ..b] ->
      do_subtract(a, b, subtract, [subtract(c1, c2), ..acc])
    [c, ..a], [] -> do_subtract(a, b, subtract, [c, ..acc])
    [], [c, ..b] -> do_subtract(a, b, subtract, [c, ..acc])
    [], [] -> list.reverse(acc)
  }
}

/// Multiply two descending polynomials, using the operations passed.
/// 
/// If you need to multiply two ascending polynomials, you can convert
/// to descending the inputs and convert to ascending the output.
pub fn multiply(
  first a: Polynomial(a, Descending),
  second b: Polynomial(a, Descending),
  with operations: Operations(a),
) -> Polynomial(a, Descending) {
  to_descending(do_multiply(to_ascending(a), to_ascending(b), operations))
}

fn do_multiply(
  first a: Polynomial(a, Ascending),
  second b: Polynomial(a, Ascending),
  with operations: Operations(a),
) -> Polynomial(a, Ascending) {
  list.index_fold(a.coefficients, [], fn(acc, c1, i) {
    [
      list.reverse(
        list.fold(b.coefficients, list.repeat(operations.zero, i), fn(acc, c2) {
          [operations.multiply(c1, c2), ..acc]
        }),
      ),
      ..acc
    ]
  })
  |> list.reverse
  |> list.fold([], fn(acc, poly) { do_add(acc, poly, operations.add, []) })
  |> Polynomial
}

/// Long divide two descending polynomials, using the operations passed.
/// Returns the quotient and the remainder.
/// 
/// If you need to multiply two ascending polynomials, you can convert
/// to descending the inputs and convert to ascending the output.
pub fn long_divide(
  divisor divisor: Polynomial(a, Descending),
  dividend dividend: Polynomial(a, Descending),
  with operations: Operations(a),
) -> #(Polynomial(a, Descending), Polynomial(a, Descending)) {
  let degree_divisor = degree(divisor, operations.zero)
  let degree_dividend = degree(dividend, operations.zero)

  use <- bool.guard(degree_divisor < degree_dividend, #(Polynomial([]), divisor))
  let new_dividend =
    list.flatten([
      dividend.coefficients,
      list.repeat(operations.zero, degree_divisor - degree_dividend),
    ])
  let assert Ok(divisor_first) = list.first(divisor.coefficients)
  let assert Ok(dividend_first) = list.first(new_dividend)

  let assert Ok(multiplier) = operations.divide(divisor_first, dividend_first)

  let remainder =
    subtract(
      divisor,
      multiply(Polynomial(new_dividend), Polynomial([multiplier]), operations),
      operations,
    )

  use <- bool.guard(
    list.fold_until(remainder.coefficients, True, fn(_, v) {
      case v == operations.zero {
        True -> list.Continue(True)
        False -> list.Stop(False)
      }
    }),
    #(Polynomial([]), Polynomial([])),
  )

  let #(Polynomial(c), remainder) =
    long_divide(simplify(remainder, operations.zero), dividend, operations)

  #(Polynomial([multiplier, ..c]), remainder)
}
