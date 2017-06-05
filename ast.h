#ifndef __AST_H__
#define __AST_H__

#include "symbol.h"

typedef enum {
	AS, BREAK, CONT, DEF, INT, BYTE, DECL, IF, ELIF, ELSE, EXIT, TRUE, FALSE, IS, LOOP, REF, RETURN, SKIP, VAR
	LPAR, RPAR, LBRAC, RBRAC, COMMA, COLON, ASSIGN
	PRINT, FOR, IF, SEQ/*NOTED*/,
  	ID, NUM_CONST, CHAR_CONST, STRING, HEX, ESC, 
  	PLUS, MINUS, TIMES, DIV, MOD,
  	LT, GT, LE, GE, EQ, NE, AND_COND, OR_COND, NOT_COND, AND_LOG, OR_LOG, NOT_LOG, DECL, BLOCK
} kind;

typedef struct node {
	kind k;
	char id;
	int num;
	struct node *left, *right;
	node * header;     // FUNC node
	int nesting_diff;  // ID and LET nodes
	int offset;        // ID and LET nodes
	int num_vars;      // BLOCK node
	Type type;         // HEADER node
} *ast;
