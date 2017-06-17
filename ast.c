#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "error.h"
#include "symbol.h"

static ast ast_make (kind k, char* s, int n, ast l, ast r, Type t) {
  ast p;
  if ((p = malloc(sizeof(struct node))) == NULL)
    exit(1);
  p->k = k;
  p->id = c;
  p->num = n;
  p->left = l;
  p->right = r;
  p->type = t;
  return p;
}

ast ast_funcdef(ast h, ast l, ast r) {
	return ast_make(FUNC_DEF, NULL, 0, l, r, NULL);
}

ast ast_seq(ast l, ast r) {
	return ( r ? return ast_make(SEQ, NULL, 0, l, r, NULL) : l);
}