open Computational_category
let check label b = if not b then failwith label
let get = function
  | Ok x -> x
  | Error (Foundations.Category.Non_composable s | Foundations.Category.Non_parallel s
    | Foundations.Category.Outside_domain s | Foundations.Category.Outside_codomain s
    | Foundations.Category.Malformed_graph s | Foundations.Category.Malformed_diagram s
    | Foundations.Category.Malformed_term s | Foundations.Category.Malformed_relation s
    | Foundations.Category.Different_base s | Foundations.Category.Non_commuting s) -> failwith s
  | Error (Foundations.Category.Iteration_limit n) -> failwith (Printf.sprintf "iteration limit %d" n)
let reject label predicate = function
  | Error e -> check label (predicate e)
  | Ok _ -> failwith (label ^ ": unexpectedly accepted")
let reject_any label = reject label (fun _ -> true)
