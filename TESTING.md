# Testing

The `comprehensive_test.txt` file provides a complete test suite covering all language features.

## Running Tests

```bash
./parser comprehensive_test.txt output.bc
luajit output.bc
```

## Test Coverage

The comprehensive test file covers:

- **Variable Declarations**
  - With type annotations (number, string, bool)
  - Without type annotations
  - With and without semicolons
  - Arrays

- **Arithmetic Operations**
  - Addition, subtraction, multiplication, division
  - Complex expressions with proper precedence

- **Compound Assignment Operators**
  - `+=`, `-=`, `*=`, `/=`

- **Comparison Operators**
  - `==`, `!=`, `<`, `>`, `<=`, `>=`

- **Logical Operators**
  - `&&` (AND), `||` (OR)
  - Complex boolean expressions

- **Conditional Blocks**
  - Simple conditions
  - Complex conditions with multiple operators

- **Loops**
  - Simple while-style loops
  - Nested loops (multiple levels)
  - Variable scope in nested contexts
  - Loops with compound assignments

- **Expressions**
  - Binary operators
  - Parenthesized expressions
  - Operator precedence

All tests are expected to pass and the generated Lua code should execute without errors.

## Output Validation

The test file generates clearly labeled output sections so it's easy to verify that each feature is working correctly. The test ends with "=== Test Complete ===" message.
