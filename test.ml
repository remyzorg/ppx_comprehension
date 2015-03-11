
module Comprehension = struct


  let range_map_start_filter : int -> int -> (int -> bool) -> (int -> 'a) -> 'a list =
    fun start stop p f ->
    let rec step acc stop =
      if stop = start then
        if p stop then f start :: acc else acc
      else
        if p stop then step (f stop :: acc) (stop - 1)
        else step acc (stop - 1)
    in step [] stop

  let map_filter l p f =
    let rec step l =
      match l with
      | [] -> []
      | h :: t ->
        if p h then f h :: step t
        else step t
    in step l

end



(* let () = *)
let l = [%cl let y = 2--10 in y]

let l2 = [%cl let y = 2--10 in if y mod 2 != 0 then Format.sprintf "%d" (y * 2)]

let l3 = [%cl let y = l in string_of_int y]


(* let l3 = [%cl *)
(*   ((x, y) (x + y) *)
(*    >>= (x, y) (if y mod 2 != 0 then x, y) *)
(*    >>= (x, y) (x + y) *)
(*    >>= y (Format.sprintf "%d" (y * 2) *)
(*   ) *)
(*     (2--10, )] *)

  (* List.iter (Printf.printf "%d ") l *)



(* let _ = [%l Format.printf "hello"] *)
