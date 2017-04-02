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
	"def" header local_def_req block
;

local_def_req:
	(local_def)* 
;

header:
	id ("is" data_type) (":" fpar_def ("," fpar_def)*)
;

fpar_def:
	(id)+ "as" fpar_type
;

data_type:
	"int" | "byte"
;

type:
	data_type ("[" int_const "]")
;

fpar_type:
	type | "ref" data_type | data_type "[" "]" ("[" int_const "]")*
;

local_def:
	func_def | func_decl | var_def
;

stmt:
	"skip" | 
	l_value ":=" expr | 
	proc_call | 
	"exit" | 
	"return" ":" expr | 
	"if" cond ":" block ("elif" cond ":" block)* ["else" ":" block] |	
	"loop" [id] ":" block |
	"break" [":" id] |
	"continue" [":" id]
;

block:
	"begin" (stmt)+ "end" | 
	stmt // CHECK THAT!!! it had an auto-end
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