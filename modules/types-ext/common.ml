  type msg = ..

  let handle_msg = ref (function _ -> failwith "Unable to handle message")

  let extend_handle f =
    let old = !handle_msg in
    handle_msg := f old

  let (q : msg Queue.t) = Queue.create ()
  let add msg = Queue.add msg q
  let handle_queue_messages () = Queue.iter !handle_msg q
  