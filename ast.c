#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "error.h"
#include "symbol.h"

static ast ast_make (kind k, char* s, int n, ast l, ast r, Type t) {
  ast p;
  // memset(p, 0, sizeof(node)); // size of ast node
  if ((p = malloc(sizeof(struct node))) == NULL) {
    fatal( "Out of memory!" );
    exit(1);
  }
  p->k = k;
  // p->id = c;
  p->num = n;
  p->left = l;
  p->right = r;
  p->type = t;
  if (s) {
    printf("s = %s\n", s);
    p->s = (char *) malloc(sizeof(char) * strlen(s)); 
    strcpy(p->s, s); 
  }
  printf("KIND = %ud\n", k);
  return p;
}

ast ast_funcdef(ast h, ast l, ast r) {
	return ast_make(FUNCDEF, NULL, 0, l, r, NULL);
}

ast ast_seq(ast l, ast r) {
	return ( r ? ast_make(SEQ, NULL, 0, l, r, NULL) : l);
}

ast ast_header(char *id, ast idr, ast fpr) {
  return ast_make(HEADER, id, 0, idr, fpr, NULL);
}

ast ast_idr(Type datatype) { //ast_is_datatype_req
  return ast_make(IDR, NULL, 0, NULL, NULL, datatype);
}

ast ast_type(Type datatype, ast bics) { // brackets_int_const_star
  return ast_make(TYPE, NULL, 0, bics, NULL, datatype);
}

ast ast_fpartype(Type datatype, ast l) {
  return ast_make(FPARTYPE, NULL, 0, l, NULL, datatype);
}

ast ast_localdef(ast l, kind k) {
  return ast_make(k, NULL, 0, l, NULL, NULL);
}

ast ast_funcdecl(ast header) {
  return ast_make(FUNCDECL, NULL, 0, header, NULL, NULL);
}

ast ast_vardef(ast l, ast r) {
  return ast_make(VARDEF, NULL, 0, l, r, NULL);
}

ast ast_skip() {
  return ast_make(SKIP, NULL, 0, NULL, NULL, NULL);
}

ast ast_ass(ast l, ast r) {
  return ast_make(ASSIGN, NULL, 0, l, r, NULL);
}

ast ast_proccall(ast l, ast r) {
  return ast_make(PROCCALL, NULL, 0, l, r, NULL);
}

ast ast_exit() {
  return ast_make(EXIT, NULL, 0, NULL, NULL, NULL);
}

ast ast_ret(ast l) {
  return ast_make(RETURN, NULL, 0, l, NULL, NULL);
}

ast ast_if(ast l, ast r) {
  return ast_make(IF, NULL, 0, l, r, NULL);
}

ast ast_elif(ast l, ast r) {
  return ast_make(ELIF, NULL, 0, l, r, NULL);  
}

ast ast_else(ast l) {
  return ast_make(ELSE, NULL, 0, l, NULL, NULL);  
}

ast ast_loop(ast id_node, ast l) {
  return ast_make(LOOP, (id_node ? id_node->s : NULL), 0, l, NULL, NULL);
}

ast ast_break(ast id_node) {
 return ast_make(BREAK, (id_node ? id_node->s : NULL), 0, NULL, NULL, NULL); 
}

ast ast_cont(ast id_node) {
 return ast_make(CONT, (id_node ? id_node->s : NULL), 0, NULL, NULL, NULL); 
}

ast ast_id(char *id) {
  return ast_make(ID, id, 0, NULL, NULL, NULL);
}

// elseif, etc


ast ast_block(ast l) {
  return ast_make(BLOCK, NULL, 0, l, NULL, NULL); 
}

ast ast_funccall(char *id, ast l) {
  return ast_make(FUNCCALL, id, 0, l, NULL, NULL);
}

ast ast_lval(ast l, ast r, char *type) {
  return ast_make(LVAL, type, 0, l, r, NULL);
}

ast ast_const(int n) {
  return ast_make(NUM_CONST, NULL, n, NULL, NULL, NULL);
}

ast ast_charconst(char c) {
  char s[2] = {c, '\0'}; 
  return ast_make(CHAR_CONST, s, 0, NULL, NULL, NULL);
}

ast ast_op(ast l, kind k, ast r) {
  return ast_make(k, NULL, 0, l, r, NULL);
}

ast ast_bool(int value) {
  return ast_make(BOOL, NULL, value, NULL, NULL, NULL);
}