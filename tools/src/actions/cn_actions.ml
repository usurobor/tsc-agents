(** CN Actions - Unix-style action library.
    Each action does one job and does it well. *)

type branch = string
type remote = string
type path = string
type content = string

type action =
  (* Git *)
  | Checkout of branch
  | Merge of branch
  | Rebase of branch
  | Push of remote * branch
  | Fetch of remote
  | Pull of remote * branch
  | Branch_create of branch
  | Branch_delete of branch
  | Remote_delete of remote * branch
  (* File *)
  | File_write of path * content
  | File_append of path * content
  | File_move of path * path
  | File_copy of path * path
  | File_delete of path
  | Dir_create of path
  (* Log *)
  | Log_append of path * string

type result = Ok | Error of string

(** Convert action to human-readable string for logging *)
let action_to_string = function
  | Checkout b -> "checkout " ^ b
  | Merge b -> "merge " ^ b
  | Rebase b -> "rebase " ^ b
  | Push (r, b) -> "push " ^ r ^ " " ^ b
  | Fetch r -> "fetch " ^ r
  | Pull (r, b) -> "pull " ^ r ^ " " ^ b
  | Branch_create b -> "branch-create " ^ b
  | Branch_delete b -> "branch-delete " ^ b
  | Remote_delete (r, b) -> "remote-delete " ^ r ^ " " ^ b
  | File_write (p, _) -> "file-write " ^ p
  | File_append (p, _) -> "file-append " ^ p
  | File_move (src, dst) -> "file-move " ^ src ^ " " ^ dst
  | File_copy (src, dst) -> "file-copy " ^ src ^ " " ^ dst
  | File_delete p -> "file-delete " ^ p
  | Dir_create p -> "dir-create " ^ p
  | Log_append (p, _) -> "log-append " ^ p
