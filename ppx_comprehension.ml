



open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident



let error ~loc s = raise (Location.Error (
    Location.error ~loc ("[%cl] " ^ s)))

let list_of_tuple seq =
  let rec step e =



let handle_payload ~loc e =
  match e with
  | [%expr let [%p? pattern] = [%e? el] in [%e? eop]] ->
    (* let ident_pat = pattern_of_expr pattern in *)
    let pred, eop = match eop with
      | [%expr if [%e? cond] then [%e? ethen]] ->
        [%expr (fun [%p pattern] -> [%e cond] )], ethen
      | e -> [%expr fun _ -> true], e
    in
    let fun_expr =
      match el with
      | [%expr range [%e? stop ]] ->
        [%expr Comprehension.range_map_start_filter [%expr 0] [%e stop]]
      | [%expr range [%e? start] [%e? stop]]
      | [%expr [%e? start] -- [%e? stop]] ->

        (* begin match start, stop with *)
        (* | Pexp_tuple el_start, Pexp_tuple el_stop when *)
        (*     List.(length el_start = length el_stop) -> *)
        (*   [%expr Compehension.range_map_start_filter_  ] *)
        (* | _ -> *)
          [%expr jjComprehension.range_map_start_filter [%e start] [%e stop]]
        (* end *)
      | _ ->
        [%expr Comprehension.map_filter [%e el]]
    in
    [%expr [%e fun_expr] [%e pred] (fun [%p pattern] -> [%e eop])]

  | _ -> error ~loc "Syntax error"





let extend_mapper argv =
  (* Our getenv_mapper only overrides the handling of expressions in the default mapper. *)
  { default_mapper with
    expr = fun mapper expr ->
      match expr with
      (* Is this an extension node? *)
      | { pexp_desc =
          (* Should have name "getenv". *)
          Pexp_extension ({ txt = "cl"; loc }, pe)} ->
        begin match pe with
        | PStr [{ pstr_desc = Pstr_eval (e, _)}] -> handle_payload ~loc e
        | _ ->
          raise (Location.Error (
            Location.error ~loc "[%l] is only on expressions"))

        end
      (* Delegate to the default mapper. *)
      | x -> default_mapper.expr mapper x;
  }



let () = register "comprehension" extend_mapper
