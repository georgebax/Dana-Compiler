%{

/*------------------------------------------To-do--------------------------------------------------------------------------------------------------------------------------
> instead of printf, we got to return something  (T_*) (??)
> fix ints ( 007 -> 7)
> push error codes to some struct?
> fix the layout shit with the tabs
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


/*----------------------------------------Libraries----------------------------------------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


/*----------------------------------------Definitions--------------------------------------------------------------------------------------------------------------------*/
#define T_eof 0

#define T_and 1000
#define T_as 1001
#define T_begin 1002
#define T_break 1003
#define T_byte 1004
#define T_continue 1005
#define T_decl 1006
#define T_def 1007
#define T_elif 1008
#define T_else 1009
#define T_end 1010
#define T_exit 1011
#define T_false 1012
#define T_if 1013
#define T_is 1014
#define T_int 1015
#define T_loop 1016
#define T_not 1017
#define T_or 1018
#define T_ref 1019
#define T_return 1020
#define T_skip 1021
#define T_true 1022
#define T_var 1023

#define T_id 1024
#define T_const 1025
#define T_string 1026
#define T_greater_equal 1027
#define T_less_equal 1028
#define T_assign 1029
#define T_char_const 1030
#define T_not_equal 1031
#define T_escape 1032
#define T_hex 1033

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



/*----------------------------------------Function Declarations----------------------------------------------------------------------------------------------------------*/
void error_handler();
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


/*----------------------------------------Variables----------------------------------------------------------------------------------------------------------------------*/
int number_of_lines = 1;
int number_of_errors = 0;
int comment_depth = 0;
int indentation_depth = 0;
char hex_num[3];
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
W [ \t]						

%%

begin 															{ printf( "Begin statement(code %d), indentation depth increased to %d\n" , T_begin , ++indentation_depth ); 
																  return T_begin; }

end 															{ printf( "End statement(code %d), indentation depth decreased to %d\n" , T_end , --indentation_depth );
																  return T_end; }

and                                                             { printf( "And statement(code %d)\n" , T_and );
																  return T_and; }

as                                                             	{ printf( "As statement(code %d)\n" , T_as );
																  return T_as; }

break                                                           { printf( "Break statement(code %d)\n" , T_break );
																  return T_break; }

def																{ printf( "Def statement(code %d)\n" , T_def );
																  return T_def; }

byte                                                            { printf( "Byte statement(code %d)\n" , T_byte );
																  return T_byte; }

continue                                                        { printf( "Continue statement(code %d)\n" ,T_continue );
																  return T_continue; }

decl                                                            { printf( "Decl statement(code %d)\n" , T_decl );
																  return T_decl; }

elif                                                            { printf( "Elif statement(code %d)\n" , T_elif );
																  return T_elif; }

else                                                            { printf( "Else statement(code %d)\n" , T_else );
																  return T_else; }

exit                                                            { printf( "Exit statement(code %d)\n" , T_exit );
																  return T_exit; }

false															{ printf( "False statement(code %d)\n" , T_false );
																  return T_false; }

if                                                              { printf( "If statement(code %d)\n" , T_if );
																  return T_if; }

is                                                              { printf( "Is statement(code %d)\n" , T_is );
																  return T_is; }

int                                                             { printf( "Int statement(code %d)\n" , T_int );
																  return T_int; }

loop                                                            { printf( "Loop statement(code %d)\n" , T_loop );
																  return T_loop; }

not                                                             { printf( "Not statement(code %d)\n" , T_not );
																  return T_not; }

or                                                              { printf( "Or statement(code %d)\n" , T_or );
																  return T_or; }

ref                                                             { printf( "Ref statement(code %d)\n" , T_ref );
																  return T_ref; }

return                                                          { printf( "Return statement(code %d)\n" , T_return );
																  return T_return; }

skip                                                            { printf( "Skip statement(code %d)\n" , T_skip );
																  return T_skip; }

true                                                            { printf( "True statement(code %d)\n" , T_true );
																  return T_true; }

var                                                             { printf( "Var statement(code %d)\n" , T_var );
																  return T_var; }

{D}+								 							{ printf( "Integer(code %d) = %d\n" , T_const , atoi(yytext) ); 
																  return T_const; }

{L}({L}|{D}|"_")*												{ printf( "Identifier(code %d) = %s\n" , T_id , yytext );
																  return T_id; }

\n																{ number_of_lines++; }


\'{HEN}\'														{ printf( "Hexademical Number(code %d) = H%s\n" , T_hex , strncpy(hex_num, yytext + 3, 2) );
																  return T_hex; }


\'{ESC}\'														{ printf( "Escape Character(code %d) = %s\n" , T_escape , yytext );
																  return T_escape; }


\'({C})\' 														{ printf( "Single Character(code %d) = %s\n" , T_char_const , yytext );
																  return T_char_const; }


\"({QC}|{SC})*\"												{ printf( "String(code %d) = %s\n", T_string , yytext );
																  return T_string; }


"#"				                        						{ printf( "Start of one line comment(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }


"(*" 															{ printf( "Start of many lines comment\n" );
																  comment_depth++; }


"*)"  				                    	            		{ printf( "End of many lines comment\n" ); 
																comment_depth--; 
																if ( comment_depth == 0 ) puts( "Comments Closed!" ); }


"+"																{ printf( "Plus Token(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }


"-"																{ printf( "Minus Token(ASCII code %d\n" , yytext[0] );
																  return yytext[0]; }


"*"																{ printf( "Multiply Token(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

	
"/" 		                            		                { printf( "Division Token(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

"%"                                                             { printf( "Modulo Token(ASCII code %d\n" , yytext[0] );
																  return yytext[0]; }

"!"                                                             { printf( "Logical Not Token(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

"&"                                                             { printf( "Logical And Token(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

"|"                                                             { printf( "Logical Or Token(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

"="                                                             { printf( "Equal Token(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

"<>"                                                            { printf( "Not Equal Token(code %d)\n" , T_not_equal );
																  return T_not_equal; }	

"<"                                                             { printf( "Less Than Token(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

">"                                                             { printf( "Greater Than Token(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

"<="                                                            { printf( "Less or Equal Token(code %d)\n" , T_less_equal );
																  return T_less_equal; }

">="                                                            { printf( "Greater or Equal Token(code %d)\n" , T_greater_equal );
																  return T_greater_equal; }

"("																{ printf( "Left Parenthesis(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

")"																{ printf( "Right Parenthesis(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

"["																{ printf( "Left Bracket(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }
	
"]"																{ printf( "Right Bracket(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

","																{ printf( "Comma(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

":"																{ printf( "Colon(ASCII code %d)\n" , yytext[0] );
																  return yytext[0]; }

":="															{ printf( "Assignment(code %d)\n" , T_assign );
																  return T_assign; }

{W}																/* do nothing! */ 


.																{ number_of_errors++; 
																  error_handler( yytext , number_of_lines ); }


%%

void error_handler(char *error , int n) {
        printf( "Error in line %d : %s\n" , n , error );
}


int main() {

	int token;
	do{
		token = yylex();
	} while (token != T_eof);

	printf( "Total Lines		     : %d\n" , number_of_lines );
	printf( "Total Number of Errors found : %d\n" , number_of_errors );
	return 0;
}