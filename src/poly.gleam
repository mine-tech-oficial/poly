//// A module for working with polynomials with generic coefficients.
//// Can be used to define operations for specific coefficient types (as an example, see polynomial/int).
//// 
//// To use the operations, you need to construct a `Operations` variable, which holds the operations
//// between each coefficient, and a "zero" value (the additive identity)

import gleam/bool
import gleam/list
import gleam/result
import iv

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
  Ascending(coefficients: List(coefficient))
  Descending(coefficients: List(coefficient))
}

// ---------- Conversion ----------

/// Reverses the order of the coefficients of the polynomial.
pub fn reverse(polynomial: Polynomial(a)) -> Polynomial(a) {
  let coefficients = list.reverse(polynomial.coefficients)
  case polynomial {
    Ascending(_) -> Descending(coefficients)
    Descending(_) -> Descending(coefficients)
  }
}

// ---------- QOL ----------

/// Get the degree of a polynomial.
pub fn degree(polynomial: Polynomial(a), zero: a) -> Int {
  list.length(simplify(polynomial, zero).coefficients)
}

/// Simplify a polynomial.
pub fn simplify(polynomial: Polynomial(a), zero: a) -> Polynomial(a) {
  case polynomial {
    Descending(coefficients) -> Descending(do_simplify(coefficients, zero))
    Ascending(coefficients) ->
      Ascending(list.reverse(do_simplify(list.reverse(coefficients), zero)))
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
      do_evaluate(coefficients, value, operations, operations.zero)
    Ascending(coefficients) ->
      do_evaluate(
        list.reverse(coefficients),
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
  let a = case a {
    Descending(coefficients) -> list.reverse(coefficients)
    Ascending(coefficients) -> coefficients
  }
  let b = case b {
    Descending(coefficients) -> list.reverse(coefficients)
    Ascending(coefficients) -> coefficients
  }

  Descending(do_add(a, b, operations.add, []))
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
  let a = case a {
    Descending(coefficients) -> list.reverse(coefficients)
    Ascending(coefficients) -> coefficients
  }
  let b = case b {
    Descending(coefficients) -> list.reverse(coefficients)
    Ascending(coefficients) -> coefficients
  }

  Descending(do_subtract(a, b, operations.subtract, operations.zero, []))
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
  let a = case a {
    Descending(coefficients) -> list.reverse(coefficients)
    Ascending(coefficients) -> coefficients
  }
  let b = case b {
    Descending(coefficients) -> list.reverse(coefficients)
    Ascending(coefficients) -> coefficients
  }
  Ascending(do_multiply(a, b, operations))
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
) -> #(Polynomial(a), Polynomial(a)) {
  let degree_divisor = degree(divisor, operations.zero)
  let degree_dividend = degree(dividend, operations.zero)

  let divisor = case divisor {
    Descending(coefficients) -> coefficients
    Ascending(coefficients) -> list.reverse(coefficients)
  }
  let dividend = case dividend {
    Descending(coefficients) -> coefficients
    Ascending(coefficients) -> list.reverse(coefficients)
  }

  let #(quotient, result) =
    do_long_divide(
      divisor,
      dividend,
      operations,
      degree_divisor - degree_dividend,
      [],
    )

  #(
    simplify(Descending(quotient), operations.zero),
    simplify(Descending(result), operations.zero),
  )
}

fn do_long_divide(
  divisor: List(a),
  dividend: List(a),
  operations: Operations(a),
  offset: Int,
  acc: List(a),
) -> #(List(a), List(a)) {
  case offset < 0 {
    True -> #(list.reverse(acc), divisor)
    False -> {
      let degree_dividend = degree(Descending(dividend), operations.zero)

      let multiplier =
        iv.get(iv.reverse(iv.from_list(divisor)), offset + degree_dividend - 1)
        |> result.try(fn(a) {
          list.first(dividend)
          |> result.map(fn(b) { #(a, b) })
        })
        |> result.try(fn(v) { operations.divide(v.0, v.1) })

      case multiplier {
        Ok(multiplier) -> {
          let divisor =
            subtract(
              Descending(divisor),
              multiply(
                Descending(dividend),
                Descending([multiplier, ..list.repeat(operations.zero, offset)]),
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
        Error(Nil) -> panic as "This probably shouldn't happen!"
      }
    }
  }
}
