%{


/*----------------------------------------Libraries----------------------------------------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "lexer.h"

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


void yyerror(const char *msg);
extern int number_of_lines;
extern int d[];
void fatal(char *msg);

ast a;
/*----------------------------------------Definitions--------------------------------------------------------------------------------------------------------------------*/


%}

%union{
  ast a;
  char c;
  int i;
  char * s;
  Type t;
}

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
%token T_if "if"
%token T_is "is"
%token T_int "int"
%token T_loop "loop"
%token T_not "not"
%token T_or "or"
%token T_ref "ref"
%token T_return "return"
%token T_skip "skip"
%token T_true 1  // instead of string
%token T_false 0 // instead of string
%token T_var "var"
%token T_not_equal "<>"
%token T_greater_equal ">="
%token T_less_equal "<="
%token T_assign
%token T_escape

%token<s> T_string
%token<s> T_id
%token<i> T_const
%token<c> T_char_const
%token<h> T_hex

%token T_ind_def

%left "or"
%left "and"
%nonassoc "not"
%nonassoc '=' "<>" '<' '>' "<=" ">="
%left '+' '-' '|'
%left '*' '/' '%' '&'
%nonassoc '!'
%left UMINUS UPLUS

%type<a> program
%type<a> stmt_list
%type<a> stmt
%type<a> expr
%type<a> header // we'll see about that

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

%%

program
:	func_def { t = $$ = $1; }
;

func_def
:	T_def header local_def_star block { $$ = ast_funcdef($2, $4, $5); }
;

local_def_star
:	local_def local_def_star 	{ $$ = ast_seq($2, $3); }
|	/*nothing*/ 				{ $$ = NULL; }
;

header
:	T_id is_data_type_req fparameters_req { $$ = ast_header($1, $2, $3); }
;

is_data_type_req 
:	T_is data_type { $$ = ast_isdatatype($2); }
|	/*nothing*/    { $$ = NULL; } // CHECK THIS
;

fparameters_req
:	':' fpar_def comma_fpar_def_star	{ $$ = ast_seq($2, $3); }
|	/*nothing*/  						{ $$ = NULL; }
;

comma_fpar_def_star
:	',' fpar_def comma_fpar_def_star 	{ $$ = ast_seq{$2, $3}; } //NEEDS CHECK
|	/*nothing*/  						{ $$ = NULL; }
;

fpar_def
:	id_plus T_as fpar_type { $$ = ast_seq($1, $2); }
;

id_plus /*(id)+*/
:	T_id         { $$ = ast_seq($1, NULL); }
|	T_id id_plus { $$ = ast_seq($1, $2); }
;

data_type
:	T_int  { $$ = $1; /*string! prob need to put something else!*/ }
|	T_byte { $$ = $1; /*string! prob need to put something else!*/ }
;

type 
:	data_type brackets_int_const_star { $$ =  }
;

fpar_type
:	type                                      { $$ = ast_fpartype($1, NULL); }
|	T_ref data_type                           { $$ = ast_fpartype($1, NULL); }
|	data_type '[' ']' brackets_int_const_star { $$ = ast_fpartype($1, ); }
;

brackets_int_const_star
:	'[' T_const ']' brackets_int_const_star
|	/*nothing*/
;

local_def
:	func_def  { $$ = ast_localdef($1); }
|	func_decl { $$ = ast_localdef($1); }
|	var_def   { $$ = ast_localdef($1); }
;

func_decl
:	"decl" header { $$ = ast_funcdecl($2); }
;

var_def
:	"var" id_plus "is" type { $$ = ast_vardef($2, $4); }
;

stmt 
:	T_skip { $$ = ast_skip($1); }
|	l_value T_assign expr { $$ = ast_ass($1, $3); }
|	proc_call { $$ = ast_proccall($1); }
|	T_exit { $$ = ast_exit($1); }
|	T_return ':' expr { $$ = ast_ret($1); }
|	T_if cond ':' block elif_and_block_star else_and_block_req { $$ = ast_if($2, $4); }
|	T_loop id_req ':' block { $$ = ast_loop($2, $4); }
|	T_break colon_id_req { $$ = ast_break($2); }
|	T_continue colon_id_req { $$ = ast_cont($2); }
;

id_req 
:	/*nothing*/
|	T_id { $$ = $1; /*STRING?*/}
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
:	T_begin stmt_list T_end { $$ = ast_block($2); }
;

stmt_list
:	stmt stmt_list /*EXPERIMENTAL*/ { $$ = ast_seq($1, $2); }
|	stmt /*and then nothing*/ { $$ = ast_seq($1, NULL); }
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
:	T_const 			{ $$ = ast_const($1); }
|	T_char_const		{ $$ = ast_charconst($1); }
|	l_value				{ $$ = ast_lval($1); }
|	'(' expr ')'		{ $$ = $2; }
|	func_call			{ $$ = ast_funccall($1); }
|	'+' expr  			{ $$ = ast_op(ast_const(0), PLUS, $3); }
|	'-' expr 			{ $$ = ast_op(ast_const(0), MINUS, $3); }
|	expr '+' expr 		{ $$ = ast_op($1, PLUS, $3); }
|	expr '-' expr  		{ $$ = ast_op($1, MINUS, $3); }
|	expr '*' expr 		{ $$ = ast_op($1, TIMES, $3); }
|	expr '/' expr  		{ $$ = ast_op($1, DIV, $3); }
|	expr '%' expr 		{ $$ = ast_op($1, MOD, $3); }
|	'!' expr 			{ $$ = ast_op($2, NOT, NULL); }
|	expr '&' expr 		{ $$ = ast_op($1, AND, $3); }
|	expr '|' expr 		{ $$ = ast_op($1, OR, $3); }
|	T_true 				{ $$ = $1; /*$$ = ast_bool($1);*/ }
|   T_false				{ $$ = $1; /*$$ = ast_bool($1);*/ }
;

cond
:	expr 				{ $$ = $1; /*The  expr  node is not calculated here!*/}
| 	x-cond				{ $$ = $1; /*The x-cond node is not calculated here!*/}
;

x-cond
:	'(' x-cond ')' 					{ $$ = ast_const($1); }
|	T_not cond 						{ $$ = ast_op($2, NOT, NULL); }
|	cond T_and cond 				{ $$ = ast_op($1, AND, $3); }
|	cond T_or  cond 				{ $$ = ast_op($1, OR, $3); }
|	cond '=' cond 					{ $$ = ast_op($1 ,EQ, $3); }
|	cond T_not_equal cond 			{ $$ = ast_op($1, NE, $3); }
|	cond '<' cond 					{ $$ = ast_op($1, LT, $3); }
|	cond '>' cond 					{ $$ = ast_op($1, GT, $3); }
|	cond T_greater_equal cond 		{ $$ = ast_op($1, GE, $3); }
|	cond T_less_equal cond 			{ $$ = ast_op($1, LE, $3); }
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
  	// for (int i = 0; i < 1024; i++) printf("%d", d[i]); // print depth array
	printf( "COMPILATION SUCCESSFUL!!\n" );
	printf( "Total number of lines : %d\n" , number_of_lines );
	return 0;
}