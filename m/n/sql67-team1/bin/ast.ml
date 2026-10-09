type select_list =
  | Star
  | Columns of string list

type query = {
  select : select_list;
  from : string;
}
