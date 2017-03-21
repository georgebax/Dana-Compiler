%{

#include <stdio.h>
#include <stdlib.h>

int nl;

%}

L [A-Za-z]
D [0-9]
W [ \t\n]
C [^'"\\]
HEX [0-9|A-F|a-f] 	
ESC \\(n|t|r|0|\\|\'|\"|x{HEX}{HEX})
SC .{-}[\n] 

%%


and|as|begin|break|byte|continue|decl|def|elif|else|end|exit|false|if|is|int|loop|not|or|ref|return|skip|true|var	printf("keyword = %s\n" , yytext);

{D}+	 															{/*007->7*/ printf("integer = %s\n" , yytext);}

{L}({L}|{D}|"_")*													printf("identifier = %s\n", yytext);

\n																	nl++;

\'{ESC}\'															printf("yo\n");

"'"({C})"'" 														printf("hola\n");

\"({SC})*\"															printf("shieeet");

{W}																	/*Nothing*/

.																	printf("error\n");

%%

int main() {
	yylex();
	printf( "Total Lines:%d\n" , nl);
	return 0;
}

