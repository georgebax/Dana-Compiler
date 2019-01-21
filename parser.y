%{


/*----------------------------------------Libraries----------------------------------------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "lexer.h"
#include "symbol.h"

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


#define true  1
#define false 0

extern int number_of_lines;
extern int d[];

void yyerror(const char *msg);
void fatal(char *msg);
int yylex();     // these lines just 
int yyrestart(); // to get rid of warnings 
int ast_show(ast t);
int ast_sem(ast t);

ast t;
/*----------------------------------------Definitions--------------------------------------------------------------------------------------------------------------------*/


%}

%union{
  ast a;
  char c;
  int i;
  char* s;
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
%type<a> func_def
%type<a> local_def_star
%type<a> header
%type<a> is_data_type_req
%type<a> fparameters_req
%type<a> comma_fpar_def_star
%type<a> fpar_def
%type<a> id_plus
%type<t> data_type
%type<a> type
%type<a> fpar_type
%type<a> brackets_int_const_star
%type<a> local_def
%type<a> func_decl
%type<a> var_def
%type<a> stmt
%type<a> id_req
%type<a> colon_id_req
%type<a> elif_and_block_star
%type<a> else_and_block_req
%type<a> block
%type<a> proc_call
%type<a> colon_expr_req
%type<a> func_call
%type<a> expr_comma_expr_req
%type<a> comma_expr_star
%type<a> l_value
%type<a> expr
%type<a> x-cond
%type<a> cond
%type<a> stmt_list

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

%%

/* MARKED WITH '//' ARE THE RULES FOR WHICH WE ARE PRETTY CONFIDENT THAT THEY ARE CORRECT... */

program // 
:	func_def { t = $$ = $1; }
;

func_def //
:	T_def header local_def_star block { $$ = ast_funcdef($2, $3, $4); } // the block needs to be on the RIGHT
;

local_def_star // 
:	local_def local_def_star 	{ $$ = ast_seq($1, $2); }
|	/*nothing*/ 				{ $$ = NULL; }
;

header // think so
:	T_id is_data_type_req fparameters_req { $$ = ast_header($1, $2, $3); }
;

is_data_type_req //
:	T_is data_type { $$ = ast_idr($2); }
|	/*nothing*/    { $$ = NULL; }
;

fparameters_req // 
:	':' fpar_def comma_fpar_def_star	{ $$ = ast_seq($2, $3); }
|	/*nothing*/  						{ $$ = NULL; }
;

comma_fpar_def_star //
:	',' fpar_def comma_fpar_def_star 	{ $$ = ast_seq($2, $3); } 
|	/*nothing*/  						{ $$ = NULL; }
;

fpar_def //
:	id_plus T_as fpar_type { $$ = ast_seq($1, $3); } // all the vars on the left, type on the right
;

id_plus //
:	T_id         { $$ = ast_seq(ast_id($1), NULL); }
|	T_id id_plus { $$ = ast_seq(ast_id($1), $2); }
;

data_type //
:	T_int  { $$ = typeInteger; }
|	T_byte { $$ = typeInteger;/*typeByte;*/ } // TODO: DEFINE THAT
;

type //
:	data_type brackets_int_const_star { $$ = ast_type($1, $2); }
;

fpar_type // we have the ast_fpartype to distinguish the 3 different cases
:	type                                      { $$ = ast_fpartype(NULL, $1); /*val*/ }
|	T_ref data_type                           { $$ = ast_fpartype($2, NULL); /*ref*/}
|	data_type '[' ']' brackets_int_const_star { $$ = ast_fpartype($1, $4); /*this is by ref*/ }
; /* they will be distinguished later on! */

brackets_int_const_star // 
:	'[' T_const ']' brackets_int_const_star { $$ = ast_seq(ast_const($2), $4); }
|	/*nothing*/ { $$ = NULL; }
;

local_def //
:	func_def  { $$ = $1; }
|	func_decl { $$ = $1; }
|	var_def   { $$ = $1; }
;

func_decl //
:	"decl" header { $$ = ast_funcdecl($2); }
;

var_def // 
:	"var" id_plus "is" type { $$ = ast_vardef($2, $4); }
;

stmt // 
:	T_skip { $$ = ast_skip(); }
|	l_value T_assign expr { $$ = ast_ass($1, $3); }
|	proc_call { $$ = $1; }
|	T_exit { $$ = ast_exit(); }
|	T_return ':' expr { $$ = ast_ret($3); }
|	T_if cond ':' block elif_and_block_star else_and_block_req { $$ = ast_if($2, ast_seq($4, ast_seq($5, $6))); }
|	T_loop id_req ':' block { $$ = ast_loop($2, $4); }
|	T_break colon_id_req { $$ = ast_break($2); }
|	T_continue colon_id_req { $$ = ast_cont($2); }
;

id_req //
:	/*nothing*/ { $$ = NULL; }
|	T_id 		{ $$ = ast_id($1); }
;

colon_id_req //
:	':' T_id 	{ $$ = ast_id($2); }
|	/*nothing*/ { $$ = NULL; }
;

elif_and_block_star //
:	T_elif cond ':' block elif_and_block_star { $$ = ast_elif($2, ast_seq($4, $5)); }
|	/*nothing*/ { $$ = NULL; }
;	

else_and_block_req //
:	T_else ':' block 	{ $$ = ast_else($3); }
|	/*nothing*/ 		{ $$ = NULL; }
;

block // 
:	T_begin stmt_list T_end { $$ = ast_block($2); }
;

stmt_list // 
:	stmt stmt_list	{ $$ = ast_seq($1, $2); }
|	stmt 			{ $$ = ast_seq($1, NULL); }
;

proc_call // 
:	T_id colon_expr_req { $$ = ast_proccall(ast_id($1), $2); }
;

colon_expr_req //
:	/*nothing*/ 				{ $$ = NULL; } 
|	':' expr comma_expr_star 	{ $$ = ast_seq($2, $3); }
;

func_call //
:	T_id '(' expr_comma_expr_req ')' { $$ = ast_funccall($1, $3); }
;

expr_comma_expr_req // 
:	/*nothing*/  			{ $$ = NULL; }
|	expr comma_expr_star	{ $$ = ast_seq($1, $2); }
;

comma_expr_star // 
:	/*nothing*/  				{ $$ = NULL; }
|	',' expr comma_expr_star	{ $$ = ast_seq($2, $3); }
;

l_value // 
:	T_id 				{ $$ = ast_lval($1, NULL, "Id"); }
|	T_string 			{ $$ = ast_lval($1, NULL, "String"); }
|	l_value '[' expr ']'{ $$ = ast_lval($1, $3, "Element"); }
;

expr //
:	T_const 			{ $$ = ast_const($1); }
|	T_char_const		{ $$ = ast_charconst($1); }
|	l_value				{ $$ = $1; }
|	'(' expr ')'		{ $$ = $2; }
|	func_call			{ $$ = $1; }
|	'+' expr  			{ $$ = ast_op(ast_const(0), PLUS, $2); }
|	'-' expr 			{ $$ = ast_op(ast_const(0), MINUS, $2); }
|	expr '+' expr 		{ $$ = ast_op($1, PLUS, $3); }
|	expr '-' expr  		{ $$ = ast_op($1, MINUS, $3); }
|	expr '*' expr 		{ $$ = ast_op($1, TIMES, $3); }
|	expr '/' expr  		{ $$ = ast_op($1, DIV, $3); }
|	expr '%' expr 		{ $$ = ast_op($1, MOD, $3); }
|	'!' expr 			{ $$ = ast_op($2, NOT_LOG, NULL); }
|	expr '&' expr 		{ $$ = ast_op($1, AND_LOG, $3); }
|	expr '|' expr 		{ $$ = ast_op($1, OR_LOG, $3); }
|	T_true 				{ $$ = ast_bool(true); }
|   T_false				{ $$ = ast_bool(false); }
;

cond //
:	expr 				{ $$ = $1; /*The  expr  node is not calculated here!*/}
| 	x-cond				{ $$ = $1; /*The x-cond node is not calculated here!*/}
;

x-cond // 
:	'(' x-cond ')' 					{ $$ = $2; }
|	T_not cond 						{ $$ = ast_op($2, NOT_COND, NULL); }
|	cond T_and cond 				{ $$ = ast_op($1, AND_COND, $3); }
|	cond T_or  cond 				{ $$ = ast_op($1, OR_COND, $3); }
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
	}
	else if (strcmp(argv[1],"-h") == 0 || strcmp(argv[1],"--help") == 0)
	    usageInformation();
	else { // DEFAULT (BEGIN-END)
	    fp = fopen(argv[1], "r");
	    printf("> Default mode\n");
	    yyrestart(fp);
	    begin_default_mode();
    }
  	if ( yyparse() ) return 1;
  	ast_show(t); // shows information about the AST tree.
 //	ast_sem(t); // NOT implemented
  	printf( "COMPILATION SUCCESSFUL!!\n" );
	printf( "Total number of lines : %d\n" , number_of_lines );
	return 0;
}