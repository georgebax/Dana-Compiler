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

int end_returned = false;

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
%s BEGEND
%s INDENT

%%

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
														          tabs = count_tabs( yytext ); 
																  printf(">>>> indentation_depth = %d\n", indentation_depth);
																  printf("tabs = %d in line %d\n", tabs, number_of_lines);
														          if ( tabs <= def_depth && end_returned ) {
  																    indentation_depth = tabs;
																  	no_of_begins++;
																  	number_of_lines--; // because the newline will be parsed twice ;)
																  	printf("> Returning begin due to mad case, @ %d\n", number_of_lines);
																  	printf(">> no_of_begins = %d\n", no_of_begins);
																  	def_depth--; // this PROBABLY does the job ;)
																  	end_returned = false; // mark that we will need to return an end to that begin
																  	return T_begin; 														          	
														          }
																  if ( tabs > indentation_depth ) { 
																  	indentation_depth = tabs;
																  	if (check_def_case()) {
																  	  puts(">>> Nested def found!");
																  	  def_depth = tabs;
																  	  printf("> def depth now set to %d\n", def_depth);
																  	  return T_ind_def;
																  	}
																  	else if (check_var_case()) {
																  	  puts(">>> ind var");
																  	}
																  	else { // normal case, at this point we are in a block!
																	  no_of_begins++;
																	  printf("> Returning (normal) begin, @ %d\n", number_of_lines);
																	  printf(">> no_of_begins = %d\n", no_of_begins);
																	  return T_begin; 
																  	}
																  }
																  else if ( tabs < indentation_depth ) {
																  	//printf("end\n");
																  	printf("indentation_depth set from %d to %d\n", indentation_depth, tabs);
  																    indentation_depth = tabs;
																  	printf("> Returning end,   @ %d\n", number_of_lines);
																  	printf(">> no_of_ends = %d\n", no_of_ends);

																  	if ( tabs <= def_depth ) {
																	  printf("in new case\n");
																	  printf("unputting %d tabs\n", tabs);
																	  for ( i = 0; i < tabs; i++ ) 
																	  	unput('\t');
																	  unput('\n');	
																	  end_returned = true;										
  																  	  no_of_ends++;
																  	  return T_end;
																  	}	 
																  }
																  else {  // tabs == indentation_depth  
																    end_returned = false;
																    printf("> No indent action taken!\n");
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


\'{HEN}\'														{ return T_hex; }


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
	case_id = 1;
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