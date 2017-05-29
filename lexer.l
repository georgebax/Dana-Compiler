%{

#define true 1
#define false 0

/*----------------------------------------Libraries----------------------------------------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "parser.h"
#include "lexer.h"
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


#define T_eof 0

/*----------------------------------------Function Declarations----------------------------------------------------------------------------------------------------------*/
int count_tabs(char *txt );
void yyerror (const char *msg);
void begin_indent_mode();
void begin_default_mode();
int check_def_case();
int check_var_case();
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


/*----------------------------------------Variables----------------------------------------------------------------------------------------------------------------------*/
int number_of_lines = 1;
int number_of_errors = 0;
int nesting = 0;
int indentation_depth = 0;
char hex_num[3];
int tabs = 0;
int tab_start = 0;
int flag = 1;
int no_of_begins = 0;
int no_of_ends = 0;
int case_id = 0;
int def_depth = 0;
int i;

int d[1024]; // variable size (?)
int depth_runner = 0;
int dd_reduction;

int ends_tbr = false;   // T_ends to be returned
int begins_tbr = false; // T_begins to be returned

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

%}

L [A-Za-z]	
D [0-9]						
C [^'"\\\n]				
HEX [0-9|A-F|a-f] 	
HEN \\x{HEX}{HEX}			
ESC \\(n|t|r|0|\\|\'|\")	
SC [^\n\"]  				
QC \\(\")
W [ ]						
T [\t]

%x COMMENT
%x SPECIAL
%s BEGEND
%s INDENT

%%

<SPECIAL>. 														{ //printf("#> %s\n", yytext);
																  unput(*yytext);
																  if ( ends_tbr > 0 )  {
																  	ends_tbr--;
																  	no_of_ends++;
																  	printf("> Returning end, %d more\n", ends_tbr);
																  	return T_end;
																  }
																  if ( begins_tbr > 0) {
																  	begins_tbr--;
																  	no_of_begins++;
																  	printf("> Returning begin, %d more\n", begins_tbr);
																  	return T_begin;
																  }
																  puts("$ going back to INDENT");
																  BEGIN(INDENT);
																}

<BEGEND>"begin"													{ no_of_begins++; return T_begin; }

<BEGEND>"end"													{ no_of_ends++; return T_end; }

<INDENT>"begin"													{ yyerror( "\"Begin\" keyword not supported in this mode!" ); }

<INDENT>"end"													{ yyerror( "\"End\" keyword not supported in this mode!" ); }

and                                                             { return T_and; }

as                                                             	{ return T_as; }

break                                                           { return T_break; }

def																{ return T_def; }

byte                                                            { return T_byte; }

continue                                                        { return T_continue; }

decl                                                            { return T_decl; }

elif                                                            { return T_elif; }

else                                                            { return T_else; }

exit                                                            { return T_exit; }

false															{ return T_false; }

if                                                              { return T_if; }

is                                                              { return T_is; }

int                                                             { return T_int; }

loop                                                            { return T_loop; }

not                                                             { return T_not; }

or                                                              { return T_or; }

ref                                                             { return T_ref; }

return                                                          { return T_return; }

skip                                                            { return T_skip; }

true                                                            { return T_true; }

var                                                             { return T_var; }

{D}+								 							{ return T_const; }

{L}({L}|{D}|"_")*												{ return T_id; }

<INDENT>\n{T}+"#".*					                        	{ number_of_lines++; /*this fixes the error when a comment line starts with tabs*/}

<INDENT>\n{T}+"(*"												{ nesting = 1; BEGIN(COMMENT);}

<INDENT>\n{T}+													{ number_of_lines++;
														          tabs = count_tabs( yytext ); printf("# tabs = %d @ %d\n", tabs, number_of_lines);

														          ends_tbr = 0;
														          begins_tbr = 0;

														          if ( depth_runner > tabs ) {
														          	printf("$ depth_runner = %d, tabs = %d\n", depth_runner, tabs);
														          	dd_reduction = 0;
														          	while ( depth_runner > def_depth ) {
														          	  if ( d[depth_runner-1] == 1 ) {
														          	  	d[depth_runner-1] = 0;
														          	  	ends_tbr++;
														          	  }
														          	  else if ( d[depth_runner-1] == 2 ) {
														          	  	d[depth_runner-1] = 0;
														          	  	begins_tbr++; // both need to be returned then ;)
														          	  	ends_tbr++;
														          	  	dd_reduction++;
														          	  }
														              depth_runner--;
														          	}
														          	def_depth -= dd_reduction; // dealt with one function

														          	printf("$$ %d ends and %d begins tbr\n", ends_tbr, begins_tbr);
														          	BEGIN(SPECIAL);

														          }

														          // should enter the next lines ONLY if the depth_runner
														          // meets the new indentation depth, which is: tabs

																  if ( tabs > indentation_depth ) { 
																  	indentation_depth = tabs;
																  	depth_runner = tabs;
																  	if (check_def_case()) {
																  	  def_depth = tabs;
																  	  d[tabs] = 2;
																  	  printf("> def depth now set to %d\n", def_depth);
																  	  return T_ind_def;
																  	}
																  	else if (check_var_case()) { // work to be done here 
																  	  puts(">>> ind var");
																  	}
																  	else {
																  	  no_of_begins++;
																  	  d[tabs] = 1; // block opened at this depth, not yet closed
																  	  puts(">>> normal block begin");
																  	  return T_begin;
																  	}
																  }
																  else if ( tabs < indentation_depth ) {
																  	indentation_depth = tabs;
																  	depth_runner = tabs;
																  }


														      	}


<INDENT><<EOF>>													{ printf("Encountered EOF\n");
																  if ( no_of_begins > no_of_ends ) {
																  	no_of_ends++;
																  	printf("> Returning end,   @ %d\n", number_of_lines);
																  	return T_end;
																  }
  																  printf("> Returning EOF!\n");
																  return T_eof;
																}															

<BEGEND>\n{T}+													{ number_of_lines++; }


\'{HEN}\'														{ yylval.intval = htoi(yytext); return T_hex; }


\'{ESC}\'														{ return T_escape; }


\'({C})\' 														{ return T_char_const; }


\"({QC}|{SC})*\"												{ return T_string; }


"#".*						                        			{ number_of_lines++; }



"(*"															{ nesting = 1; BEGIN(COMMENT);}
<COMMENT>"(*" 													{ nesting++; }
<COMMENT>"*)"		  				               	            { nesting--; 
																  if ( nesting == 0 ) {
																  	if (case_id == 0)
																  	  BEGIN(BEGEND); 
																  	else
																  	  BEGIN(INDENT);
																  }
																}

<COMMENT>"\n"													{ number_of_lines++; }
<COMMENT><<EOF>>    											{ yyerror( "EOF encountered inside comment" ); }
<COMMENT>"*"													{ /*nothing*/ }
<COMMENT>[^*\n]													{ /*nothing*/ }


\n 																{ number_of_lines++; }


"+"																{ return yytext[0]; }


"-"																{ return yytext[0]; }


"*"																{ return yytext[0]; }

	
"/" 		                            		                { return yytext[0]; }

"%"                                                             { return yytext[0]; }

"!"                                                             { return yytext[0]; }

"&"                                                             { return yytext[0]; }

"|"                                                             { return yytext[0]; }

"="                                                             { return yytext[0]; }

"<>"                                                            { return T_not_equal; }	

"<"                                                             { return yytext[0]; }

">"                                                             { return yytext[0]; }

"<="                                                            { return T_less_equal; }

">="                                                            { return T_greater_equal; }

"("																{ return yytext[0]; }

")"																{ return yytext[0]; }

"["																{ return yytext[0]; }
	
"]"																{ return yytext[0]; }

","																{ return yytext[0]; }

":"																{ return yytext[0]; }

":="															{ return T_assign; }

{W}|{T}															/* do nothing! */ 


.																{ number_of_errors++; 
																  yyerror( "illegal character" ); }


%%

int count_tabs( char *txt ) {
	int i;
	int num_of_tabs = 0;
	for ( i = 0; i <= strlen(txt); i++ )
		if ( txt[ i ] == '\t' )
			num_of_tabs++;
	return num_of_tabs;
}

int switch_hex( char c ) {
	switch(c) {
	case 'a':
	case 'A':
		return 10;
	case 'b':
	case 'B':
		return 11;
	case 'c':
	case 'C':
		return 12;
	case 'd':
	case 'D':
		return 13;
	case 'e':
	case 'E':
		return 14;
	case 'f':
	case 'F':
		return 15;
	default :
		return atoi(c);
}

int htoi( char *hex ) { // converts '/x{HEX}{HEX}/' to integer
	return switch_hex(yytext[3]) * 16 + switch_hex(yytext[4]);
}

int check_def_case() {
	char c;
	if ( ((c = input()) == EOF) || (c != 'd') ) {
		unput('d');
		return false;
	}
	if ( ((c = input()) == EOF) || (c != 'e') ) {
		unput('e'); // unput from finish to start!
		unput('d'); 
		return false;
	}
	if ( ((c = input()) == EOF) || (c != 'f') ) {
		unput('f'); // unput from finish to start!		
		unput('e'); 
		unput('d'); 
		return false;
	}
	unput('f'); // unput from finish to start!		
	unput('e'); 
	unput('d'); 
	return true;
}

int check_var_case() {
	char c;
	if ( ((c = input()) == EOF) || (c != 'v') ) {
		unput('v');
		return false;
	}
	if ( ((c = input()) == EOF) || (c != 'a') ) {
		unput('a'); // unput from finish to start!
		unput('v'); 
		return false;
	}
	if ( ((c = input()) == EOF) || (c != 'r') ) {
		unput('r'); // unput from finish to start!		
		unput('a'); 
		unput('v'); 
		return false;
	}
	unput('r'); // unput from finish to start!		
	unput('a'); 
	unput('v'); 
	return true;
}

void fatal(char *msg) {
	fprintf(stderr, "%s\n", msg);
	exit(2);
}

void yyerror ( const char *msg ) {
	fprintf( stderr, "DANA ERROR: %s\n" , msg );
 	fprintf( stderr, "ERROR FOUND IN LINE %d...\n" , number_of_lines );
  	exit( 1 );
}

void begin_default_mode() {
	case_id = 0;
	BEGIN(BEGEND);
}

void begin_indent_mode() {
	int i;
	case_id = 1;
	//d = malloc( sizeof(int) * 1024 );
	for ( i = 0; i < 1024; i++ ) d[i] = 0; // init the depth array
	BEGIN(INDENT);
}

/*
int main(int argc, char *argv[]) {

    FILE *fp;

    if (argc == 1) fatal("Too few arguments! Type dana --help,-h for usage information");

    if (strcmp(argv[1],"-i") == 0 || strcmp(argv[1],"--indents") == 0) {
        printf(">> Indentation mode\n");
		yyin = fopen(argv[2], "r"); //Open file and redirect yylex to it
		if (yyin == NULL) fatal("File not found");
        fp = fopen(argv[2], "r");
        yyrestart(fp); 
        BEGIN(INDENT);
    }
    else if (strcmp(argv[1],"-h") == 0 || strcmp(argv[1],"--help") == 0) {
        usageInformation();
    }
    else { // DEFAULT (BEGIN-END)
        printf(">> Default mode\n");
        fp = fopen(argv[1], "r");
        yyrestart(fp);
        BEGIN(BEGEND);
    }

    int token;

    do {
        token = yylex();
        printf("@ line:%d \t token=%d \t lexeme=\"%s\"\n", number_of_lines, token, yytext);
    } while (token != T_eof);
    return 0;
}
*/