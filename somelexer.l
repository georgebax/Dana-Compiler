%{

/*----------------------------------------Libraries----------------------------------------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



/*-----------------------------------------Functions Declaration---------------------------------------------------------------------------------------------------------*/
void error_handler();
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



/*----------------------------------------Variables----------------------------------------------------------------------------------------------------------------------*/
int number_of_lines = 0;
int number_of_errors = 0;
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

%}

L [A-Za-z]
D [0-9]
W [ \t\n]
C [^'"\\]
HEX [0-9|A-F|a-f] 	
ESC \\(n|t|r|0|\\|\'|\"|x{HEX}{HEX})
SC [^\n] 

%%


and|as|begin|break|byte|continue|decl|def|elif|else|end|exit|false|if|is|int|loop|not|or|ref|return|skip|true|var	printf( "keyword = %s\n" , yytext );

{D}+	 														{ /*007->7*/ printf( "integer = %s\n" , yytext ); }

{L}({L}|{D}|"_")*												printf( "identifier = %s\n", yytext );

\n																number_of_lines++;

\'{ESC}\'														printf( "Escape Character = %s\n" , yytext );

"'"({C})"'" 													printf( "Single Character = %s\n" , yytext );

\"{SC}*\"														printf( "String = %s\n",yytext );



"#"                                                             printf( "Start of one line comment\n" );

"(*" 															printf( "Start of many lines comment\n" );

"*)"                                                            printf( "End of many lines comment\n" );

"+"																printf( "Plus Token\n" );

"-"																printf( "Minus Token\n" );

"*"																printf( "Multiply Token\n" );

"/"                                                             printf( "Division Token\n" );

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


"("																printf( "Left Paren\n" );

")"																printf( "Right Paren\n" );

"["																printf( "Left Bracket\n" );

"]"																printf( "Right Bracket\n" );

","																printf( "Comma\n" );

":"																printf( "Colon\n" );

":="															printf( "Assignement\n" );


{W}															/*Nothing*/

.															{ number_of_errors++; error_handler( yytext , number_of_lines ); }

%%


void error_handler(char *error , int n)
{
        printf( "Error in line %d : %s\n" , n , error );
}


int main()
{
	yylex();
	printf( "Total Lines		     : %d\n" , number_of_lines );
	printf( "Total Number of Errors found : %d\n" , number_of_errors );
	return 0;
}
