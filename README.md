# ppx_comprehension
Syntax extension point for list comprehension


```ocaml
# let l = [%cl let x = range 8 in "lol"]
val l : bytes list = ["lol"; "lol"; "lol"; "lol"; "lol"; "lol"; "lol"; "lol"; "lol"]

# let l2 = [%cl let y = if y mod 2 != 0 then Format.sprintf "%d" (y * 2) in (2--10)]
val l2 : bytes list = ["4"; "6"; "10"; "14"; "18"]


# let l3 = [%cl let y = l in string_of_int y]

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

### `range`keyword

The range keyword doesn't compute a list in the first place. It
creates the list [f (start); ... ; f(stop)] in O(n) so it goes from
start to stop by calling a range function with parameter f

If the <list-expr> is an Ocaml expression, the called function is a filter_map
