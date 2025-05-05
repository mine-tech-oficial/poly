//// A module for working with integer polynomials
//// 
//// For polynomial creation and conversion, use the functions provided in the `poly` module

import gleam/int
import poly.{Operations}

/// A polynomial with integer coefficients.
/// 
/// The `order` type parameter is a phantom type representing the order.
pub type Polynomial =
  poly.Polynomial(Int)

const operations = Operations(
  zero: 0,
  add: int.add,
  subtract: int.subtract,
  multiply: int.multiply,
  divide: int.divide,
)

// ---------- QOL ----------

/// Get the degree of a polynomial.
pub fn degree(polynomial: Polynomial) -> Int {
  poly.degree(polynomial, 0)
}

/// Simplify a polynomial.
pub fn simplify(polynomial: Polynomial) -> Polynomial {
  poly.simplify(polynomial, 0)
}

// ---------- Operations ----------

/// Evaluate a polynomial, using the operations passed.
pub fn evaluate(polynomial polynomial: Polynomial, x value: Int) -> Int {
  poly.evaluate(polynomial, value, operations)
}

/// Add two polynomials. Returns a descending polynomial.
pub fn add(first a: Polynomial, second b: Polynomial) -> Polynomial {
  poly.add(a, b, operations)
}

/// Subtract two polynomials. Returns a descending polynomial.
pub fn subtract(first a: Polynomial, second b: Polynomial) -> Polynomial {
  poly.subtract(a, b, operations)
}

/// Multiply two descending polynomials. Returns an ascending polynomial.
pub fn multiply(first a: Polynomial, second b: Polynomial) -> Polynomial {
  poly.multiply(a, b, operations)
}

/// Long divide two polynomials. Returns the quotient and the remainder as descending polynomials.
pub fn long_divide(
  divisor a: Polynomial,
  dividend b: Polynomial,
) -> #(Polynomial, Polynomial) {
  poly.long_divide(a, b, operations)
}
