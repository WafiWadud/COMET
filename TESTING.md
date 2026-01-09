# COMET Language Testing Guide

## Test Suite

The main test file is `comprehensive_test.txt`, which covers all features of the COMET language.

### Running Tests

To compile and test the comprehensive test suite:

```bash
./parser comprehensive_test.txt
luajit a.out
```

Or in one command:

```bash
./parser comprehensive_test.txt && luajit a.out
```

## Test Coverage

The `comprehensive_test.txt` file tests the following features:

### 1. Variable Declarations
- Type annotations: `number`, `string`, `bool`
- Untyped declarations with inference
- Array declarations with type specifications

### 2. Arithmetic Operations
- Basic operators: `+`, `-`, `*`, `/`
- Proper operator precedence
- Complex expressions with parentheses

### 3. Compound Assignments
- Operators: `+=`, `-=`, `*=`, `/=`
- Works with variables and array elements

### 4. Comparison Operators
- Equality: `==`, `!=`
- Ordering: `<`, `>`, `<=`, `>=`
- All tested in conditional expressions

### 5. Logical Operators
- AND operator: `&&`
- OR operator: `||`
- Proper short-circuit evaluation
- Combinations in conditionals

### 6. Control Flow
- **Loops**: `until` loops with conditions
- **Conditionals**: `if-then-end` style with `?` and `done`
- **Nested structures**: loops within conditionals and vice versa
- **Otherwise**: `otherwise?` for else blocks
- **Elseif**: `otherwise (condition)?` for else-if chains

### 7. Arrays
- **Array literals**: `[1, 2, 3]`
- **Array access**: `arr[1]`, `arr[i]`, `arr[i+1]`
- **Array assignment**: `arr[1] = value`
- **Array compound assignments**: `arr[1] += 5`
- **Array length**: `#arr`
- **Nested arrays**: `[[1,2], [3,4]]`
- **Mixed-type arrays**: `array[]`

### 8. Strings
- **String literals**: `"hello"`
- **Escape sequences**: `\n`, `\t`, `\r`, `\\`, `\"`
- **Concatenation**: `"hello" .. " " .. "world"`
- **String length**: `#text`
- **String interpolation**: `"Value: ${expr}"`

### 9. Functions
- **Function declaration** with parameters and return types
- **Multiple parameters** with type annotations
- **Return statements** with expressions
- **Function calls** with arguments
- **Nested function calls** in expressions

### 10. Variadic Arguments
- **Variadic parameters**: `function name(...args)`
- **Multiple calls** with different argument counts
- **Variadic with fixed parameters**: `function name(a: type, ...rest)`

### 11. Array Parameters
- **Functions accepting arrays**: `function(arr: number[])`
- **Generic array parameters**: `function(items: array[])`
- **Array passing** by reference
- **Array access** within functions
- **Length operator with parameters**: `#arr` in function bodies

### 11b. Array Manipulation
- **push(array, value)**: Add element to end of array
- **pop(array)**: Remove element from end of array
- **insert(array, position, value)**: Insert at specific position
- **In-place operations**: All functions modify array directly

### 12. Union Types
- **Type union syntax**: `number | string`
- **Variable declarations**: `let x: number | string = value`
- **Works with multiple types**: supports any combination

### 13. Type Checking Methods
- **Isnumber method**: `value.isnumber`
- **Isstring method**: `value.isstring`
- **Isbool method**: `value.isbool`
- **In conditionals**: `(value.isnumber)? ... done`
- **With logical operators**: `(a.isnumber && b.isstring)?`
- **Works with expressions**: `(compute().isnumber)?`

### 14. Mixed Features
- Arrays with function parameters
- Union types in function parameters
- Type checking methods with complex expressions
- Variadic functions with different argument types

## Expected Output

When running the comprehensive test, you should see:
- "Variables declared"
- Results of arithmetic operations
- "AND: both conditions true"
- "OR: at least one condition true"
- Loop iteration output (1-5)
- Nested loop output
- String results
- Array access results
- String interpolation results
- Function call results
- Array function parameters working with `#` operator
- Array manipulation results (push, pop, insert)
- Type checking confirmations
- "All Features Tested Successfully"

## Test Organization

The test file is organized into sections with headers:
```
print("=== Section Name ===")
print("\n")
# test code here
```

This makes it easy to identify which feature is being tested in the output.

## Building and Running

1. **Build the parser:**
   ```bash
   make clean
   make
   ```

2. **Run comprehensive test:**
   ```bash
   ./parser comprehensive_test.txt
   luajit a.out
   ```

3. **View generated Lua code:**
   ```bash
   cat a.out.lua
   ```

## Adding New Tests

To add new tests to `comprehensive_test.txt`:

1. Add a new section with a header:
   ```
   print("=== New Feature ===")
   print("\n")
   ```

2. Add test code and output statements

3. Rebuild and test:
   ```bash
   ./parser comprehensive_test.txt && luajit a.out
   ```

## Debugging

If a test fails:

1. **Check syntax errors:**
   - Read the parser error message carefully
   - Line numbers indicate where parsing failed
   - Look for unsupported syntax patterns

2. **Check generated Lua:**
   - Run `cat a.out.lua` to see the intermediate Lua code
   - Verify the Lua syntax is correct
   - Test the Lua code directly if needed

3. **Check runtime errors:**
   - Look at the error message from luajit
   - Verify variable types and array bounds
   - Check function parameter passing

## Language Limitations

Current limitations in COMET:

- Variable names cannot contain underscores
- Array operations use 1-based indexing (Lua convention)
- No custom types or structs
- No module system or imports
- No exception handling
- Type checking is not enforced at compile time
- Union types and function types are for documentation only

## Future Test Coverage

Potential future test additions:
- More complex nested array operations
- Higher-order functions (functions as parameters)
- Recursive function calls
- Complex string interpolation scenarios
- Performance benchmarks
- Edge cases for type checking
