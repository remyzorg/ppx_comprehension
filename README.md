# ppx_comprehension
Syntax extension point for list comprehension


```ocaml
# let l = [%cl let x = 2--10 in x]
val l : int list = [2; 3; 4; 5; 6; 7; 8; 9; 10]

# let l2 = [%cl let y = 2--10 in if y mod 2 != 0 then Format.sprintf "%d" (y * 2)]
val l2 : bytes list = ["6"; "10"; "14"; "18"]

# let l3 = [%cl let y = l in string_of_int y]
val l3 : bytes list = ["2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"; "10"]


```

## Syntax

```
cl ::= let <pattern> = <list-expr> in <cond-expr>

list-expr :=
	| range <expr> | range <expr> <expr> | <expr> -- <expr>
	| <expr>

cond-expr :=
	| if <expr> then <expr>
	| <expr>

pattern ::= <ocaml-pattern>
expr ::= <ocaml-expr>
```
### `if-then` keyword

The if-then keyword just adds a predicate to the function (range or map)

### `range` keyword

The range keyword doesn't compute a list in the first place. It
creates the list `[f (start); ... ; f(stop)]` in *O(n)* so it goes from
stop to start (reverse construction) by calling a range function with parameter f.

If the `<list-expr>` is an Ocaml expression, the called function is a filter_map
