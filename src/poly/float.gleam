//// A module for working with float polynomials
//// 
//// For polynomial creation and conversion, use the functions provided in the `poly` module

import gleam/float
import poly.{Operations}

/// A polynomial with float coefficients.
/// 
/// The `order` type parameter is a phantom type representing the order.
pub type Polynomial =
  poly.Polynomial(Float)

const operations = Operations(
  zero: 0.0,
  add: float.add,
  subtract: float.subtract,
  multiply: float.multiply,
  divide: float.divide,
)

// ---------- Conversion ----------

/// Create a descending polynomial from a list. If it's empty, create a zero polynomial
pub fn from_descending_list(coefficients: List(Float)) -> Polynomial {
  poly.from_descending_list(coefficients, 0.0)
}

/// Create an ascending polynomial from a list. If it's empty, create a zero polynomial
pub fn from_ascending_list(coefficients: List(Float)) -> Polynomial {
  poly.from_ascending_list(coefficients, 0.0)
}

// ---------- QOL ----------

/// Get the degree of a polynomial.
pub fn degree(polynomial: Polynomial) -> Int {
  poly.degree(polynomial, 0.0)
}

/// Simplify a polynomial.
pub fn simplify(polynomial: Polynomial) -> Polynomial {
  poly.simplify(polynomial, 0.0)
}

// ---------- Operations ----------

/// Evaluate a polynomial, using the operations passed.
pub fn evaluate(polynomial polynomial: Polynomial, x value: Float) -> Float {
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
) -> Result(#(Polynomial, Polynomial), Nil) {
  poly.long_divide(a, b, operations)
}
