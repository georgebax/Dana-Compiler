#ifndef __AST_H__
#define __AST_H__

#include "symbol.h"

#define STRMAX 128

typedef enum {
	FUNCDEF, AS, BREAK, CONT, DEF, INT, BYTE, DECL, IF, ELIF, ELSE, EXIT, TRUE, FALSE, IS, LOOP, REF, RETURN, SKIP, VAR,
	LPAR, RPAR, LBRAC, RBRAC, COMMA, COLON, ASSIGN,
	HEADER, IDR, TYPE, FPARTYPE, PROCCALL, FUNCCALL, LVAL, BOOL,
	PRINT, FOR, SEQ,
  	ID, NUM_CONST, CHAR_CONST, STRING, HEX, ESC, 
  	PLUS, MINUS, TIMES, DIV, MOD,
  	LT, GT, LE, GE, EQ, NE, AND_COND, OR_COND, NOT_COND, AND_LOG, OR_LOG, NOT_LOG, BLOCK
} kind;

typedef struct node {
	kind k;
	char id;
	char* s;
	int num;
	struct node *left, *right;
	struct node * header;	// FUNC node
	int nesting_diff;  		// ID and LET nodes
	int offset;        		// ID and LET nodes
	int num_vars;      		// BLOCK node
	Type type;         		// HEADER node
} *ast;

ast ast_funcdef(ast h, ast l, ast r);
ast ast_seq(ast l, ast r);
ast ast_header(char *id, ast idr, ast fpr);
ast ast_idr(Type datatype); //ast_is_datatype_req
ast ast_type(Type datatype, ast bics); // brackets_int_const_star
ast ast_fpar_type(Type datatype, ast l);
ast ast_localdef(ast l, kind k);
ast ast_skip();
ast ast_ass(ast l, ast r);
ast ast_proccall(ast l, ast r);
ast ast_exit();
ast ast_ret(ast l);
ast ast_loop(char *id, ast l);
ast ast_break(char *id);
ast ast_break(char *id);
ast ast_block(ast l);
ast ast_funccall(char *id, ast l);
ast ast_lval(ast l, ast r, char *type);
ast ast_const(int n);
ast ast_charconst(char c);
ast ast_op(ast l, kind k, ast r);
ast ast_bool(int value);



#endif