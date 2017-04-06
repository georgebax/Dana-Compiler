%{

/*----------------------------------------Libraries----------------------------------------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


void yyerror (const char *msg);
extern int number_of_lines;

/*----------------------------------------Definitions--------------------------------------------------------------------------------------------------------------------*/


%}

%token T_and "and"
%token T_as "as"
%token T_begin "begin"
%token T_break "break"
%token T_byte "byte"
%token T_continue "continue"
%token T_decl "decl"
%token T_def "def"
%token T_elif "elif"
%token T_else "else"
%token T_end "end"
%token T_exit "exit"
%token T_false "false"
%token T_if "if"
%token T_is "is"
%token T_int "int"
%token T_loop "loop"
%token T_not "not"
%token T_or "or"
%token T_ref "ref"
%token T_return "return"
%token T_skip "skip"
%token T_true "true"
%token T_var "var"
%token T_string
%token T_id
%token T_const
%token T_greater_equal
%token T_less_equal
%token T_assign
%token T_char_const
%token T_not_equal
%token T_escape
%token T_hex


%left '+' '-'
%left '*' '/' '%'
%left UMINUS




/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

%%
program:
	func_def
;

func_def:
	"def" header local_def_star block
;

local_def_star:
	local_def local_def_star |
	/*nothing*/ 
;

header:
	id is_data_type_req fparameters_req
;

is_data_type_req: /*at most 1*/
	"is" data_type |
	/*nothing*/
;

fparameters_req:
	":" fpar_def comma_fpar_def_star |
	/*nothing*/ 
;

comma_fpar_def_star:
	"," fpar_def comma_fpar_def_star |
	/*nothing*/
;

fpar_def:
	id_plus "as" fpar_type
;

id_plus: /*(id)+*/
	id /*and then nothing*/
	id id_plus |
:

data_type:
	"int" | 
	"byte"
;

type: /*INT_CONST NEEDS ATTENTION!*/
	data_type brackets_int_const_star
;

fpar_type:
	type | 
	"ref" data_type | 
	data_type "[" "]" brackets_int_const_star
;

brackets_int_const_star:
	"[" int_const "]" brackets_int_const_star |
	/*nothing*/
;

local_def:
	func_def | 
	func_decl | 
	var_def
;

stmt:
	"skip" | 
	l_value ":=" expr | 
	proc_call | 
	"exit" | 
	"return" ":" expr | 
	"if" cond ":" block elif_and_block_star else_and_block_req |	
	"loop" id_req ":" block |
	"break" colon_id_req |
	"continue" colon_id_req
;

id_req:
	id |
	/*nothing*/
;

colon_id_req:
	":" id |
	/*nothing*/
;

elif_and_block_star:
	"elif" cond ":" block elif_and_block_star |
	/*nothing*/
;	

else_and_block_req:
	"else" ":" block |
	/*nothing*/
;

block:
	"begin" stmt_plus "end" | 
	stmt_plus // CHECK THAT!!! it had an auto-end
;

stmt_plus:
	stmt /*and then nothing*/ |
	stmt stmt_plus
;

proc_call:
	id [":" expr ("," expr)*]
;

func_call:
	id "(" [expr ("," expr)*] ")"
;

l_value:
	id | string_literal | l_value "[" expr "]"
;

expr:
	int_const |
	char_const | 
	l_value | 
	"(" expr ")" | 
	func_call |
	("+" | "-") expr | 
	expr ("+" | "-" | "*" | "/" | "%") expr |
	"true" | "false" | "!" expr | expr ("&" | "|") expr
;

cond:
	expr |
	"(" cond ")" |
	"not" cond |
	cond ("and" | "or") cond |
	expr ("=" | "<>" | "<" | ">" | "<=" | ">=") expr
;	

%%


void yyerror (const char *msg) {
  fprintf(stderr, "Dana error: %s\n", msg);
  fprintf(stderr, "Aborting, I've had enough with line %d...\n" , number_of_lines );
  exit(1);
}


int main() {
  if (yyparse()) return 1;
  printf("Compilation was successful.\n");
  return 0;
}