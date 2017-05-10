%{


/*----------------------------------------Libraries----------------------------------------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexer.h"

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


void yyerror(const char *msg);
extern int number_of_lines;
void fatal(char *msg);

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
%token T_not_equal "<>"
%token T_greater_equal ">="
%token T_less_equal "<="
%token T_assign
%token T_char_const
%token T_escape
%token T_hex

%token T_ind_def

%left "or"
%left "and"
%nonassoc "not"
%nonassoc '=' "<>" '<' '>' "<=" ">="
%left '+' '-' '|'
%left '*' '/' '%' '&'
%nonassoc '!'
%left UMINUS UPLUS


/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

%%

program
:	func_def
;

func_def
:	T_def header T_ind_def_req local_def_star block
;

T_ind_def_req
:	T_ind_def
|	/*nothing*/
;

local_def_star
:	local_def local_def_star
|	/*nothing*/ 
;

header
:	T_id is_data_type_req fparameters_req
;

is_data_type_req 
:	T_is data_type
|	/*nothing*/
;

fparameters_req
:	':' fpar_def comma_fpar_def_star
|	/*nothing*/ 
;

comma_fpar_def_star
:	',' fpar_def comma_fpar_def_star
|	/*nothing*/
;

fpar_def
:	id_plus T_as fpar_type
;

id_plus /*(id)+*/
:	T_id /*and then nothing*/
|	T_id id_plus
;

data_type
:	T_int
|	T_byte
;

type /*INT_CONST NEEDS ATTENTION!*/
:	data_type brackets_int_const_star
;

fpar_type
:	type
|	T_ref data_type 
|	data_type '[' ']' brackets_int_const_star
;

brackets_int_const_star
:	'[' T_const ']' brackets_int_const_star
|	/*nothing*/
;

local_def
:	func_def
|	func_decl
|	var_def
;

func_decl
:	"decl" header
;

var_def
:	"var" id_plus "is" type
;

stmt
:	T_skip 
|	l_value T_assign expr 
|	proc_call 
|	T_exit 
|	T_return ':' expr 
|	T_if cond ':' block elif_and_block_star else_and_block_req 
|	T_loop id_req ':' block 
|	T_break colon_id_req 
|	T_continue colon_id_req
;

id_req
:	/*nothing*/
|	T_id
;

colon_id_req
:	':' T_id
|	/*nothing*/
;

elif_and_block_star
:	T_elif cond ':' block elif_and_block_star
|	/*nothing*/
;	

else_and_block_req
:	T_else ':' block
|	/*nothing*/
;

block
:	T_begin stmt_plus T_end
;

stmt_plus
:	stmt stmt_plus /*EXPERIMENTAL*/
|	stmt /*and then nothing*/
;

proc_call
:	T_id colon_expr_req
;

colon_expr_req
:	/*nothing*/ 
|	':' expr comma_expr_star
;

func_call
:	T_id '(' expr_comma_expr_req ')'
;

expr_comma_expr_req
:	/*nothing*/ 
|	expr comma_expr_star
;

comma_expr_star
:	/*nothing*/ 
|	',' expr comma_expr_star
;

l_value
:	T_id | T_string | l_value '[' expr ']'
;

expr
:	T_const 
|	T_char_const 
|	l_value 
|	'(' expr ')' 
|	func_call
|	'+' expr  
|	'-' expr 
|	expr '+' expr 
|	expr '-' expr  
|	expr '*' expr  
|	expr '/' expr  
|	expr '%' expr 
|	T_true | T_false
|	'!' expr 
|	expr '&' expr 
|	expr '|' expr
;

cond
:	expr
| 	x-cond
;

x-cond
:	'(' x-cond ')' 
|	T_not cond 
|	cond T_and cond 
|	cond T_or  cond 
|	cond '=' cond 
|	cond T_not_equal cond 
|	cond '<' cond 
|	cond '>' cond 
|	cond T_greater_equal cond 
|	cond T_less_equal cond
;	


%%

void usageInformation() {
	    fprintf(stderr,
        "\n  Usage"
        "\n    $ dana [option] [input file]"
        "\n"
        "\n  Options"
        "\n    --indents, -i\tCompile using indentation instead of begin-end keywords"
        "\n    --help, -h   \tDisplay help message"
        "\n"
    );
    exit(1);
}


int main(int argc, char *argv[]) {
	FILE *fp;

	if (argc == 1) fatal("Too few arguments! Type dana --help,-h for usage information");

	if (strcmp(argv[1],"-i") == 0 || strcmp(argv[1],"--indents") == 0) {
		//yyin = fopen(filename, "r"); //Open file and redirect yylex to it
	    fp = fopen(argv[2], "r");
		if (fp == NULL) fatal("File not found");
		printf("> Indent mode\n");
	    yyrestart(fp); 
	    begin_indent_mode();
	    // BEGIN(INDENT);
	}
	else if (strcmp(argv[1],"-h") == 0 || strcmp(argv[1],"--help") == 0)
	    usageInformation();
	else { // DEFAULT (BEGIN-END)
	    fp = fopen(argv[1], "r");
	    printf("> Default mode\n");
	    yyrestart(fp);
	    begin_default_mode();
	    // BEGIN(BEGINEND);
    }

  	if ( yyparse() ) return 1;

	printf( "COMPILATION SUCCESSFULL!!\n" );
	printf( "Total number of lines : %d\n" , number_of_lines );
	return 0;
}