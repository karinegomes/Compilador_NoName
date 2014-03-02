%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]
PONTUACAO [!?.,;:]

DELIM 		{ESPACO}+
NUM 		{DIGITO}+
TAMANHO 	{DIGITO}+

CARACTERE {LETRA}|{NUM}|{PONTUACAO}

REAL 		{NUM}+("."{NUM}+)?
CHAR 		\'({CARACTERE})\'
ID 			{LETRA}({LETRA}|{NUM})*
BOOLEAN 	"TRUE"|"FALSE"
STRING 		\'{DELIM}*{CARACTERE}+({DELIM}*{CARACTERE}+)*{DELIM}*\'|\"{DELIM}*{CARACTERE}+({DELIM}*{CARACTERE}+)*{DELIM}*\"

%%

"\n"			{}

{DELIM} 		{}

"main"			{ return TK_MAIN; }

"while"			{ return TK_WHILE; }

"do"			{ return TK_DO; }

"if"			{ return TK_IF; }

"else"			{ return TK_ELSE; }

"for"			{ return TK_FOR; }

"int"			{ return TK_TIPO_INT; }

"float"			{ return TK_TIPO_FLOAT; }

"boolean"		{ return TK_TIPO_BOOLEAN; }

"string"		{ return TK_TIPO_STRING; }

"char"			{ return TK_TIPO_STRING; }

"void"			{ return TK_TIPO_VOID; }

"return"		{ return TK_RETURN; }

"break"			{ return TK_BREAK; }

"continue"		{ return TK_CONTINUE; }

"cout"			{ return TK_COUT; }

"switch"		{ return TK_SWITCH; }

"case"			{ return TK_CASE; }

"default"		{ return TK_DEFAULT; }

[(){}[\];,]		{ return *yytext; }

[+\-*/=]		{ return *yytext; }

"<"				{ return TK_MENOR; }
">"				{ return TK_MAIOR; }
"<="			{ return TK_MENOR_IGUAL; }
">="			{ return TK_MAIOR_IGUAL; }
"=="			{ return TK_IGUAL; }
"!="			{ return TK_DIFERENTE; }
"||"			{ return TK_OU; }
"&&"			{ return TK_E; }

"++"			{ return TK_INC; }
"--"			{ return TK_DEC; }

":"				{ return TK_DOIS_PONTOS; }

(\[{ID}*\])+	{ yylval.traducao = yytext; return VET_ID; }
(\[{NUM}*\])+	{ yylval.traducao = yytext; return TAMANHO_VET; }
{NUM}			{ yylval.traducao = yytext; return TK_INT; }
{REAL}			{ yylval.traducao = yytext; return TK_FLOAT; }
{BOOLEAN}		{ yylval.traducao = yytext; return TK_BOOLEAN; }
{CHAR}			{ yylval.traducao = yytext; return TK_STRING; }
{STRING}		{ yylval.traducao = yytext; return TK_STRING; }
{ID}			{ yylval.label = yytext; return TK_ID; }

.				{ *yytext; }

%%