%{

/*------------------------------------------To-do--------------------------------------------------------------------------------------------------------------------------
fix many line comments.We don't need to return anything!!!!
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


/*----------------------------------------Libraries----------------------------------------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


#define T_eof 0

/*----------------------------------------Function Declarations----------------------------------------------------------------------------------------------------------*/
int count_tabs(char *txt );
void yyerror (const char *msg);
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


%%

begin 															{ flag = 0; return T_begin; }

end 															{ flag = 0; return T_end; }

and                                                             { flag = 0; return T_and; }

as                                                             	{ flag = 0; return T_as; }

break                                                           { flag = 0; return T_break; }

def																{ flag = 0; return T_def; }

byte                                                            { flag = 0; return T_byte; }

continue                                                        { flag = 0; return T_continue; }

decl                                                            { flag = 0; return T_decl; }

elif                                                            { flag = 0; return T_elif; }

else                                                            { flag = 0; return T_else; }

exit                                                            { flag = 0; return T_exit; }

false															{ flag = 0; return T_false; }

if                                                              { flag = 0; return T_if; }

is                                                              { flag = 0; return T_is; }

int                                                             { flag = 0; return T_int; }

loop                                                            { flag = 0; return T_loop; }

not                                                             { flag = 0; return T_not; }

or                                                              { flag = 0; return T_or; }

ref                                                             { flag = 0; return T_ref; }

return                                                          { flag = 0; return T_return; }

skip                                                            { flag = 0; return T_skip; }

true                                                            { flag = 0; return T_true; }

var                                                             { flag = 0; return T_var; }

{D}+								 							{ flag = 0; return T_const; }

{L}({L}|{D}|"_")*												{ flag = 0; return T_id; }

\n{T}+															{ number_of_lines++;
														          tabs = count_tabs( yytext ); 
																  tabs = tabs-tab_start; 
																  printf("tabs = %d\n", tabs);
																  printf("indentation_depth = %d\n", indentation_depth);
																  if ( tabs > indentation_depth ) { 
																  	printf("begin\n");
																  	indentation_depth = tabs;
																  	return T_begin; }
																  if ( tabs < indentation_depth ) {
																  	printf("end\n");
																  	indentation_depth = tabs;
																  	return T_end; }
																  }


{T}+															{ if ( number_of_lines == 1 && flag == 1) { tab_start = count_tabs( yytext ); } }                                                                  


\'{HEN}\'														{ flag = 0; return T_hex; }


\'{ESC}\'														{ flag = 0; return T_escape; }


\'({C})\' 														{ flag = 0; return T_char_const; }


\"({QC}|{SC})*\"												{ flag = 0; return T_string; }


"#".*						                        			{ number_of_lines++; }



"(*"															{ nesting = 1; BEGIN( COMMENT );}
<COMMENT>"(*" 													{ nesting++; }
<COMMENT>"*)"		  				               	            { nesting--; if ( nesting == 0 ) BEGIN( INITIAL ); }
<COMMENT>"\n"													{ number_of_lines++; }
<COMMENT><<EOF>>    											{ yyerror( "EOF encountered inside comment" ); }
<COMMENT>"*"													{ /*nothing*/ }
<COMMENT>[^*\n]													{ /*nothing*/ }


\n 																{ number_of_lines++; }


"+"																{ flag = 0; return yytext[0]; }


"-"																{ flag = 0; return yytext[0]; }


"*"																{ flag = 0; return yytext[0]; }

	
"/" 		                            		                { flag = 0; return yytext[0]; }

"%"                                                             { flag = 0; return yytext[0]; }

"!"                                                             { flag = 0; return yytext[0]; }

"&"                                                             { flag = 0; return yytext[0]; }

"|"                                                             { flag = 0; return yytext[0]; }

"="                                                             { flag = 0; return yytext[0]; }

"<>"                                                            { flag = 0; return T_not_equal; }	

"<"                                                             { flag = 0; return yytext[0]; }

">"                                                             { flag = 0; return yytext[0]; }

"<="                                                            { flag = 0; return T_less_equal; }

">="                                                            { flag = 0; return T_greater_equal; }

"("																{ flag = 0; return yytext[0]; }

")"																{ flag = 0; return yytext[0]; }

"["																{ flag = 0; return yytext[0]; }
	
"]"																{ flag = 0; return yytext[0]; }

","																{ flag = 0; return yytext[0]; }

":"																{ flag = 0; return yytext[0]; }

":="															{ flag = 0; return T_assign; }

{W}|{T}															/* do nothing! */ 


.																{ flag = 0; number_of_errors++; 
																  yyerror( "illegal character" ); }


%%

int count_tabs( char *txt )
{
	int i;
	int num_of_tabs = 0;
	for ( i = 0; i <= strlen(txt); i++ )
		if ( txt[ i ] == '\t' )
			num_of_tabs++;
	return num_of_tabs;
}