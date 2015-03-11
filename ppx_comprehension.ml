



open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident



let error ~loc s = raise (Location.Error (
    Location.error ~loc ("[%cl] " ^ s)))


let rec pattern_of_expr e =
  match e.pexp_desc with
  | Pexp_ident {txt = Longident.Lident s; loc} ->
    (Pat.var {txt = s; loc})
  | Pexp_tuple exprs ->
    (Pat.tuple ~loc:e.pexp_loc @@ List.map pattern_of_expr exprs)
  | _ -> error ~loc:e.pexp_loc "identifier or tuple expected"


let handle_payload ~loc e =
  match e with
  | [%expr let [%p? pattern] = [%e? el] in [%e? eop]] ->
    (* let ident_pat = pattern_of_expr pattern in *)
    let pred, eop = match eop with
      | [%expr if [%e? cond] then [%e? ethen]] ->
        [%expr (fun [%p pattern] -> [%e cond] )], ethen
      | e -> [%expr fun _ -> true], e
    in
    let start, stop = begin match el with
      | [%expr range [%e? stop]] -> [%expr 0], stop
      | [%expr range [%e? start] [%e? stop]]
      | [%expr [%e? start] -- [%e? stop]] -> start, stop
      | _ -> [%expr 0], [%expr 0]
    end in
    let fun_expr =
      match el with
      | [%expr range [%e? stop ]] ->
        [%expr Comprehension.range_map_start_filter [%expr 0] [%e stop]]
      | [%expr range [%e? start] [%e? stop]]
      | [%expr [%e? start] -- [%e? stop]] ->
        [%expr Comprehension.range_map_start_filter [%e start] [%e stop]]
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
