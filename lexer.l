%{


/*----------------------------------------To-do---------------------------------------------------------------------------------------------------------------------------
> instead of printf, we got to return something  (T_*) (??)
> fix ints ( 007 -> 7)
> push error codes to some struct?
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/*----------------------------------------Libraries----------------------------------------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


/*----------------------------------------Function Declarations----------------------------------------------------------------------------------------------------------*/
void error_handler();
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


/*----------------------------------------Variables----------------------------------------------------------------------------------------------------------------------*/
int number_of_lines = 0;
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
W [ ]

%%

begin 								printf( "Begin statement, indentation depth increased to %d\n", ++indentation_depth );

end 								printf( "End statement, indentation depth decreased to %d\n", --indentation_depth );

and                                                             printf( "And statement\n" );

as                                                             	printf( "As statement\n" );

break                                                           printf( "Break statement\n" );

def								printf( "Def statement\n" );

byte                                                            printf( "Byte statement\n" );

continue                                                        printf( "Continue statement\n" );

decl                                                            printf( "Decl statement\n" );

elif                                                            printf( "Elif statement\n" );

else                                                            printf( "Else statement\n" );

exit                                                            printf( "Exit statement\n" );

false								printf( "False statement\n" );

if                                                              printf( "If statement\n" );

is                                                              printf( "Is statement\n" );

int                                                             printf( "Int statement\n" );

loop                                                            printf( "Loop statement\n" );

not                                                             printf( "Not statement\n" );

or                                                              printf( "Or statement\n" );

ref                                                             printf( "Ref statement\n" );

return                                                          printf( "Return statement\n" );

skip                                                            printf( "Skip statement\n" );

true                                                            printf( "True statement\n" );

var                                                             printf( "Var statement\n" );

{D}+	 							printf( "integer = %d\n" , atoi(yytext) ); 

{L}({L}|{D}|"_")*						printf( "identifier = %s\n", yytext );

\n								number_of_lines++;

\'{HEN}\'							printf( "Hexademical Number = H%s\n", strncpy(hex_num, yytext + 3, 2) );

\'{ESC}\'							printf( "Escape Character = %s\n" , yytext );

\'({C})\' 							printf( "Single Character = %s\n" , yytext );

\"({QC}|{SC})*\"						printf( "String = %s\n",yytext );

"#"				                        	printf( "Start of one line comment\n" );

"(*" 								{ printf( "Start of many lines comment\n" ); comment_depth++; }


"*)"  				                                { printf( "End of many lines comment\n" ); 
								comment_depth--; 
								if ( comment_depth == 0 ) puts( "Comments Closed!" ); }


"+"								printf( "Plus Token\n" );


"-"								printf( "Minus Token\n" );

"*"								printf( "Multiply Token\n" );

"/"                             		                printf( "Division Token\n" );

"%"                                                             printf( "Modulo Token\n" );

"!"                                                             printf( "Logical Not Token\n" );

"&"                                                             printf( "Logical And Token\n" );

"|"                                                             printf( "Logical Or Token\n" );

"="                                                             printf( "Equal Token\n" );

"<>"                                                            printf( "Not Equal Token\n" );

"<"                                                             printf( "Less Than Token\n" );

">"                                                             printf( "Greater Than Token\n" );

"<="                                                            printf( "Less or Equal Token\n" );

">="                                                            printf( "Greater or Equal Token\n" );

"("								printf( "Left Parenthesis\n" );

")"								printf( "Right Parenthesis\n" );

"["								printf( "Left Bracket\n" );

"]"								printf( "Right Bracket\n" );

","								printf( "Comma\n" );

":"								printf( "Colon\n" );

":="								printf( "Assignment\n" );

{W}								/* do nothing! */ 

.								{ number_of_errors++; error_handler( yytext , number_of_lines ); }

%%

void error_handler(char *error , int n) {
        printf( "Error in line %d : %s\n" , n , error );
}


int main() {
	yylex();
	printf( "Total Lines		     : %d\n" , number_of_lines );
	printf( "Total Number of Errors found : %d\n" , number_of_errors );
	return 0;
}

