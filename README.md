# ppx_comprehension
Syntax extension point for comprehension list


```
# let l = [%cl x ("lol") (range 8)]
val l : bytes list = ["lol"; "lol"; "lol"; "lol"; "lol"; "lol"; "lol"; "lol"; "lol"]

# let l2 = [%cl y (if y mod 2 != 0 then Format.sprintf "%d" (y * 2)) (2--10)]
val l2 : bytes list = ["4"; "6"; "10"; "14"; "18"]

```


```
if <expr> then <expr> => filter_map 

```
