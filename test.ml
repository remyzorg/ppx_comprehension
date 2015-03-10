
module Comprehension = struct


  let range_map_start_filter : (int -> bool) -> int -> int -> (int -> 'a) -> 'a list =
    fun p start stop f ->
    let rec step acc stop =
      if stop = start then f start :: acc
      else
        let stop = stop - 1 in
        if p stop then step (f stop :: acc) stop
        else step acc stop
    in step [] stop

end



(* let () = *)
let l = [%cl y ("lol") (2--10)]


let l2 = [%cl y (if y mod 2 != 0 then Format.sprintf "%d" (y * 2)) (2--10)]

(* let l3 = [%cl *)
(*   ((x, y) (x + y) *)
(*    >>= (x, y) (if y mod 2 != 0 then x, y) *)
(*    >>= (x, y) (x + y) *)
(*    >>= y (Format.sprintf "%d" (y * 2) *)
(*   ) *)
(*     (2--10, )] *)

  (* List.iter (Printf.printf "%d ") l *)



(* let _ = [%l Format.printf "hello"] *)
