(** Tests for CN Actions *)

open Cn_actions_lib.Cn_actions
open Cn_actions_lib.Cn_actions_compose

let%expect_test "action_to_string - git actions" =
  print_endline (action_to_string (Checkout "main"));
  print_endline (action_to_string (Merge "feature"));
  print_endline (action_to_string (Push ("origin", "main")));
  print_endline (action_to_string (Branch_delete "old-branch"));
  print_endline (action_to_string (Remote_delete ("origin", "old-branch")));
  [%expect
    {|
    checkout main
    merge feature
    push origin main
    branch-delete old-branch
    remote-delete origin old-branch
    |}]

let%expect_test "action_to_string - file actions" =
  print_endline (action_to_string (File_write ("test.txt", "content")));
  print_endline (action_to_string (File_move ("a.txt", "b.txt")));
  print_endline (action_to_string (Dir_create "logs"));
  print_endline (action_to_string (Log_append ("log.md", "entry")));
  [%expect
    {|
    file-write test.txt
    file-move a.txt b.txt
    dir-create logs
    log-append log.md
    |}]

let%expect_test "accept composition" =
  let actions = accept "pi/feature" in
  List.iter (fun a -> print_endline (action_to_string a)) actions;
  [%expect
    {|
    checkout main
    merge pi/feature
    push origin main
    branch-delete pi/feature
    remote-delete origin pi/feature
    log-append logs/inbox.md
    |}]

let%expect_test "reject composition" =
  let actions = reject "pi/bad-idea" "out of scope" in
  List.iter (fun a -> print_endline (action_to_string a)) actions;
  [%expect
    {|
    branch-delete pi/bad-idea
    remote-delete origin pi/bad-idea
    log-append logs/inbox.md
    |}]

let%expect_test "defer composition" =
  let actions = defer "pi/later" "next week" in
  List.iter (fun a -> print_endline (action_to_string a)) actions;
  [%expect {| log-append logs/inbox.md |}]

let%expect_test "delegate composition" =
  let actions = delegate "sigma/task" "cn-tau" in
  List.iter (fun a -> print_endline (action_to_string a)) actions;
  [%expect
    {|
    push cn-tau sigma/task
    branch-delete sigma/task
    remote-delete origin sigma/task
    log-append logs/inbox.md
    |}]

let%expect_test "materialize_thread composition" =
  let actions =
    materialize_thread "pi/review" "threads/inbox/pi-review.md" "# Review\n"
  in
  List.iter (fun a -> print_endline (action_to_string a)) actions;
  [%expect
    {|
    dir-create threads/inbox
    file-write threads/inbox/pi-review.md
    log-append logs/inbox.md
    |}]
