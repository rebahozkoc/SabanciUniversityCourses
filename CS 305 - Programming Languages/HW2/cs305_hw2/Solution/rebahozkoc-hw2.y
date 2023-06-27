%{
#include <stdio.h>
void yyerror (const char *msg) {
    return;
}
%}
%token tSTRING tGET tSET tFUNCTION tPRINT tIF tRETURN tADD tSUB tMUL tDIV tINC tGT tEQUALITY tDEC tLT tLEQ tGEQ tIDENT tNUM
%start jisp
%%

jisp : '[' stmt_list ']' 
;

stmt_list :
          | set_stmt stmt_list
          | if_stmt stmt_list
          | print_stmt stmt_list
          | increment_stmt stmt_list
          | decrement_stmt stmt_list
          | return_stmt stmt_list
          | expr stmt_list
;

expr : tSTRING
     | tNUM
     | get_expr
     | condition
     | operator
     | func_dec
;

get_expr : '[' tGET ','  tIDENT ']'
         | '[' tGET ','  tIDENT ',' '[' expr_list ']' ']';

expr_list : 
          | expr
          | expr ',' expr_list ;

set_stmt : '[' tSET ',' tIDENT ',' expr ']';

if_stmt : '[' tIF ',' condition ',' '[' stmt_list ']'  ']'
        | '[' tIF ',' condition ',' '[' stmt_list ']' '[' stmt_list ']' ']';
        

print_stmt : '[' tPRINT ',' expr ']';

increment_stmt : '[' tINC ',' tIDENT ']'; 

decrement_stmt : '[' tDEC ',' tIDENT ']';

return_stmt : '[' tRETURN ']'
            | '[' tRETURN ',' expr ']';

condition : '[' tEQUALITY ',' expr ',' expr ']'
          | '[' tGT ',' expr ',' expr ']'
          | '[' tGEQ ',' expr ',' expr ']'
          | '[' tLEQ ',' expr ',' expr ']'
          | '[' tLT ',' expr ',' expr ']';

operator : '[' tADD ',' expr ',' expr ']'
         | '[' tSUB ',' expr ',' expr ']'
         | '[' tMUL ',' expr ',' expr ']'
         | '[' tDIV ',' expr ',' expr ']';

func_dec : '[' tFUNCTION ',' '[' parameter_list ']' ',' '[' stmt_list ']' ']';

parameter_list : 
               | tIDENT
               | tIDENT ',' parameter_list;

%%
int main (){
    if (yyparse()){
        // parse error
        printf("ERROR\n");
        return 1;
    }
    else{
        // successful parsing
        printf("OK\n");
        return 0;
    }
}
