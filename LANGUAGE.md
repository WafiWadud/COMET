# Language Specification

## Overview

This is a statically-typed programming language that compiles to Lua and can be executed as LuaJIT bytecode. The language emphasizes clarity with explicit type annotations and straightforward syntax.

## Data Types

### Primitive Types

- **`bool`** - Boolean values: `true` or `false`
- **`number`** - Numeric values (integers and floats): `42`, `3.14`
- **`string`** - Text values: `"hello world"`

### Union Types

Types can be combined using the pipe operator `|` to create union types that accept multiple types:

```
let flexible: number | string = 42
let flexible2: string | number = "hello"
let status: bool | number = true
```

Union types are useful for variables that can hold different types of values at runtime.

### String Escape Sequences

Strings support the following escape sequences:
- `\n` - Newline
- `\t` - Tab
- `\r` - Carriage return
- `\\` - Backslash
- `\"` - Double quote

**Examples:**
```
let msg: string = "Line 1\nLine 2"
let quoted: string = "She said \"Hello\""
let path: string = "C:\\Users\\Name"
```

### String Interpolation

Strings support interpolation using `${expression}` syntax:

```
let name = "Alice"
let age = 30
let info = "Name: ${name}, Age: ${age}"
print(info)  // Outputs: Name: Alice, Age: 30
```

Expressions inside `${}` are evaluated and converted to strings.

### String Concatenation

Use the `..` operator to concatenate strings:

```
let greeting = "Hello" .. " " .. "World"
print(greeting)  // Outputs: Hello World
```

### Function Types

Function types can be declared to represent callable objects with specific parameter and return types:

```
function(<param_types>) -> <return_type>
```

**Examples:**

```
# Function type for a function that takes two numbers and returns a number
let callback: function(number, number) -> number

# Function type for a function that takes a string and returns a string
let transformer: function(string) -> string

# Function type for a function with no parameters
let producer: function() -> number
```

Function types are useful for type annotations when working with higher-order functions (functions that accept other functions as arguments).

### Array Types

Arrays can be homogeneous (single type) or heterogeneous (mixed types):

**Homogeneous arrays:**
```
number[]           # Dynamic array of numbers
number[5]          # Array of 5 numbers
string[]           # Dynamic array of strings
bool[3]            # Array of 3 booleans
```

**Heterogeneous arrays:**
```
array              # Generic array (can hold any types)
array[]            # Dynamic generic array
array[10]          # Generic array with fixed size 10
```

Arrays can contain nested arrays at any depth.

### Array Access and Assignment

Array elements are accessed and modified using bracket notation with 1-based indexing (like Lua):

**Access:**
```
arr[1]             # First element
arr[i]             # Element at index i
arr[i + 1]         # Element at computed index
```

**Assignment:**
```
arr[1] = 10        # Set first element to 10
arr[i] = value     # Set element at index i
arr[i] += 5        # Add 5 to element at index i
```

**Homogeneous Array Examples:**
```
let numbers: number[] = [10, 20, 30]
print(numbers[1])  # Outputs: 10
print(numbers[2])  # Outputs: 20

# Modify elements
numbers[1] = 100
numbers[2] += 50
print(numbers[1])  # Outputs: 100
print(numbers[2])  # Outputs: 70

# Array modification in loops
let i: number = 1;
until (i > 2)?
  numbers[i] = numbers[i] * 2
  i += 1
done
```

**Heterogeneous Array Examples:**
```
# Mixed types in single array
let mixed: array = [1, "hello", true]
print(mixed[1])  # Outputs: 1
print(mixed[2])  # Outputs: hello
print(mixed[3])  # Outputs: true

# Nested arrays
let nested = [1, 2, [3, 4, 5]]
print(nested[3][1])  # Outputs: 3
print(nested[3][2])  # Outputs: 4

# Mixed and nested
let complex = ["first", [10, 20], true, ["a", "b"]]
print(complex[1])      # Outputs: first
print(complex[2][1])   # Outputs: 10
print(complex[4][2])   # Outputs: b
```

Array elements support all compound assignment operators: `+=`, `-=`, `*=`, `/=`

## Variables

### Declaration Syntax

```
let <identifier>: <type> = <expression>
```

### Examples

```
let x: number = 42
let name: string = "Alice"
let flag: bool = true
let values: number[] = [1, 2, 3, 4, 5]
let items: array[] = ["hello", 42, true]
```

### Rules

- Variable names must start with a letter, followed by letters or digits
- All variables require explicit type annotations
- Variables are function-scoped
- Cannot declare the same variable twice in the same scope

## Functions

### Declaration Syntax

```
function <name>(<parameters>) -> <return_type>
  <function_body>
done
```

### Parameter Syntax

```
<identifier>: <type>
<identifier>: <array_type>
...<identifier>        # Variadic arguments (accepts any number of arguments)
```

### Parameters with Arrays

Functions can accept arrays as parameters:

```
function sumarray(nums: number[]) -> number
  return 0
done

function processitems(items: array[]) -> number
  return 0
done

# Call with arrays
let data: number[] = [1, 2, 3]
sumarray(data)

let mixed: array[] = [1, "hello", true]
processitems(mixed)
```

Arrays are passed by reference and can be typed as:
- Homogeneous arrays: `number[]`, `string[]`, `bool[]`
- Generic arrays: `array[]` or `array`
- Sized arrays: `number[5]` (type annotation, size not enforced)

### Using `#` operator with array parameters

The length operator `#` works on array parameters in functions:

```
function getarraylen(arr: number[]) -> number
  return #arr
done

let data: number[] = [1, 2, 3]
print(getarraylen(data))  # Outputs: 3
```

## Array Manipulation Functions

COMET provides built-in functions for array manipulation:

### push(array, value)

Add an element to the end of an array:

```
let arr: number[] = [1, 2, 3]
push(arr, 4)     # arr is now [1, 2, 3, 4]
push(arr, 5)     # arr is now [1, 2, 3, 4, 5]
```

### pop(array)

Remove and return the last element of an array:

```
let arr: number[] = [1, 2, 3]
pop(arr)         # arr is now [1, 2]
```

### insert(array, position, value)

Insert an element at a specific position (1-based indexing):

```
let arr: number[] = [1, 2, 3]
insert(arr, 2, 99)  # arr is now [1, 99, 2, 3]
```

All array manipulation functions operate on arrays in-place and compile to Lua's `table.insert()` and `table.remove()` functions.

### Variadic Arguments

Functions can accept a variable number of arguments using the `...` ellipsis operator:

```
function sum(...args) -> number
  return 0
done

function greet(...names) -> string
  return "Hello"
done

# Call with any number of arguments
print(sum(1, 2, 3, 4, 5))
print(greet("Alice", "Bob", "Charlie"))
```

Variadic parameters must be the last parameter (or only parameter) in the function signature and are represented as `...` in the generated Lua code.

### Return Statements

Functions can return values using the `return` keyword:

```
return <expression>
```

**Examples:**

#### Simple function with return
```
function add(a: number, b: number) -> number
  return a + b
done
```

#### Multiple parameters with return
```
function multiply(x: number, y: number) -> number
  return x * y
done
```

#### Function returning strings
```
function greet(name: string) -> string
  return name
done
```

#### No parameters
```
function double(x: number) -> number
  return x * 2
done
```

### Function Calls

Functions are called using standard syntax:

```
<function_name>()
<function_name>(<arg1>, <arg2>, ...)
```

Functions can be called within expressions:

```
print(add(5, 3))
print(multiply(x, 2))
```

### Notes

- Function parameters are passed correctly to the Lua code and are accessible within the function body
- Functions must use `return` statements to return values
- Return statements can return any expression (arithmetic, variables, function calls, etc.)
- Function bodies can contain variable declarations, statements, and return statements
- Return statements can optionally be followed by a semicolon

## Operators

### Arithmetic Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `+` | Addition | `a + b` |
| `-` | Subtraction | `a - b` |
| `*` | Multiplication | `a * b` |
| `/` | Division | `a / b` |

### String Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `..` | Concatenation | `"Hello" .. " " .. "World"` |
| `#` | Length | `#"hello"` returns `5` |

### Array Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `#` | Length | `#arr` returns number of elements |

### Compound Assignment Operators

| Operator | Meaning | Equivalent |
|----------|---------|------------|
| `+=` | Add and assign | `x = x + 5` |
| `-=` | Subtract and assign | `x = x - 5` |
| `*=` | Multiply and assign | `x = x * 5` |
| `/=` | Divide and assign | `x = x / 5` |

**Examples:**
```
x += 1
count -= 2
total *= 2
result /= 10
```

**Precedence**: `*` and `/` bind tighter than `+` and `-`

```
x + y * 2      # Evaluates as x + (y * 2)
(x + y) * 2    # Use parentheses to override
```

### Comparison Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `==` | Equal | `x == 5` |
| `!=` | Not equal | `x != 5` |
| `<` | Less than | `x < 5` |
| `>` | Greater than | `x > 5` |
| `<=` | Less than or equal | `x <= 5` |
| `>=` | Greater than or equal | `x >= 5` |

Returns a boolean value.

### Logical Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `&&` | Logical AND | `a && b` |
| `\|\|` | Logical OR | `a \|\| b` |
| `!` | Logical NOT | `!flag` |

**Precedence**: `!` binds tightest, then `&&`, then `\|\|`

```
a || b && c    # Evaluates as a || (b && c)
(a || b) && c  # Use parentheses to override
```

## Expressions

Expressions combine values and operators to produce results.

### Expression Syntax

```
<value>
<expression> <operator> <expression>
(<expression>)
<function_call>
```

### Examples

```
42
x + y
(a * b) + (c / d)
x > 10 && y < 5
add(5, 3) * 2
```

### Operator Precedence (highest to lowest)

1. Parentheses `()`
2. Multiplication `*`, Division `/`
3. Addition `+`, Subtraction `-`
4. Comparison `==`, `!=`, `<`, `>`, `<=`, `>=`
5. Logical AND `&&`
6. Logical OR `||`

## Control Flow

### Loops

Loop blocks execute statements repeatedly while a condition is true.

**Syntax:**
```
until (<expression>)?
  <statements>
done
```

The `until` keyword starts the loop, which continues while the condition in parentheses is truthy. Multiple statements can be included in the loop body, separated by newlines.

**Example:**
```
let i: number = 1;
until (i < 10)?
  print(i)
  i += 1
done
```

This loop prints numbers 1 through 9, incrementing `i` by 1 each iteration.

### Break and Continue

The `break` statement exits a loop immediately. The `continue` statement skips to the next iteration.

```
break       # Exit the loop
continue    # Skip to next iteration
```

**Examples:**
```
let i: number = 1;
until (i > 10)?
  (i == 5)?
    break  // Exit when i equals 5
  done
  print(i)
  i += 1
done

let j: number = 1;
until (j > 10)?
  (j == 3)?
    j += 1
    continue  // Skip printing when j is 3
  done
  print(j)
  j += 1
done
```

### Nested Loops

Loops can be nested inside other loops. Variable declarations in nested loops are scoped to the loop they appear in.

**Example:**
```
let i: number = 1;
until (i <= 3)?
  print(i)
  let j: number = 1;
  until (j <= 2)?
    print(j)
    j += 1
  done
  i += 1
done
```

This prints:
```
1
1
2
2
1
2
3
1
2
```

### Conditional Blocks

Conditional blocks evaluate an expression and execute one or more statements if the result is truthy.

```
(<expression>)?
  <statement>
  <statement>
  ...
done
```

### Syntax Notes

- The `?` marks the condition
- Multiple statements can follow
- Block must end with `done`
- Statements can include: function calls, assignments, variable declarations, return statements, break, continue, and nested conditionals

### Nested Conditionals

Conditional blocks can be nested inside other conditionals, loops, and other conditional blocks at any depth.

**Example:**
```
(x < 20)?
  print("outer condition")
  (y > 15)?
    print("inner condition")
  done
done
```

### Break and Continue in Conditionals

`break` and `continue` statements work inside conditionals within loops. `break` exits the loop immediately, while `continue` skips to the next iteration.

**Example:**
```
let i: number = 1;
until (i > 10)?
  (i == 5)?
    print("Breaking at 5")
    break
  done
  print(i)
  i += 1
done

let j: number = 1;
until (j > 5)?
  (j == 3)?
    print("Skipping 3")
    continue
  done
  print(j)
  j += 1
done
```

### Otherwise (Else) and Elseif

Conditional blocks can have `otherwise` clauses for alternative branches:

**Standalone else:**
```
(x > 10)?
  print("x is greater than 10")
otherwise?
  print("x is not greater than 10")
done
```

**Else if (with condition):**
```
(x > 20)?
  print("x > 20")
otherwise (x == 20)?
  print("x == 20")
otherwise?
  print("x < 20")
done
```

The `otherwise` keyword can be followed by `?` for a simple else, or by a condition `(expr)?` for else if.

### Examples

```
(x == 42)?
  print("x is forty-two")
done

(y > 10)?
  print("y is greater than 10")
  y = y - 1
done

(flag && count > 0)?
  print("conditions met")
  count -= 1
done

(!(x > 20))?  // Using NOT operator
  print("x is not greater than 20")
  x = x + 10
done
```

## Type Checking

### Type Checking Methods

Objects support type checking methods using dot notation:

```
<expression>.isnumber    # Check if value is a number
<expression>.isstring    # Check if value is a string
<expression>.isbool      # Check if value is a boolean
```

These methods return boolean values (true/false) based on the runtime type of the value.

**Examples:**

```
let num: number = 42
let str: string = "hello"
let flag: bool = true

(num.isnumber)?
  print("num is a number")
done

(str.isstring)?
  print("str is a string")
done

(flag.isbool)?
  print("flag is a boolean")
done

# Works with expressions and variables
let value = 100
(value.isnumber)?
  print("value is numeric")
done

# Can be combined with logical operators
(value.isnumber && str.isstring)?
  print("Both conditions are true")
done
```

Type checking methods are particularly useful when working with union types or dynamic values.

## Built-in Functions

### print()

Output a value to stdout without adding a newline (unlike standard print functions).

```
print(<expression>)
```

To print on separate lines, include `\n` in the string or call print with a newline string.

**Examples:**
```
print(42)
print("\n")              # Output a newline
print("Hello, World!")
print("\n")
print(x + y)
print("\n")
print("Multi")
print("line")           # Prints "Multiline" without a newline between
```

**Output:**
```
42
Hello, World!
<value of x+y>
Multiline
```

### input()

Read a value from stdin with a prompt. Returns the input as the specified type.

```
input(<string_literal>, <type>)
```

When the type is `number`, the input is automatically converted. Other types return the raw string input.

**Examples:**
```
let name: string = input("Enter your name: ", string)
let age: number = input("Enter your age: ", number)
```

**Example session:**
```
Enter your name: Alice
Enter your age: 30
Alice
30
```

## Comments

COMET supports both line and inline comments:

```
# Line comment using hash
let x: number = 42
let y: number = 50  // Inline comment using //

// Another inline comment style
x = x + 10
```

Comments are stripped during lexical analysis and do not affect the compiled output.

## Complete Program Example

```
# Variable declarations
let x: number = 10
let y: number = 20
let name: string = "Program"

# Function declaration
function multiply(a: number, b: number) -> number
let product: number = a * b
done

# Conditional block
(x < y)?
print("x is less than y")
done

# Function calls
print(x)
print(y)
print(multiply(x, y))

# Arithmetic in expressions
print(x + y)
print(x * y - 5)

# Complex conditions
(multiply(x, 2) > 15 && y != 0)?
print("complex condition met")
done

# Loop with compound assignment
let counter: number = 1;
until (counter <= 5)?
  print(counter)
  counter += 1
done
```

## Error Handling

The parser performs syntax validation during compilation. Errors include:

- Undefined variables (not caught at compile time, runtime error in Lua)
- Type mismatches in syntax (parser rejects)
- Unmatched delimiters or operators (parser rejects)
- Unexpected tokens (parser rejects)

Error messages indicate the line number where parsing failed.

## Compilation Process

1. **Lexical Analysis**: Tokenizes input into keywords, operators, literals, identifiers
2. **Parsing**: Builds abstract syntax tree and validates syntax
3. **Code Generation**: Emits equivalent Lua code with semantic actions
4. **Bytecode Compilation**: LuaJIT compiles Lua to executable bytecode

## Limitations

- No type checking at compile time (relies on Lua's dynamic typing)
- Single loop condition style (while-style, not C-style for loops)
- No structs or custom types
- No module system
- No exception handling
- Identifier names cannot contain underscores (lexer limitation)
