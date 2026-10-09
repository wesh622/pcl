let find s sub =
  let n = String.length s and m = String.length sub in
  let rec go i =
    if i + m > n then raise Not_found
    else if String.sub s i m = sub then i
    else go (i + 1)
  in
  go 0
