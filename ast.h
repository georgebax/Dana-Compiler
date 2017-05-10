#ifndef __AST_H__
#define __AST_H__

typedef enum {
  PRINT, LET, FOR, IF, SEQ,
  ID, CONST, PLUS, MINUS, TIMES, DIV, MOD
} kind;
