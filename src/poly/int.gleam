//// A module for working with integer polynomials
//// 
//// For polynomial creation and conversion, use the functions provided in the `poly` module

import gleam/int
import poly.{type Ascending, type Descending, Operations}

/// A polynomial with integer coefficients.
/// 
/// The `order` type parameter is a phantom type representing the order.
pub type Polynomial(order) =
  poly.Polynomial(Int, order)

const operations = Operations(
  zero: 0,
  add: int.add,
  subtract: int.subtract,
  multiply: int.multiply,
  divide: int.divide,
)

// ---------- QOL ----------

/// Get the degree of a descending poly.
pub fn degree(polynomial: Polynomial(Descending)) -> Int {
  poly.degree(polynomial, 0)
}

/// Get the degree of an ascending poly.
pub fn degree_ascending(polynomial: Polynomial(Ascending)) -> Int {
  poly.degree_ascending(polynomial, 0)
}

/// Simplify a descending poly.
pub fn simplify(polynomial: Polynomial(Descending)) -> Polynomial(Descending) {
  poly.simplify(polynomial, 0)
}

/// Simplify an ascending poly.
pub fn simplify_ascending(
  polynomial: Polynomial(Ascending),
) -> Polynomial(Ascending) {
  poly.simplify_ascending(polynomial, 0)
}

// ---------- Operations ----------

/// Evaluate an descending polynomial, using the operations passed.
pub fn evaluate(
  polynomial polynomial: Polynomial(Descending),
  x value: Int,
) -> Int {
  poly.evaluate(polynomial, value, operations)
}

/// Evaluate an ascending polynomial, using the operations passed.
pub fn evaluate_ascending(
  polynomial polynomial: Polynomial(Ascending),
  x value: Int,
) -> Int {
  poly.evaluate_ascending(polynomial, value, operations)
}

/// Add two polynomials.
pub fn add(
  first a: Polynomial(Descending),
  second b: Polynomial(Descending),
) -> Polynomial(Descending) {
  poly.add(a, b, operations)
}

/// Subtract two polynomials.
pub fn subtract(
  first a: Polynomial(Descending),
  second b: Polynomial(Descending),
) -> Polynomial(Descending) {
  poly.subtract(a, b, operations)
}

/// Multiply two descending polynomials.
/// 
/// If you need to multiply two ascending polynomials, you can convert
/// to descending the inputs and convert to ascending the output.
pub fn multiply(
  first a: Polynomial(Descending),
  second b: Polynomial(Descending),
) -> Polynomial(Descending) {
  poly.multiply(a, b, operations)
}

/// Long divide two descending polynomials. Returns the quotient and the remainder.
/// 
/// If you need to multiply two ascending polynomials, you can convert
/// to descending the inputs and convert to ascending the output.
pub fn long_divide(
  divisor a: Polynomial(Descending),
  dividend b: Polynomial(Descending),
) -> #(Polynomial(Descending), Polynomial(Descending)) {
  poly.long_divide(a, b, operations)
}
