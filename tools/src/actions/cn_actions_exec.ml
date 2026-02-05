(** CN Actions Executor - Effectful execution via Node.js *)

open Cn_actions_lib.Cn_actions

(** Node.js child_process.execSync binding *)
external exec_sync : string -> string = "execSync"
  [@@mel.module "child_process"]

(** Node.js fs bindings *)
external write_file_sync : string -> string -> unit = "writeFileSync"
  [@@mel.module "fs"]

external append_file_sync : string -> string -> unit = "appendFileSync"
  [@@mel.module "fs"]

external rename_sync : string -> string -> unit = "renameSync"
  [@@mel.module "fs"]

external copy_file_sync : string -> string -> unit = "copyFileSync"
  [@@mel.module "fs"]

external unlink_sync : string -> unit = "unlinkSync"
  [@@mel.module "fs"]

external mkdir_sync : string -> < recursive : bool > Js.t -> unit = "mkdirSync"
  [@@mel.module "fs"]

(** Get ISO timestamp for logging *)
let timestamp () =
  let d = Js.Date.make () in
  Js.Date.toISOString d

(** Execute a git command, return result *)
let git cmd =
  try
    let _ = exec_sync ("git " ^ cmd) in
    Ok
  with _ -> Error ("git " ^ cmd ^ " failed")

(** Execute a single action *)
let execute action =
  match action with
  (* Git actions *)
  | Checkout b -> git ("checkout " ^ b)
  | Merge b -> git ("merge " ^ b)
  | Rebase b -> git ("rebase " ^ b)
  | Push (r, b) -> git ("push " ^ r ^ " " ^ b)
  | Fetch r -> git ("fetch " ^ r)
  | Pull (r, b) -> git ("pull " ^ r ^ " " ^ b)
  | Branch_create b -> git ("checkout -b " ^ b)
  | Branch_delete b -> git ("branch -d " ^ b)
  | Remote_delete (r, b) -> git ("push " ^ r ^ " --delete " ^ b)
  (* File actions *)
  | File_write (p, c) -> (
      try
        write_file_sync p c;
        Ok
      with _ -> Error ("file-write " ^ p ^ " failed"))
  | File_append (p, c) -> (
      try
        append_file_sync p c;
        Ok
      with _ -> Error ("file-append " ^ p ^ " failed"))
  | File_move (src, dst) -> (
      try
        rename_sync src dst;
        Ok
      with _ -> Error ("file-move " ^ src ^ " " ^ dst ^ " failed"))
  | File_copy (src, dst) -> (
      try
        copy_file_sync src dst;
        Ok
      with _ -> Error ("file-copy " ^ src ^ " " ^ dst ^ " failed"))
  | File_delete p -> (
      try
        unlink_sync p;
        Ok
      with _ -> Error ("file-delete " ^ p ^ " failed"))
  | Dir_create p -> (
      try
        mkdir_sync p [%mel.obj { recursive = true }];
        Ok
      with _ -> Error ("dir-create " ^ p ^ " failed"))
  (* Log actions *)
  | Log_append (p, line) -> (
      try
        let entry = timestamp () ^ " " ^ line ^ "\n" in
        append_file_sync p entry;
        Ok
      with _ -> Error ("log-append " ^ p ^ " failed"))

(** Execute all actions, stop on first error *)
let rec execute_all actions =
  match actions with
  | [] -> Ok
  | action :: rest -> (
      match execute action with
      | Ok -> execute_all rest
      | Error e -> Error e)

(** Execute with logging - logs each action before execution *)
let execute_logged log_path action =
  let _ = execute (Log_append (log_path, action_to_string action)) in
  execute action

(** Execute all with logging *)
let execute_all_logged log_path actions =
  let rec go = function
    | [] -> Ok
    | action :: rest -> (
        match execute_logged log_path action with
        | Ok -> go rest
        | Error e -> Error e)
  in
  go actions
