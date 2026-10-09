%token SELECT FROM STAR COMMA SEMI EOF
%token <string> IDENT

%start <Ast.query> query
%%

query:
  | SELECT s = select_list FROM t = IDENT SEMI? EOF { { Ast.select = s; from = t } }

select_list:
  | STAR                                   { Ast.Star }
  | cols = separated_nonempty_list(COMMA, IDENT) { Ast.Columns cols }
