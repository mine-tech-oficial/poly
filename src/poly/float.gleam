//// A module for working with float polynomials

import gleam/float
import poly.{type Ascending, type Descending, Operations}

/// A polynomial with float coefficients.
/// 
/// The `order` type parameter is a phantom type representing the order.
pub type Polynomial(order) =
  poly.Polynomial(Float, order)

const operations = Operations(
  zero: 0.0,
  add: float.add,
  subtract: float.subtract,
  multiply: float.multiply,
  divide: float.divide,
)

/// Convert the polynomial to an ascending order of the coefficients.
pub fn to_ascending(polynomial: Polynomial(Descending)) -> Polynomial(Ascending) {
  poly.to_ascending(polynomial)
}

/// Convert the polynomial to a descending order of the coefficients.
pub fn to_descending(
  polynomial: Polynomial(Ascending),
) -> Polynomial(Descending) {
  poly.to_descending(polynomial)
}

/// Create a descending polynomial from a list of coefficients.
pub fn from_list(coefficients: List(Float)) -> Polynomial(Descending) {
  poly.from_list(coefficients)
}

/// Create an ascending polynomial from a list of coefficients.
pub fn from_list_ascending(coefficients: List(Float)) -> Polynomial(Ascending) {
  poly.from_list_ascending(coefficients)
}

/// Get the list of coefficients from the poly.
pub fn coefficients(polynomial: Polynomial(order)) -> List(Float) {
  poly.coefficients(polynomial)
}

/// Get the degree of a descending poly.
pub fn degree(polynomial: Polynomial(Descending)) -> Int {
  poly.degree(polynomial, 0.0)
}

/// Get the degree of an ascending poly.
pub fn degree_ascending(polynomial: Polynomial(Ascending)) -> Int {
  poly.degree_ascending(polynomial, 0.0)
}

/// Simplify a descending poly.
pub fn simplify(polynomial: Polynomial(Descending)) -> Polynomial(Descending) {
  poly.simplify(polynomial, 0.0)
}

/// Simplify an ascending poly.
pub fn simplify_ascending(
  polynomial: Polynomial(Ascending),
) -> Polynomial(Ascending) {
  poly.simplify_ascending(polynomial, 0.0)
}

/// Add two polynomials.
pub fn add(
  first a: Polynomial(order),
  second b: Polynomial(order),
) -> Polynomial(order) {
  poly.add(a, b, operations)
}

/// Subtract two polynomials.
pub fn subtract(
  first a: Polynomial(order),
  second b: Polynomial(order),
) -> Polynomial(order) {
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
