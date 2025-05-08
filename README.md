# poly

[![Package Version](https://img.shields.io/hexpm/v/poly)](https://hex.pm/packages/poly)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/poly/)

A library for working with polynomials.
Provides an abstract module, at `poly`, for generic coefficients, and specific modules for integers and floats, at `poly/int` and `poly/float`, respectively.

Special thanks to [yoshi](https://gitlab.com/arkandos) for their beautiful docs at [iv](https://hexdocs.pm/iv/iv.html) that were used as heavy inspiration.

```sh
gleam add polynomial@1
```

```gleam
import poly

pub fn main() {
  let ops = poly.Operations(
    zero: 0,
    add: int.add,
    subtract: int.subtract,
    multiply: int.multiply,
    divide: int.divide
  )

  let a = poly.from_list([1, 2, 3])
  let b = poly.from_list([4, 5, 6])

  // Prints out [4, 13, 28, 27, 18]
  echo poly.coefficients(poly.multiply(a, b, with: ops))
}
```

Further documentation can be found at <https://hexdocs.pm/poly>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
