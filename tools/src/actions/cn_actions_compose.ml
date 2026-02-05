(** CN Actions Composition - Higher-level action sequences.
    These are examples of composing atomic actions. *)

open Cn_actions

(** Accept an inbound branch - merge to main, push, cleanup *)
let accept branch =
  [
    Checkout "main";
    Merge branch;
    Push ("origin", "main");
    Branch_delete branch;
    Remote_delete ("origin", branch);
    Log_append ("logs/inbox.md", "accepted: " ^ branch);
  ]

(** Reject an inbound branch - delete without merging *)
let reject branch reason =
  [
    Branch_delete branch;
    Remote_delete ("origin", branch);
    Log_append ("logs/inbox.md", "rejected: " ^ branch ^ " (" ^ reason ^ ")");
  ]

(** Defer an inbound branch - just log, keep branch *)
let defer branch until =
  [ Log_append ("logs/inbox.md", "deferred: " ^ branch ^ " until " ^ until) ]

(** Delegate an inbound branch - push to peer's repo *)
let delegate branch peer_remote =
  [
    Push (peer_remote, branch);
    Branch_delete branch;
    Remote_delete ("origin", branch);
    Log_append
      ("logs/inbox.md", "delegated: " ^ branch ^ " to " ^ peer_remote);
  ]

(** Materialize a branch as a thread file *)
let materialize_thread branch thread_path content =
  [
    Dir_create (Filename.dirname thread_path);
    File_write (thread_path, content);
    Log_append ("logs/inbox.md", "materialized: " ^ branch ^ " -> " ^ thread_path);
  ]
