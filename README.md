# Adapt

Bijective parsing grammar library based on lpeg.
The same grammar definition may be used to parse a stream of text into a Concrete Syntax Tree, and translate a CST back into a stream of text with full validation.

## Technical Overview

### Technology

- **Primary language:** Lua

### Overall design
- Grammars are defined via a native DSL constructing a tree of objects possessing :Raise() and :Lower() methods
- Execution traverses top-down over either a stream of text which may be any seekable Moonrise.Stream derived class, or a tree of objects.

### Ordered choice
Implemented in Transform/Select/init.lua
:Raise() results in a Wrapper enclosed object indicating the branch taken, enabling :Lower() to be O(1).
Methods for dealing with the extra clutter are exposed in companion library [Concrete](http://github.com/sunsetTech/Concrete)

### Lookahead
Implemented in Transform/Lookahead.lua
:Lower() attaches a constraint to the execution state that must either be satisfied or not satisfied, depending on mode, until it hits the logical end of the pattern.

### Set subtraction
Implemented in Transform/Without.lua
:Raise() uses negative lookahead to ensure the exclusion pattern does not match while returning to the initial stream position.
:Lower() also uses negative lookahead, and attaches a constraint that must not be satisfied until it hits a logical end. 
For the initial match it implements substring checking to ensure the exclusion pattern does not match all or some of the initial write.

### Constraints
Implemented in Execution/State/init.lua 
:CheckConstraints() is called every write and checks all active constraints at the starting position of the write.
If the lookahead mode is Negative and the pattern succeeds then it signals a parse failure, otherwise it is removed from the constraint array.
If the lookahead mode is Positive and the pattern fails, strictly not because it hit a logical end, then it signals a parse failure, otherwise it is removed from the constraint array.

## Features
- Wide range of implemented atoms including: ordered choice (Select), Lookahead (positive and negative), set subtraction (Without), bijective transformation with Lens.
- Hooks for debugging.

## Status
Personal project, active development.
Some transitive dependencies for this library are not yet available on github.

## Example
```Lua
return Grammar{
    ....
    Alpha = Select{
        Range("a","z"),
        Range("A","Z")
    };

    Decimal = Grammar{
        Digit = Range("0","9");
        Atleast(1, Jump"Digit") / Lenses.Flat;
    };

    Alphanumeric = Select{
        Jump"Alpha",
        Jump"Decimal.Digit"
    };

    Identifier = Grammar{
        Character = Select{
            Jump"Alphanumeric",
            String"_",
        };
        
        Without(
            Select{
                Jump"Keyword",
            },
            Atleast(1, Jump"Character")
        ) 
        / Lenses.Flat
    };
    ....
}
```

## TODO
Transpiler from object tree to Lua
