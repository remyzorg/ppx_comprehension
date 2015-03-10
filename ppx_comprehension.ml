



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

  | [%expr [%e? pattern] [%e? eop] [%e? el]] ->
    let ident_pat = pattern_of_expr pattern in
    let cond, eop = match eop with
      | [%expr if [%e? cond] then [%e? ethen]] ->
        Some [%expr (fun [%p ident_pat] -> [%e cond] )], ethen
      | e -> None, e
    in
    let fun_expr = begin match el with
      | [%expr range [%e? stop]] ->
        let f = match cond with
          | None -> [%expr Comprehension.range_map]
          | Some pred -> [%expr Comprehension.range_map_filter [%e pred]]
        in [%expr [%e f] [%e stop]]

      | [%expr range [%e? start] [%e? stop]]
      | [%expr [%e? start] -- [%e? stop]] ->
        let f = match cond with
          | None -> [%expr Comprehension.range_map_start]
          | Some pred -> [%expr Comprehension.range_map_start_filter [%e pred]]
        in [%expr [%e f] [%e start] [%e stop]]
      | _ -> error ~loc:el.pexp_loc "comprehension list expected"
    end
    in
    [%expr [%e fun_expr] (fun [%p ident_pat] -> [%e eop])]

  | _ -> error ~loc "syntax error"




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
