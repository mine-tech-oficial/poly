//// A module for working with polynomials with generic coefficients.
//// Can be used to define operations for specific coefficient types (as an example, see polynomial/int).
//// 
//// To use the operations, you need to construct a `Operations` variable, which holds the operations
//// between each coefficient, and a "zero" value (the additive identity)

import gleam/list
import gleam/result
import iv
import non_empty_list.{type NonEmptyList, NonEmptyList}

/// A type representing the operations of the coefficient.
/// 
/// The divide function has to return the greatest number that, when multiplied by the divisor,
/// is smaller than or equal to the dividend.
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
pub type Polynomial(coefficient) {
  Ascending(coefficients: NonEmptyList(coefficient))
  Descending(coefficients: NonEmptyList(coefficient))
}

// ---------- Conversion ----------

/// Reverses the order of the coefficients of the polynomial.
pub fn reverse(polynomial: Polynomial(a)) -> Polynomial(a) {
  let coefficients = non_empty_list.reverse(polynomial.coefficients)
  case polynomial {
    Ascending(_) -> Descending(coefficients)
    Descending(_) -> Ascending(coefficients)
  }
}

/// Create a descending polynomial from a list. If it's empty, create a zero polynomial
pub fn from_descending_list(coefficients: List(a), zero: a) -> Polynomial(a) {
  case coefficients {
    [first, ..rest] -> Descending(NonEmptyList(first, rest))
    [] -> Descending(NonEmptyList(zero, []))
  }
}

/// Create a descending polynomial from a list. If it's empty, create a zero polynomial
pub fn from_ascending_list(coefficients: List(a), zero: a) -> Polynomial(a) {
  case coefficients {
    [first, ..rest] -> Ascending(NonEmptyList(first, rest))
    [] -> Ascending(NonEmptyList(zero, []))
  }
}

// ---------- QOL ----------

/// Gets the coefficients of the polynomial in a descending order (no matter the polynomial order).
pub fn get_descending_coefficients(polynomial: Polynomial(a)) -> NonEmptyList(a) {
  case polynomial {
    Descending(coefficients) -> coefficients
    Ascending(coefficients) -> non_empty_list.reverse(coefficients)
  }
}

/// Gets the coefficients of the polynomial in an ascending order (no matter the polynomial order).
pub fn get_ascending_coefficients(polynomial: Polynomial(a)) -> NonEmptyList(a) {
  case polynomial {
    Ascending(coefficients) -> coefficients
    Descending(coefficients) -> non_empty_list.reverse(coefficients)
  }
}

/// Get the degree of a polynomial.
pub fn degree(polynomial: Polynomial(a), zero: a) -> Int {
  simplify(polynomial, zero).coefficients
  |> non_empty_list.to_list
  |> list.length
}

/// Simplify a polynomial.
pub fn simplify(polynomial: Polynomial(a), zero: a) -> Polynomial(a) {
  let simplified =
    get_descending_coefficients(polynomial)
    |> non_empty_list.to_list
    |> do_simplify(zero)
    |> from_descending_list(zero)

  case polynomial {
    Descending(_) -> simplified
    Ascending(_) -> reverse(simplified)
  }
}

fn do_simplify(coefficients: List(a), zero: a) -> List(a) {
  case coefficients {
    [v, ..rest] if v == zero -> do_simplify(rest, zero)
    rest -> rest
  }
}

// ---------- Operations ----------

/// Evaluate a polynomial, using the operations passed.
pub fn evaluate(
  polynomial polynomial: Polynomial(a),
  x value: a,
  with operations: Operations(a),
) -> a {
  case polynomial {
    Descending(coefficients) ->
      do_evaluate(
        non_empty_list.to_list(coefficients),
        value,
        operations,
        operations.zero,
      )
    Ascending(coefficients) ->
      do_evaluate(
        list.reverse(non_empty_list.to_list(coefficients)),
        value,
        operations,
        operations.zero,
      )
  }
}

fn do_evaluate(
  coefficients: List(a),
  value: a,
  operations: Operations(a),
  acc: a,
) -> a {
  case coefficients {
    [c, ..rest] ->
      do_evaluate(
        rest,
        value,
        operations,
        operations.add(operations.multiply(acc, value), c),
      )
    [] -> acc
  }
}

/// Add two polynomials, using the operations passed. Returns a descending polynomial.
pub fn add(
  first a: Polynomial(a),
  second b: Polynomial(a),
  with operations: Operations(a),
) -> Polynomial(a) {
  let a =
    get_ascending_coefficients(a)
    |> non_empty_list.to_list
  let b =
    get_ascending_coefficients(b)
    |> non_empty_list.to_list

  do_add(a, b, operations.add, [])
  |> from_descending_list(operations.zero)
}

fn do_add(a: List(a), b: List(a), add: fn(a, a) -> a, acc: List(a)) -> List(a) {
  case a, b {
    [c1, ..a], [c2, ..b] -> do_add(a, b, add, [add(c1, c2), ..acc])
    [c, ..a], [] -> do_add(a, b, add, [c, ..acc])
    [], [c, ..b] -> do_add(a, b, add, [c, ..acc])
    [], [] -> acc
  }
}

/// Subtract two polynomials, using the operations passed. Returns a descending polynomial.
pub fn subtract(
  first a: Polynomial(a),
  second b: Polynomial(a),
  with operations: Operations(a),
) -> Polynomial(a) {
  let a =
    get_ascending_coefficients(a)
    |> non_empty_list.to_list
  let b =
    get_ascending_coefficients(b)
    |> non_empty_list.to_list

  do_subtract(a, b, operations.subtract, operations.zero, [])
  |> from_descending_list(operations.zero)
}

fn do_subtract(
  a: List(a),
  b: List(a),
  subtract: fn(a, a) -> a,
  zero: a,
  acc: List(a),
) -> List(a) {
  case a, b {
    [c1, ..a], [c2, ..b] ->
      do_subtract(a, b, subtract, zero, [subtract(c1, c2), ..acc])
    [c, ..a], [] -> do_subtract(a, b, subtract, zero, [c, ..acc])
    [], [c, ..b] ->
      do_subtract(a, b, subtract, zero, [subtract(zero, c), ..acc])
    [], [] -> acc
  }
}

/// Multiply two polynomials, using the operations passed. Returns an ascending polynomial.
pub fn multiply(
  first a: Polynomial(a),
  second b: Polynomial(a),
  with operations: Operations(a),
) -> Polynomial(a) {
  let a =
    get_ascending_coefficients(a)
    |> non_empty_list.to_list
  let b =
    get_ascending_coefficients(b)
    |> non_empty_list.to_list

  do_multiply(a, b, operations)
  |> from_ascending_list(operations.zero)
}

fn do_multiply(
  first a: List(a),
  second b: List(a),
  with operations: Operations(a),
) -> List(a) {
  list.index_fold(a, [], fn(acc, c1, i) {
    [
      list.reverse(
        list.fold(b, list.repeat(operations.zero, i), fn(acc, c2) {
          [operations.multiply(c1, c2), ..acc]
        }),
      ),
      ..acc
    ]
  })
  |> list.reverse
  |> list.fold([], fn(acc, poly) {
    list.reverse(do_add(acc, poly, operations.add, []))
  })
}

/// Long divide two polynomials, using the operations passed.
/// Returns the quotient and the remainder as descending polynomials.
pub fn long_divide(
  divisor divisor: Polynomial(a),
  dividend dividend: Polynomial(a),
  with operations: Operations(a),
) -> Result(#(Polynomial(a), Polynomial(a)), Nil) {
  let degree_divisor = degree(divisor, operations.zero)
  let degree_dividend = degree(dividend, operations.zero)

  let divisor = get_descending_coefficients(divisor)
  let dividend = get_descending_coefficients(dividend)

  use #(quotient, remainder) <- result.map(
    do_long_divide(
      divisor,
      dividend,
      operations,
      degree_divisor - degree_dividend,
      [],
    ),
  )

  let quotient = from_descending_list(quotient, operations.zero)
  #(
    simplify(quotient, operations.zero),
    simplify(Descending(remainder), operations.zero),
  )
}

fn do_long_divide(
  divisor: NonEmptyList(a),
  dividend: NonEmptyList(a),
  operations: Operations(a),
  offset: Int,
  acc: List(a),
) -> Result(#(List(a), NonEmptyList(a)), Nil) {
  case offset < 0 {
    True -> Ok(#(list.reverse(acc), divisor))
    False -> {
      let degree_dividend = degree(Descending(dividend), operations.zero)

      let multiplier =
        divisor
        |> non_empty_list.to_list
        |> iv.from_list
        |> iv.reverse
        |> iv.get(offset + degree_dividend - 1)
        |> result.map(fn(a) { #(a, dividend.first) })
        |> result.try(fn(v) { operations.divide(v.0, v.1) })

      case multiplier {
        Ok(multiplier) -> {
          let divisor =
            subtract(
              Descending(divisor),
              multiply(
                Descending(dividend),
                Descending(NonEmptyList(
                  first: multiplier,
                  rest: list.repeat(operations.zero, offset),
                )),
                operations,
              ),
              operations,
            )

          do_long_divide(
            divisor.coefficients,
            dividend,
            operations,
            offset - 1,
            [multiplier, ..acc],
          )
        }
        Error(Nil) -> Error(Nil)
      }
    }
  }
}
