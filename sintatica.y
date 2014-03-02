%{
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <list>
#include <vector>

#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string label;
	string traducao;
	string tipo;
	string argumentos;
	int qtdeArgs;
	string tiposArgs;
	int tamanho;
	string tamanho_vet;
	string valor;
	bool esconder_declaracao;
	string lista_valores;
	bool isFunction;
	bool isArray;
	bool definida;
};
typedef struct atributos Atributos;

typedef map<string, Atributos> STRINGMAP;

STRINGMAP labelsMap;

int yylex(void);
void yyerror(string);
string generateLabel();
string geraBloco();
string intToString(int label);
int tipoToIndice(string tipo);
void traducaoOpAritmetica(Atributos* dolar, Atributos* um, Atributos* tres, char operador);
void traducaoOpAritmeticaIncDec(Atributos* dolar, Atributos* um, string operador);
void atribuicao (Atributos* dolar, Atributos* um, Atributos* tres);
void atribuicao2 (Atributos* dolar, Atributos* um, Atributos* tres, Atributos* quatro);
void atribuicaoVetor(Atributos* dolar, Atributos* um, Atributos* dois, Atributos* quatro);
void logica(Atributos* dolar, Atributos* um, Atributos* dois, Atributos* tres, string operador);
void cast(Atributos* dolar, Atributos* um, Atributos* tres, string operador);
void processaToken(Atributos* dolar, Atributos* um, string tipo);
bool pertenceAoAtualEscopo(string label);
void trata_tamanho(Atributos* dolar, Atributos* um, Atributos* dois, Atributos* quatro, string tamanhoVetTkId);
vector<int> dimensaoMatriz(string matriz);
string matrizParaVetorDeclaracao(string matriz);
string matrizParaVetorElementos(string matrizDec, string matrizElem);
int contaChar(char caractere, string texto);
string tkIdVetor (string matriz);
void fechaEscopo();
void abreEscopo();
STRINGMAP* buscarTkId(string label);
void declaracoes();
void verificaFuncaoDeclarada();
bool loopFor = false;
bool loopForWhile = false;

string opAritmetico[6][6];

string declaracoesDeVariaveis;

list<STRINGMAP*> pilhaDeMapas;

vector<string> funcoesChamadas;

list<string> labelsDeAbertura;
list<string> labelsDeFechamento;
list<string> labelsDeIncremento;

list<string> caseLabel;
list<string> caseLabelTemp;
list<string> caseTraducao;

string switchLabel;

%}

%token TK_INT TK_FLOAT TK_BOOLEAN TK_CHAR TK_STRING
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOLEAN TK_TIPO_CHAR TK_TIPO_STRING TK_TIPO_VOID
%token TK_MENOR TK_MAIOR TK_MENOR_IGUAL TK_MAIOR_IGUAL TK_IGUAL TK_DIFERENTE TK_OU TK_E
%token TK_WHILE TK_IF TK_ELSE TK_FOR TK_DO TK_BREAK TK_CONTINUE TK_SWITCH TK_CASE TK_DEFAULT
%token TK_INC TK_DEC TK_COUT
%token TK_FIM TK_ERROR TAMANHO_VET VET_ID TK_DOIS_PONTOS
%token TK_RETURN

%start INICIO

%right '='
%left '+' '-'
%left '*' '/' '%'
%left TK_INC TK_DEC
%left TK_OU
%left TK_E
%left TK_IGUAL TK_DIFERENTE
%left TK_MENOR TK_MAIOR TK_MENOR_IGUAL TK_MAIOR_IGUAL
%left '(' ')'

%%

INICIO				: ESC_GLOBAL S
					{
						verificaFuncaoDeclarada();

						cout << "\n\n/*Compilador NoName*/\n#include<string.h>\n#include<iostream>\n#include<stdio.h>\n\nusing namespace std;\n\n" << endl;

						cout << declaracoesDeVariaveis << endl;

						declaracoes();

						cout << $2.traducao << endl;


					}
					;

S					: DECLARACOES ';' MAIN
					{
						$$.traducao = $1.traducao + "\n" + $3.traducao;
					}
					| DECLARACOES ';' FUNCOES MAIN
					{
						$$.traducao = $1.traducao + "\n" + $3.traducao + "\n\n" + $4.traducao;
					}
					| DECLARACOES ';' PROTOTIPOS_FUNCOES MAIN FUNCOES
					{
						$$.traducao = $1.traducao + "\n" + $3.traducao + "\n" + $4.traducao + "\n\n" + $5.traducao;
					}
					| DECLARACOES ';' PROTOTIPOS_FUNCOES FUNCOES MAIN FUNCOES
					{
						$$.traducao = $1.traducao + "\n" + $3.traducao + "\n" + $4.traducao + "\n\n" + $5.traducao + "\n\n" + $6.traducao;
					}
					| FUNCOES MAIN
					{
						$$.traducao = $1.traducao + "\n" + $2.traducao;
					}
					| MAIN
					{
						$$.traducao = $1.traducao;
					}
					| PROTOTIPOS_FUNCOES MAIN FUNCOES
					{
						//declaracoes();
						$$.traducao = $1.traducao + "\n" + $2.traducao + "\n" + $3.traducao;
					}
					| PROTOTIPOS_FUNCOES FUNCOES MAIN FUNCOES
					{
						$$.traducao = $1.traducao + "\n" + $2.traducao + "\n" + $3.traducao + "\n" + $4.traducao;
					}
					;

MAIN 				: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
					{
						$$.traducao =  "int main(void)\n{\n" + $5.traducao + "\treturn 0;\n}\n\n";
					}
					;

ESC_GLOBAL			: 
					{
						abreEscopo();	
					}
					;
/*DECL_GLOBAL		: 
					{
						declaracoes();	
					}
					;*/

INICIO_ESC			: '{'
					{
						abreEscopo();
						//cout << "\nAbertura: "<< pilhaDeMapas.size() << endl;
						$$.traducao = "";
					}
					;

FIM_ESC				: '}'
					{
						declaracoes();
						fechaEscopo();
						//cout << "\nFechamento: " << pilhaDeMapas.size() << endl;
						$$.traducao = "";
					}
					;

BLOCO				: INICIO_ESC COMANDOS FIM_ESC
					{
						$$.traducao = $2.traducao;
					}
					;

FUNCOES				: FUNCOES FUNCAO
					{
						$$.traducao = $1.traducao + $2.traducao;
					}
					| FUNCAO
					{
						$$.traducao = $1.traducao;
					}

DECLARACOES 		: DECLARACOES ';' DECLARACAO
					{
						$$.traducao = $1.traducao + $3.traducao;
					}
					| DECLARACAO
					{
						$$.traducao = $1.traducao;
					}
					|
					;

ARGUMENTOS 			: DECLARACAO ',' ARGUMENTOS
					{
						$$.tiposArgs = $1.tipo + ',' + $3.tiposArgs;

						$$.traducao = $1.argumentos + ", " + $3.traducao;
					}
					| DECLARACAO
					{
						$$.tiposArgs = $1.tipo;
						$$.traducao = $1.argumentos;
					}
					|
					{
						$$.traducao = "";
					}
					;

COMANDOS			: COMANDO COMANDOS
					{
						$$.traducao = $1.traducao + "\n" + $2.traducao;
					}
					|
					{
						$$.traducao = "";
					}
					;

BREAK				: TK_BREAK
					{
						string label = labelsDeFechamento.back();

						$$.traducao = "\tgoto " + label + ";\n";

					}
					;

CONTINUE			: TK_CONTINUE
					{

						string label;

						if(loopFor)
							label = labelsDeIncremento.front();
						else
							label = labelsDeAbertura.front();

						$$.traducao = "\tgoto " + label + ";\n";

					}
					;	

COUT		 		: TK_COUT '(' E ')'	
					{

						$$.traducao = "\tcout << " + $3.label + " << endl;";

					}
					;				

COMANDO 			: E ';'
					| DECLARACAO ';'
					| ATRIBUICAO ';'
					| IF
					| WHILE
					| FOR
					| DO
					| SWITCH
					| RETURN ';'
					| CHAMADA_FUNCAO ';'
					| BREAK ';'
					| CONTINUE ';'
					| COUT ';'
					;

LISTA_VALORES		: LISTA_VALORES ',' E
					{
						$$.traducao += $3.traducao;
						$$.valor = $1.valor + ", " + $3.label;
					}
					| E
					{
						$$.traducao = $1.traducao;
						$$.valor = $1.label;
					}
					;

ATRIBUICAO			: TK_ID '=' E
					{
						atribuicao(&$$, &$1, &$3);
					}
					| TK_ID '=' CHAMADA_FUNCAO
					{
						atribuicao(&$$, &$1, &$3);
					}
					| TK_ID '=' TK_ID VET_ID
					{
						atribuicao2(&$$, &$1, &$3, &$4);
					}
					| TK_ID TAMANHO_VET '=' E
					{
						atribuicaoVetor(&$$, &$1, &$2, &$4);
					}
					| TK_ID VET_ID '=' E
					{
						atribuicaoVetor(&$$, &$1, &$2, &$4);
					}				
					| TK_ID TAMANHO_VET '=' CHAMADA_FUNCAO
					{
						atribuicaoVetor(&$$, &$1, &$2, &$4);
					}
					| TK_ID TK_INC // E ++
					{
						traducaoOpAritmeticaIncDec(&$$, &$1, "++");
					}
					| TK_ID TK_DEC // E --
					{
						traducaoOpAritmeticaIncDec(&$$, &$1, "--");
					}
					| TK_INC TK_ID // ++ E
					{
						traducaoOpAritmeticaIncDec(&$$, &$2, "++");
					}
					| TK_DEC TK_ID// -- E
					{
						traducaoOpAritmeticaIncDec(&$$, &$2, "--");
					}
					;

TIPO				: TK_TIPO_INT
					{
						$$.label = "int";
						$$.tipo = "int";
					}
					|	TK_TIPO_FLOAT
					{
						$$.label = "float";
						$$.tipo = "float";
					}
					|	TK_TIPO_BOOLEAN
					{
						$$.label = "boolean";
						$$.tipo = "boolean";
					}
					|	TK_TIPO_STRING
					{
						$$.label = "string";
						$$.tipo = "string";
					}
					|	TK_TIPO_CHAR
					{
						$$.label = "char";
						$$.tipo = "char";
					}
					|	TK_TIPO_VOID
					{
						$$.label = "void";
						$$.tipo = "void";
					}
					; 

DECLARACAO			: TIPO TK_ID
					{

						STRINGMAP* mapa = pilhaDeMapas.front();

						if(!pertenceAoAtualEscopo($2.label))
						{
							(*mapa)[$2.label].label = generateLabel();
							(*mapa)[$2.label].tipo = $1.tipo;
						}

						$$.tipo = (*mapa)[$2.label].tipo;

						$2.label = (*mapa)[$2.label].label;

						if ($$.tipo == "string")
						{
							(*mapa)[$2.label].tipo = std::string("char");
							(*mapa)[$2.label].label = $2.label + "[1000]";
							(*mapa)[$2.label].tamanho = 1000;
							$$.traducao = "";
						}

						else 
						{
							$$.traducao = "";
							$$.argumentos = $$.tipo + " " + $2.label;
						}
					
					}
					| TIPO TK_ID TAMANHO_VET
					{

						STRINGMAP* mapa = pilhaDeMapas.front();

						if(!pertenceAoAtualEscopo($2.label))
						{
							(*mapa)[$2.label].label = generateLabel();
							(*mapa)[$2.label].tipo = $1.tipo;
							(*mapa)[$2.label].tamanho_vet = $3.traducao;
							(*mapa)[$2.label].isArray = true;
						}

						$$.tipo = (*mapa)[$2.label].tipo;

						$2.label = (*mapa)[$2.label].label;

						if ($$.tipo == "string")
						{
							(*mapa)[$2.label].tipo = std::string("char");
							(*mapa)[$2.label].label = $2.label + "[1000]";
							(*mapa)[$2.label].tamanho = 1000;
							$$.traducao = "";
						}

						else 
						{
							$$.traducao = "";
							$$.argumentos = $$.tipo + " " + $2.label + $3.traducao;
						}
					
					}
					| DECLARACAO ',' TK_ID
					{
						STRINGMAP* mapa = pilhaDeMapas.front();

						if(!pertenceAoAtualEscopo($3.label))
						{
							(*mapa)[$3.label].label = generateLabel();
							(*mapa)[$3.label].tipo = $1.tipo;
						}

						$$.tipo = (*mapa)[$3.label].tipo;
						$3.label = (*mapa)[$3.label].label;

						if ($$.tipo == "string")
						{
							(*mapa)[$3.label].tipo = std::string("char");
							(*mapa)[$3.label].label = $3.label + "[1000]";
							(*mapa)[$3.label].tamanho = 1000;
							$$.traducao = "";
						}
						else 
						{
							$$.traducao = "";
						}
					}	
					| DECLARACAO ',' TK_ID '=' E
					{
						STRINGMAP* mapa = pilhaDeMapas.front();

						if(!pertenceAoAtualEscopo($3.label))
						{
							(*mapa)[$3.label].label = generateLabel();
							(*mapa)[$3.label].tipo = $1.tipo;
						}

						$$.tipo = (*mapa)[$3.label].tipo;
						$3.label = (*mapa)[$3.label].label;

						if ($$.tipo == $5.tipo)
						{
							if($$.tipo == "string")
							{
								(*mapa)[$3.label].tamanho = $5.tamanho;
								(*mapa)[$3.label].label = $3.label + "["+ intToString($5.tamanho) +"]";
								(*mapa)[$3.label].tipo = std::string("char");
								$$.traducao = $5.traducao + "\t" + "strcpy(" + $3.label + ", " + $5.label + ");\n";
							}
							else
							{
								$$.traducao = $1.traducao + "\n" + $5.traducao + "\t" + $3.label + " = " + $5.label + ";\n";
							}
						}
						else
						{
							if (opAritmetico[tipoToIndice($$.tipo)][tipoToIndice($5.tipo)] == "ilegal") 
							{
								yyerror("ERRO: Atribuição ilegal!");
							}
							else
							{
								//tratar no mapa
								$$.traducao = $1.traducao + "\n" + $5.traducao + "\t" + $3.label + " = (" + $$.tipo + ") " + $5.label + ";\n";
							}
						}
					}
					| TIPO TK_ID '=' E
					{
						STRINGMAP* mapa = pilhaDeMapas.front();

						if(!pertenceAoAtualEscopo($2.label))
						{
							(*mapa)[$2.label].label = generateLabel();
							(*mapa)[$2.label].tipo = $1.tipo;
						}
						
						$$.tipo = (*mapa)[$2.label].tipo;
						$2.label = (*mapa)[$2.label].label;

						if ($$.tipo == $4.tipo)
						{
							if($$.tipo == "string")
							{
								(*mapa)[$2.label].tamanho = $4.tamanho;
								(*mapa)[$2.label].label = $2.label + "["+ intToString($4.tamanho) +"]";
								(*mapa)[$2.label].tipo = std::string("char");
								$$.traducao = $4.traducao + "\tstrcpy(" + $2.label + ", " + $4.label + ");\n";
							}
							else
							{
								$$.traducao = $4.traducao + "\t" + $2.label + " = " + $4.label + ";\n";
							}
						}
						else
						{
							if (opAritmetico[tipoToIndice($$.tipo)][tipoToIndice($4.tipo)] == "ilegal") 
							{
								yyerror("ERRO: Atribuição ilegal!");
							}
							else
							{
								//tratar no mapa
								$$.traducao = $4.traducao + "\t" + $2.label + " = (" + $$.tipo + ") " + $4.label + ";\n";
							}
						}
					}
					| TIPO TK_ID TAMANHO_VET '=' '{' LISTA_VALORES '}'
					{
						STRINGMAP* mapa = pilhaDeMapas.front();

						$3.traducao = matrizParaVetorDeclaracao($3.traducao);

						if(!pertenceAoAtualEscopo($2.label))
						{
							(*mapa)[$2.label].label = generateLabel();
							(*mapa)[$2.label].tipo = $1.tipo;
							(*mapa)[$2.label].tamanho_vet = $3.traducao;
							(*mapa)[$2.label].esconder_declaracao = true;
						}
						
						$$.tipo = (*mapa)[$2.label].tipo;
						$2.label = (*mapa)[$2.label].label;

						if ($$.tipo == $6.tipo)
						{
							if($$.tipo == "string")
							{
								(*mapa)[$2.label].tamanho = $6.tamanho;
								(*mapa)[$2.label].label = $2.label + "["+ intToString($6.tamanho) +"]";
								(*mapa)[$2.label].tipo = std::string("char");
								$$.traducao = $6.traducao + "\tstrcpy(" + $2.label + ", " + $6.label + ");\n";
							}
							else
							{
								int quantidade = contaChar(',', $6.valor);

								int pos = 0;

								for (int i = 0; i < $3.traducao.size(); i++) {
									if ($3.traducao[i] == '[') {
										pos = i+1;
									}
								}
								// pega o tamanho do vetor em string e converte pra int ("[3]" >> "3" >> 3)
								int tamanho_vet = atoi($3.traducao.substr(pos, $3.traducao.size()-2).c_str());

								if (tamanho_vet == 0 || quantidade < tamanho_vet) {
									$$.traducao = $6.traducao + "\n\t" + $$.tipo + " " + $2.label + $3.traducao + " = {" + $6.valor + "};\n";
								}
								else {
									yyerror("ERRO: Elementos em excesso no inicializador de matriz.");
								}
							}
						}
						else
						{
							if (opAritmetico[tipoToIndice($$.tipo)][tipoToIndice($6.tipo)] == "ilegal") 
							{
								yyerror("ERRO: Atribuição ilegal!");
							}
							else
							{
								//tratar no mapa
								$$.traducao = $6.traducao + "\t" + $2.label + " = (" + $$.tipo + ") " + $6.label + ";\n";
							}
						}
					}		
					;

IF 					: TK_IF '(' E ')' BLOCO
					{
						//string blocoIf = geraBloco();
						string blocoEnd = geraBloco();
					    $$.traducao = $3.traducao + "\n\tif (" + $3.label +") goto " + blocoEnd + ";\n\n" + $5.traducao + "\t" + blocoEnd + ":\n";
					}
					| TK_IF '(' E ')' BLOCO TK_ELSE BLOCO
					{
						string blocoIf = geraBloco();
					    string blocoElse = geraBloco();
					    string blocoEnd = geraBloco();
					    $$.traducao = $3.traducao + "\n\tif (" + $3.label +") goto " + blocoElse + ";\n\n" + $5.traducao  + "\tgoto " + blocoEnd  + ";\n\n\t" + blocoElse + ":\n"+$7.traducao + "\t" + blocoEnd + ":\n";
					}
					;

WHILE		: WHILE_C '(' E ')' BLOCO
		    {
			    
			    $$.traducao = $3.traducao + "\n\t" + labelsDeAbertura.front() + ":" + "\n\tif (" + $3.label +") goto " + labelsDeFechamento.front() + ";\n\n" + $5.traducao + "\tgoto " + labelsDeAbertura.front() + ";\n\n\t" + labelsDeFechamento.front() + ":\n";
				labelsDeAbertura.pop_front();
				labelsDeFechamento.pop_front();

				if(loopForWhile)
				{
					loopFor = true;
					loopForWhile = false;
				}
			}
	    	;

WHILE_C 	: TK_WHILE
			{
				if(loopFor)
				{
					loopFor = false;
					loopForWhile = true;
				}

				string blocoIf = geraBloco();
			    labelsDeAbertura.push_front(blocoIf);
			    string blocoElse = geraBloco();
			    labelsDeFechamento.push_front(blocoElse);

			}
			;

DO 			: DO_C BLOCO TK_WHILE '(' E ')' ';'
			{
			    $$.traducao = $5.traducao + "\n\t" + labelsDeAbertura.front() + ":\n" + $2.traducao + "\tif (" + $5.label + ") goto " + labelsDeFechamento.front() + ";\n\tgoto " + labelsDeAbertura.front() + ";\n\n\t" + labelsDeFechamento.front() + ":\n";
				labelsDeAbertura.pop_front();
				labelsDeFechamento.pop_front();

				if(loopForWhile)
				{
					loopFor = true;
					loopForWhile = false;
				}
			}
			;

DO_C 		: TK_DO
			{
				string blocoIf = geraBloco();
			    labelsDeAbertura.push_front(blocoIf);
			    string blocoElse = geraBloco();
			    labelsDeFechamento.push_front(blocoElse);

			    if(loopFor)
				{
					loopFor = false;
					loopForWhile = true;
				}

			}
			;

FOR 		: FOR_C '(' ATRIBUICAO ';' E ';' ATRIBUICAO ')' BLOCO
			{
				
			    $$.traducao = $3.traducao + "\n\t" + labelsDeAbertura.front() + ":\n" +  $5.traducao + "\n\tif (" + $5.label +") goto " + labelsDeFechamento.front() + ";\n\n" + $9.traducao + "\n\t" + labelsDeIncremento.front() + ":\n" + $7.traducao + "\tgoto " + labelsDeAbertura.front() + ";\n\n\t" + labelsDeFechamento.front() + ":\n";
				labelsDeAbertura.pop_front();
				labelsDeIncremento.pop_front();
				labelsDeFechamento.pop_front();
				loopFor = false;
			}
			;

FOR_C		: TK_FOR
			{
				loopFor = true;
				string blocoIf = geraBloco();
			    labelsDeAbertura.push_front(blocoIf);
			    string blocoIncremento = geraBloco();
			    labelsDeIncremento.push_front(blocoIncremento);
			    string blocoElse = geraBloco();
			    labelsDeFechamento.push_front(blocoElse);
			}
			;

SWITCH		: SWITCH_C '(' E ')' '{' CASES '}'
			{

				list<string>::iterator i;
				$$.traducao = "";
	
				for(i = caseLabel.begin(); i != caseLabel.end(); i++)
				{
					$$.traducao += caseTraducao.front() + "\t" + caseLabelTemp.front() + " = (" + $3.label + " ==" + *i + ");\n";
					caseLabelTemp.pop_front();
					caseTraducao.pop_front();
				}


				
				
				$$.traducao += /*$3.traducao + "\n\tif (!" + $3.label +") goto " + labelsDeFechamento.front()*/ + "\n\n" + $6.traducao + "\n\n\t" + labelsDeFechamento.front() + ":\n";
				labelsDeAbertura.pop_front();
				labelsDeFechamento.pop_front();
			}
			;

SWITCH_C	: TK_SWITCH
			{
				string blocoIf = geraBloco();
			    labelsDeAbertura.push_front(blocoIf);
			    string blocoElse = geraBloco();
			    labelsDeFechamento.push_front(blocoElse);
			}
			;

CASES		: CASE CASES
			{
				$$.traducao = $1.traducao + "\n" + $2.traducao;
			}
			| CASE
			{
				$$.traducao = $1.traducao;
			}
			| DEFAULT
			{
				$$.traducao = $1.traducao;
			}
			;

CASE		: CASE_C E TK_DOIS_PONTOS COMANDOS
			{

				$$.traducao = "";
	
				STRINGMAP* mapa = pilhaDeMapas.front();
				
				string label = generateLabel();
	
				(*mapa)[label].label = label;
				(*mapa)[label].tipo = "int";
				caseLabelTemp.push_front(label);
	
				caseLabel.push_front($2.label);

				caseTraducao.push_front($2.traducao);
					
			
				$$.traducao += "\n\tif (!" + caseLabelTemp.front() +") goto " + labelsDeFechamento.front() + ";\n\n" + 		$4.traducao + "\n\n\t" + labelsDeFechamento.front() + ":\n";
				labelsDeAbertura.pop_front();
				labelsDeFechamento.pop_front();
			}
			;

DEFAULT 	: TK_DEFAULT TK_DOIS_PONTOS COMANDOS
			{
				$$.traducao = $3.traducao;
			}
			;

CASE_C		: TK_CASE
			{
				string blocoIf = geraBloco();
			    labelsDeAbertura.push_front(blocoIf);
			    string blocoElse = geraBloco();
			    labelsDeFechamento.push_front(blocoElse);
			}
			;

PROTOTIPOS_FUNCOES	: PROTOTIPOS_FUNCOES PROTOTIPO_FUNCAO
					{
						$$.traducao = $1.traducao + $2.traducao;
					}
					| PROTOTIPO_FUNCAO
					{
						$$.traducao = $1.traducao;
					}
					;

PROTOTIPO_FUNCAO 	: TIPO TK_ID '(' ARGUMENTOS ')' ';'
					{
						STRINGMAP* mapa = pilhaDeMapas.front();

						(*mapa)[$2.label].label = generateLabel();
						(*mapa)[$2.label].tipo = $1.tipo;
						(*mapa)[$2.label].argumentos = $4.traducao;
						(*mapa)[$2.label].tiposArgs = $4.tiposArgs;
						(*mapa)[$2.label].isFunction = true;
						(*mapa)[$2.label].definida = 0;

						$$.label = (*mapa)[$2.label].label;


						int quantidade = contaChar(',', $4.traducao);

						(*mapa)[$2.label].qtdeArgs = quantidade + 1;

						$$.traducao = "\n" + $1.label + " " + $$.label + "(" + $4.traducao + ");\n";
					}
					;

FUNCAO				: TIPO TK_ID '(' ARGUMENTOS ')' BLOCO 
					{

						STRINGMAP* mapa = buscarTkId($2.label);

						if (mapa == NULL) {

							mapa = pilhaDeMapas.front();

							(*mapa)[$2.label].label = generateLabel();
							(*mapa)[$2.label].tipo = $1.tipo;
							(*mapa)[$2.label].argumentos = $4.traducao;
							(*mapa)[$2.label].tiposArgs = $4.tiposArgs;
							(*mapa)[$2.label].isFunction = true;
							(*mapa)[$2.label].definida = 1;
							int quantidade = contaChar(',', $4.traducao);

							(*mapa)[$2.label].qtdeArgs = quantidade + 1;

							$$.label = (*mapa)[$2.label].label;
						}

						else {
							$$.tipo = $1.tipo;
							$$.label = (*mapa)[$2.label].label;
							(*mapa)[$2.label].definida = 1;
							$$.definida = 1;
						}

						(*mapa)[$2.label].definida = 1;

						if ($$.tipo == "void") {
							if ($6.traducao.find("return") != -1) {
								yyerror("ERRO: ‘return’ com valor, em função retornando void");
							}
							else {

							$$.traducao = "\n" + $1.label + " " + $$.label + "(" + $4.traducao + ") {\n" + $6.traducao + "}\n";
							}
						} else {
							$$.traducao = "\n" + $1.label + " " + $$.label + "(" + $4.traducao + ") {\n" + $6.traducao + "}\n";
						}
					}
					;
			
CHAMADA_FUNCAO		: TK_ID '(' CHAMADA_TK_FUNCAO ')'
					{
						int quantidade = contaChar(',', $3.traducao);

						STRINGMAP* mapa = buscarTkId($1.label);

						if(mapa == NULL)
							yyerror("ERRO: Função não declarada.");

						if ((*mapa)[$1.label].definida != 1) {
							funcoesChamadas.push_back($1.label);
						}


						$$.tipo = (*mapa)[$1.label].tipo;
						$$.qtdeArgs = (*mapa)[$1.label].qtdeArgs;
						$$.isFunction = true;

						string tiposArgs = (*mapa)[$1.label].tiposArgs;

						int qtdeArgsDec = (*mapa)[$1.label].qtdeArgs;
						int qtdeArgsChamada = quantidade + 1;

						$$.label = (*mapa)[$1.label].label;

						if (qtdeArgsDec != qtdeArgsChamada) {
							yyerror("ERRO: Quantidade de argumentos não confere.");
						}
						else if (tiposArgs != $3.tiposArgs) {
							yyerror("ERRO: Tipos das variáveis não conferem.");
						}
						else {
							if ($$.tipo == "void") {
								$$.traducao = "\t" + $$.label + "(" + $3.traducao + ");";
							}
							else {
								$$.label = generateLabel();
								STRINGMAP* mapa2 = pilhaDeMapas.front();
								(*mapa2)[$$.label].label = $$.label;
								(*mapa2)[$$.label].tipo = $$.tipo;
								$$.traducao = $$.label + " = " + $1.label + "(" + $3.traducao + ");";
							}
						}
					}
					;
			
CHAMADA_TK_FUNCAO	: TK_ID ',' CHAMADA_TK_FUNCAO
					{
						STRINGMAP* mapa = buscarTkId($1.label);

						if(mapa == NULL)
							yyerror("ERRO: Variável não declarada.");

						$$.label = (*mapa)[$1.label].label;

						$$.tipo = (*mapa)[$1.label].tipo;

						$$.tiposArgs = $$.tipo + ',' + $3.tiposArgs;
						
						$$.traducao = $$.label + ", " + $3.traducao;
					}
					| TK_ID
					{
						STRINGMAP* mapa = buscarTkId($1.label);

						if(mapa == NULL)
							yyerror("ERRO: Variável não declarada.");

						$$.label = (*mapa)[$1.label].label;

						$$.tipo = (*mapa)[$1.label].tipo;

						$$.tiposArgs = $$.tipo;
						
						$$.traducao = $$.label;
					}
					|
					{
						$$.traducao = "";
					}
					;

RETURN 				: TK_RETURN TK_ID
					{
						STRINGMAP* mapa = buscarTkId($2.label);

						if(mapa == NULL)
							yyerror("ERRO: Variável não declarada.");

						$2.label = (*mapa)[$2.label].label;
						//$2.tipo = (*mapa)[$2.label].tipo;

						$$.traducao = "\treturn " + $2.label + ";";
					}
					;

E 					: E '+' E
					{
						traducaoOpAritmetica(&$$, &$1, &$3, '+');
					}
					| E '-' E
					{
						traducaoOpAritmetica(&$$, &$1, &$3, '-');
					}			
					| E '*' E
					{
						traducaoOpAritmetica(&$$, &$1, &$3, '*');
					}			
					| E '/' E
					{
						traducaoOpAritmetica(&$$, &$1, &$3, '/');
					}		
					| E '%' E
					{
						traducaoOpAritmetica(&$$, &$1, &$3, '%');
					}	
					| '(' E ')'
					{
						//tratar no mapa
						$$.label = generateLabel();
						$$.tipo = $2.tipo;
						$$.traducao = $2.traducao + "\t" + $$.tipo + " " + $$.label + " = " + $2.label + ";\n";
					}
					| E TK_MENOR_IGUAL E
					{
						logica(&$$, &$1, &$2, &$3, "<=");
					}
					| E TK_MAIOR_IGUAL E
					{
						logica(&$$, &$1, &$2, &$3, ">=");
					}
					| E TK_OU E
					{
						logica(&$$, &$1, &$2, &$3, "||");
					}
					| E TK_E E
					{
						logica(&$$, &$1, &$2, &$3, "&&");
					}
					| E TK_IGUAL E
					{
						logica(&$$, &$1, &$2, &$3, "==");
					}
					| E TK_DIFERENTE E
					{
						logica(&$$, &$1, &$2, &$3, "!=");
					}
					| E TK_MENOR E
					{
						logica(&$$, &$1, &$2, &$3, "<");
					}
					| E TK_MAIOR E
					{
						logica(&$$, &$1, &$2, &$3, ">");
					}
					| TK_INT
					{
						processaToken(&$$, &$1, "int");
					}
					| TK_FLOAT
					{
						processaToken(&$$, &$1, "float");
					}
					| TK_BOOLEAN
					{
						processaToken(&$$, &$1, "boolean");
					}
					| TK_STRING
					{
						processaToken(&$$, &$1, "string");
					}
					| TK_CHAR
					{
						processaToken(&$$, &$1, "char");
					}
					| TK_ID
					{
						//STRINGMAP* mapa = pilhaDeMapas.front();

						STRINGMAP* mapa = buscarTkId($1.label);

						$$.label = (*mapa)[$1.label].label;
						$$.tipo = (*mapa)[$1.label].tipo;

						$$.tamanho = (*mapa)[$1.label].tamanho;
						
						$$.traducao = "";
					}
					| TK_ID TAMANHO_VET
					{
						//STRINGMAP* mapa = pilhaDeMapas.front();

						STRINGMAP* mapa = buscarTkId($1.label);

						$$.label = $1.label;
						$$.tipo = (*mapa)[$1.label].tipo;
						$$.tamanho = (*mapa)[$1.label].tamanho;
						$$.tamanho_vet = $2.traducao;
						$$.isArray = (*mapa)[$1.label].isArray;
						
						$$.traducao = "";
					}
					
					;
%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{
	opAritmetico[1][1] = "int";
	opAritmetico[1][2] = "float";
	opAritmetico[1][3] = "ilegal";
	opAritmetico[1][4] = "string";
	opAritmetico[1][5] = "ilegal";
	opAritmetico[2][1] = "float";
	opAritmetico[2][2] = "float";
	opAritmetico[2][3] = "ilegal";
	opAritmetico[2][4] = "string";
	opAritmetico[2][5] = "ilegal";
	opAritmetico[3][1] = "ilegal";
	opAritmetico[3][2] = "ilegal";
	opAritmetico[3][3] = "string";
	opAritmetico[3][4] = "string";
	opAritmetico[3][5] = "ilegal";
	opAritmetico[4][1] = "string";
	opAritmetico[4][2] = "string";
	opAritmetico[4][3] = "string";
	opAritmetico[4][4] = "string";
	opAritmetico[4][5] = "ilegal";
	opAritmetico[5][1] = "ilegal";
	opAritmetico[5][2] = "ilegal";
	opAritmetico[5][3] = "ilegal";
	opAritmetico[5][4] = "ilegal";
	opAritmetico[5][5] = "ilegal";

	yyparse();

	return 0;
}

int tipoToIndice(string tipo)
{
	if(tipo == "int") 
		return 1;
	else if(tipo == "float") 
		return 2;
	else if(tipo == "string") 
		return 3;
	else if(tipo == "char") 
		return 4;
	else if(tipo == "boolean") 
		return 5;
}

void traducaoOpAritmeticaIncDec(Atributos* dolar, Atributos* um, string operador)
{
	STRINGMAP* mapa = buscarTkId(um->label);

	if(mapa == NULL)
		yyerror("ERRO: Variável não declarada");

	um->label = (*mapa)[um->label].label;
	um->traducao = "";
	
	dolar->traducao = um->traducao + "\t";

	if(um->tipo == "string" || um->tipo == "char")
	{
		yyerror("ERRO: Atribuição ilegal!");
	}
	else
	{
		if (operador == "++") {
			dolar->traducao += um->label + " = " + um->label + " + 1;\n";
		}
		else if (operador == "--") {
			dolar->traducao += um->label + " = " + um->label + " - 1;\n";
		}
		
	}
}

void traducaoOpAritmetica(Atributos* dolar, Atributos* um, Atributos* tres, char operador)
{
	STRINGMAP* mapa = pilhaDeMapas.front();

	string label = generateLabel();
	string tipo = opAritmetico[tipoToIndice(um->tipo)][tipoToIndice(tres->tipo)];

	(*mapa)[label].label = label;
	(*mapa)[label].traducao = "";
	(*mapa)[label].tipo = tipo;
	dolar->tipo = tipo;
	dolar->label = label;

	dolar->traducao = um->traducao + tres->traducao + "\t";

	if (um->tipo != tres->tipo)
	{
		if (dolar->tipo == "ilegal") 
		{
			yyerror("ERRO: Atribuição ilegal!");
		}
		else if (dolar->tipo == um->tipo)
		{
			dolar->traducao += dolar->label + " = " + um->label + " " + operador +" (" + dolar->tipo + ") " + tres->label + ";\n";
		}
		else if (dolar->tipo == tres->tipo)
		{	
			dolar->traducao += dolar->label + " = (" + dolar->tipo + ") " + um->label + " " + operador + " " + tres->label + ";\n";
		}
	}
	else
	{

		if(dolar->tipo == "string" && operador == '+')
		{
			dolar->tamanho = (*mapa)[um->label].tamanho + (*mapa)[tres->label].tamanho;
			
			dolar->traducao = um->traducao + tres->traducao + "\tstrcpy(" + dolar->label + ", " + um->label + ");\n\t" + "strcat(" + dolar->label + ", " + tres->label +");\n";
			(*mapa)[label].label = dolar->label +"[" + intToString(dolar->tamanho) + "]";
			(*mapa)[label].traducao = "";
			(*mapa)[label].tamanho = dolar->tamanho;
			(*mapa)[label].tipo = std::string("char");
		}
		else
		{
			if (um->tamanho_vet != "" && tres->tamanho_vet != "") {
				dolar->traducao += dolar->label + " = " + um->label + um->tamanho_vet + " " + operador + " " + tres->label + tres->tamanho_vet + ";\n";
			}
			else if (um->tamanho_vet != "" && tres->tamanho_vet == "") {
				dolar->traducao += dolar->label + " = " + um->label + um->tamanho_vet + " " + operador + " " + tres->label + ";\n";
			}
			else if (um->tamanho_vet == "" && tres->tamanho_vet != "") {
				dolar->traducao += dolar->label + " = " + um->label + " " + operador + " " + tres->label + tres->tamanho_vet + ";\n";
			}
			else {
				dolar->traducao += dolar->label + " = " + um->label + " " + operador + " " + tres->label + ";\n";
			}
		}
		
	}
}

void cast(Atributos* dolar, Atributos* um, Atributos* tres, string operador)
{
	
	if (dolar->tipo == "ilegal") 
	{
		yyerror("ERRO: Atribuição ilegal!");
	}
	else if (dolar->tipo == um->tipo)
	{
		dolar->traducao += dolar->label + " = " + um->label + " " + operador +" (" + dolar->tipo + ") " + tres->label + ";\n";
	}
	else if (dolar->tipo == tres->tipo)
	{	
		dolar->traducao += dolar->label + " = (" + dolar->tipo + ") " + um->label + " " + operador + " " + tres->label + ";\n";
	}
	
}

string geraBloco()
{

	static int bloco = 0;

	stringstream label;

	label << "bloco" << bloco++;
	
	return label.str();
}

string intToString(int label)
{
	stringstream out;
	out << label;
	return out.str();
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}

void processaToken(Atributos* dolar, Atributos* um, string tipo)
{
	STRINGMAP* mapa = pilhaDeMapas.front();

	string label = generateLabel();
	dolar->tipo = tipo;
	dolar->label = label;
	dolar->valor = um->traducao;

	if (tipo != "string")
	{
		(*mapa)[label].label = label;
		(*mapa)[label].traducao = um->traducao;
		(*mapa)[label].tipo = tipo;
		dolar->traducao = "\t" + dolar->label + " = " + um->traducao + ";\n";
		//dolar->declaracao = dolar->tipo + " " + dolar->label + ";\n";
	}
	else
	{
		string as = std::string("\'");

		if (um->traducao.find(as) != std::string::npos) {
    		um->traducao = um->traducao.replace(um->traducao.begin(),um->traducao.begin()+1,"\"");
    		um->traducao = um->traducao.replace(um->traducao.end()-1,um->traducao.end(),"\""); 
		}

		dolar->tamanho = um->traducao.length()-1;
	
		dolar->traducao = "\tstrcpy(" + dolar->label + ", " + um->traducao + ");\n";
		(*mapa)[label].label = dolar->label + "[" + intToString(dolar->tamanho) + "]";
		(*mapa)[label].tipo = std::string("char");
		(*mapa)[label].tamanho = dolar->tamanho;
	}
}

void atribuicao (Atributos* dolar, Atributos* um, Atributos* tres)
{

	STRINGMAP* mapa = buscarTkId(um->label);

	STRINGMAP* mapa2 = buscarTkId(tres->label);

	if(mapa == NULL)
		yyerror("ERRO: Variável não declarada.");

	if(mapa2 == NULL)
		yyerror("ERRO: Variável não declarada.");

	dolar->label = (*mapa)[um->label].label;
	dolar->tipo = (*mapa)[um->label].tipo;
	um->label = dolar->label;

	string matrizDec = (*mapa2)[tres->label].tamanho_vet;

	if (dolar->tipo == tres->tipo)
	{
		if(dolar->tipo == "string")
		{
			(*mapa)[um->label].tamanho = tres->tamanho;
			(*mapa)[um->label].label = dolar->label + "["+ intToString(tres->tamanho) +"]";
			(*mapa)[um->label].tipo = std::string("char");

			if (tres->isFunction == true) {
				dolar->traducao = tres->traducao + "\n\tstrcpy(" + dolar->label + ", " + tres->label + ");\n";
			}
			else {
				dolar->traducao = tres->traducao + "\tstrcpy(" + dolar->label + ", " + tres->label + ");\n";
			}
		}
		else
		{
			if(tres->isArray == 0) {
				dolar->traducao = tres->traducao + "\n\t" + um->label + " = " + tres->label + ";\n";
			}
			else {
				string tres_tamanho_vet = matrizParaVetorElementos(matrizDec, tres->tamanho_vet);
				dolar->traducao = tres->traducao + "\n\t" + um->label + " = " + tres->label + tres_tamanho_vet + ";\n";
			}
		}
	}
	else
	{
		if (opAritmetico[tipoToIndice(dolar->tipo)][tipoToIndice(tres->tipo)] == "ilegal") 
		{
			yyerror("ERRO: Atribuição ilegal!");
		}
		else
		{
			dolar->traducao = tres->traducao + "\n\t" + dolar->label + " = (" + dolar->tipo + ") " + tres->label + ";\n";
		}
	}
}

void atribuicao2 (Atributos* dolar, Atributos* um, Atributos* tres, Atributos* quatro)
{
	STRINGMAP* mapa = buscarTkId(um->label);

	STRINGMAP* mapa2 = buscarTkId(tres->label);

	if(mapa == NULL)
		yyerror("ERRO: Variável não declarada.");

	if(mapa2 == NULL)
		yyerror("ERRO: Variável não declarada.");

	dolar->label = (*mapa)[um->label].label;
	dolar->tipo = (*mapa)[um->label].tipo;
	um->label = dolar->label;

	string matrizDec = (*mapa2)[tres->label].tamanho_vet;
	tres->tipo = (*mapa2)[tres->label].tipo;

	if (dolar->tipo == tres->tipo)
	{
		if(dolar->tipo == "string")
		{
			(*mapa)[um->label].tamanho = tres->tamanho;
			(*mapa)[um->label].label = dolar->label + "["+ intToString(tres->tamanho) +"]";
			(*mapa)[um->label].tipo = std::string("char");

			if (tres->isFunction == true) {
				dolar->traducao = tres->traducao + "\n\tstrcpy(" + dolar->label + ", " + tres->label + ");\n";
			}
			else {
				dolar->traducao = tres->traducao + "\tstrcpy(" + dolar->label + ", " + tres->label + ");\n";
			}
		}
		else
		{
			// só funciona para matrizes uni-dimensionais (reconhecer vet[j], por exemplo. reconhecer vet[i][j] não funciona)
			string dimensao_str = tkIdVetor(quatro->traducao);

			STRINGMAP* mapa = buscarTkId(dimensao_str);

			if(mapa == NULL) {
				if(tres->isArray == 0) {
					dolar->traducao = tres->traducao + "\n\t" + um->label + " = " + tres->label + ";\n";
				}
				else {
					string tres_tamanho_vet = matrizParaVetorElementos(matrizDec, tres->tamanho_vet);
					dolar->traducao = tres->traducao + "\n\t" + um->label + " = " + tres->label + tres_tamanho_vet + ";\n";
				}
			}
			else {
				string temp = (*mapa)[dimensao_str].label;
				string quatro_label = (*mapa)[quatro->label].label;
				
				dolar->traducao = "\t" + um->label + " = " + quatro_label + "[" + temp + "]" + ";\n";
			}
		}
	}
	else
	{
		if (opAritmetico[tipoToIndice(dolar->tipo)][tipoToIndice(tres->tipo)] == "ilegal") 
		{
			yyerror("ERRO: Atribuição ilegal!");
		}
		else
		{
			dolar->traducao = tres->traducao + "\n\t" + dolar->label + " = (" + dolar->tipo + ") " + tres->label + ";\n";
		}
	}
}

void atribuicaoVetor (Atributos* dolar, Atributos* um, Atributos* dois, Atributos* quatro) {

	STRINGMAP* mapa = buscarTkId(um->label);

	if(mapa == NULL)
		yyerror("ERRO: Variável não declarada.");

	dolar->label = (*mapa)[um->label].label;
	dolar->tipo = (*mapa)[um->label].tipo;
	string tamanhoVetTkId = (*mapa)[um->label].tamanho_vet;
	um->label = dolar->label;

	if (dolar->tipo == quatro->tipo)
	{
		if(dolar->tipo == "string")
		{
			(*mapa)[um->label].tamanho = quatro->tamanho;
			(*mapa)[um->label].label = um->label + "["+ intToString(um->tamanho) +"]";
			(*mapa)[um->label].tipo = std::string("char");
			dolar->traducao = quatro->traducao + "\t" + "strcpy(" + um->label + ", " + quatro->label + ");\n";
		}
		else
		{
			trata_tamanho(dolar, um, dois, quatro, tamanhoVetTkId);	
		}
	}
	else
	{
		if (opAritmetico[tipoToIndice(dolar->tipo)][tipoToIndice(quatro->tipo)] == "ilegal") 
		{
			yyerror("ERRO: Atribuição ilegal!");
		}
		else
		{
			//tratar no mapa
			dolar->traducao = quatro->traducao + "\t" + um->label + " = (" + dolar->tipo + ") " + quatro->label + ";\n";
		}
	}
}

void logica(Atributos* dolar, Atributos* um, Atributos* dois, Atributos* tres, string operador)
{
	STRINGMAP* mapa = pilhaDeMapas.front();

	string label = generateLabel();
    dolar->label = label;
    dolar->tipo = opAritmetico[tipoToIndice(um->tipo)][tipoToIndice(tres->tipo)];
    string logica = dois->traducao;

    dolar->traducao = um->traducao + tres->traducao + "\t";

    if (um->tipo != tres->tipo)
	{
		cast(dolar, um, tres, logica);
	}
	else
	{
		dolar->traducao += dolar->label + " = !(" + um->label + " " + operador + " " + tres->label + ");\n";
	}
    (*mapa)[label].label = label;
	(*mapa)[label].traducao = "";
	(*mapa)[label].tipo = dolar->tipo;
}

// ---------------------- FUNÇÕES DE VETOR E MATRIZ ------------------------------------

// função que confere se a dimensão da declaração e de seus elementos (conta os colchetes) são iguais e imprime a tradução
void trata_tamanho(Atributos* dolar, Atributos* um, Atributos* dois, Atributos* quatro, string tamanhoVetTkId) {

	int quantidade1 = contaChar('[', tamanhoVetTkId);
	int quantidade2 = contaChar('[', dois->traducao);
	string tamanhoVetDec;

	if (quatro->isArray == 1) {
		STRINGMAP* mapa = buscarTkId(quatro->label);
		tamanhoVetDec = (*mapa)[quatro->label].tamanho_vet;
	}

	if (quantidade1 == quantidade2) {
		if (quantidade1 > 1) {
			dois->traducao = matrizParaVetorElementos(tamanhoVetTkId, dois->traducao);
		}

		// confere se a atribuição é para uma função ou não
		if (quatro->qtdeArgs > 0) {
			dolar->traducao = "\t" + um->label + dois->traducao + " = " + quatro->traducao + "\n";
		}
		else {
			// só funciona para matrizes uni-dimensionais (reconhecer vet[j], por exemplo. reconhecer vet[i][j] não funciona)
			string dimensao_str = tkIdVetor(dois->traducao);

			STRINGMAP* mapa = buscarTkId(dimensao_str);

			if(mapa == NULL) {
				if(quatro->isArray == 0) {
					dolar->traducao = quatro->traducao + "\t" + um->label + dois->traducao + " = " + quatro->label + ";\n";
				}
				else {
					string quatro_tamanho_vet = matrizParaVetorElementos(tamanhoVetDec, quatro->tamanho_vet);
					dolar->traducao = quatro->traducao + "\t" + um->label + dois->traducao + " = " + quatro->label + quatro_tamanho_vet + ";\n";
				}
			}

			else {
				string temp = (*mapa)[dimensao_str].label;
				dolar->traducao = quatro->traducao + "\t" + um->label + "[" + temp + "]" + " = " + quatro->label + quatro->tamanho_vet + ";\n";
			}
		}
	}
	else {
		yyerror("ERRO: Tipos incompatíveis.");
	}	
}

string tkIdVetor (string matriz) {

	std::vector<int> pos;
	string dimensao_str;

	// guarda as posições dos colchetes
	for (int i = 0; i < matriz.size(); i++) {
		if (matriz[i] == '[' || matriz[i] == ']') {
			pos.push_back(i);
		}
	}

	// usa as posições dos colchetes para guardar em string o tamanho da matriz
	dimensao_str = matriz.substr(pos[0]+1,pos[1]-pos[0]-1);

	return dimensao_str;
}

// função que retorna um vetor com a dimensão da matriz (exemplo: "[4][3]" retorna 4 e 3)
vector<int> dimensaoMatriz(string matriz) {

	std::vector<int> pos;
	vector<int> dimensao;
	vector<string> dimensao_str;

	// guarda as posições dos colchetes
	for (int i = 0; i < matriz.size(); i++) {
		if (matriz[i] == '[' || matriz[i] == ']') {
			pos.push_back(i);
		}
	}

	// usa as posições dos colchetes para guardar em string o tamanho da matriz
	for (int i = 0; i < pos.size(); i=i+2) {
		dimensao_str.push_back(matriz.substr(pos[i]+1,pos[i+1]-pos[i]-1));
	}

	// converte o tamanho da matriz para int
	for (int i = 0; i < dimensao_str.size(); i++) {
		dimensao.push_back(atoi(dimensao_str[i].c_str()));
	}

	return dimensao;
}

// função que dado a dimensão de uma matriz, retorna a dimensão de vetor (para declaração da matriz) (exemplo: "[4][3]" retorna "[12]")
string matrizParaVetorDeclaracao(string matriz) {

	vector<int> dimensao = dimensaoMatriz(matriz);
	string novaDimensao;
	int mult = 1;

	for (int i = 0; i < dimensao.size(); i++) {
		mult *= dimensao[i];
	}

	if (mult == 0) {
		novaDimensao = "[]";
	}
	else {
		novaDimensao = "[" + intToString(mult) + "]";
	}

	return novaDimensao;
}

// função que dado a dimensão de uma matriz, retorna a dimensão de vetor (para elementos da matriz)
string matrizParaVetorElementos(string matrizDec, string matrizElem) {

	vector<int> dimensaoDec = dimensaoMatriz(matrizDec);
	vector<int> dimensaoElem = dimensaoMatriz(matrizElem);
	string novaDimensao;
	int soma = 0, mult = 1, valor = 0;

	for (int i = 0; i < dimensaoDec.size(); i++) {
		mult = dimensaoElem[i];

		for(int j = dimensaoDec.size() - 1; j > i; j--) {
			valor = dimensaoDec[i];
			mult = mult * valor;
		}

		soma = soma + mult;
	}

	novaDimensao = "[" + intToString(soma) + "]";

	return novaDimensao;
}

// ---------------------- FIM FUNÇÕES DE VETOR E MATRIZ ------------------------------------

string generateLabel()
{
	static int counter = 0;
	stringstream label;

	label << "temp" << counter++;
	
	return label.str();
	
}

int contaChar(char caractere, string texto) {
	int quantidade = 0;

	for (int i = 0; i < texto.size(); i++) {
		if (texto[i] == caractere) {
			quantidade++;
		}
	}

	return quantidade;
}

void declaracoes()
{
	STRINGMAP mapa = *pilhaDeMapas.front();
	STRINGMAP::iterator i;
	stringstream ss;
	
	for(i = mapa.begin(); i != mapa.end(); i++){	
		if(i->second.tipo != "string") {
			if (i->second.isFunction == false) {
				if (i->second.tamanho_vet == "") {
					ss << i->second.tipo << " " << i->second.label << ";\n";
				}
				else if (i->second.esconder_declaracao != true){
					i->second.tamanho_vet = matrizParaVetorDeclaracao(i->second.tamanho_vet);
					ss << i->second.tipo << " " << i->second.label << i->second.tamanho_vet << ";\n";
				}
			}
		}
	}
	declaracoesDeVariaveis+= ss.str() + "\n";
}

void abreEscopo()
{
	STRINGMAP* mapa = new STRINGMAP();
	pilhaDeMapas.push_front(mapa);
}

void fechaEscopo()
{
	pilhaDeMapas.pop_front();
}

bool pertenceAoAtualEscopo(string label)
{
	STRINGMAP* mapa = pilhaDeMapas.front();

	if(	mapa->find(label) == mapa->end())
		return false;
	else
		return true;	
}

STRINGMAP* buscarTkId(string label)
{
	list<STRINGMAP*>::iterator i;
	
	for(i = pilhaDeMapas.begin(); i != pilhaDeMapas.end(); i++)
	{
		STRINGMAP* mapa = *i;

		if(mapa->find(label) != mapa->end())
		{
			return 	mapa;
		}
	}

	return NULL;
}

void verificaFuncaoDeclarada()
{
	string nome_args;
	
	for(int i = 0; i < funcoesChamadas.size(); i++) {

		nome_args = funcoesChamadas[i];

		STRINGMAP* mapa = buscarTkId(nome_args);
			
		if((*mapa)[nome_args].definida != 1)
		{
			yyerror("ERRO: Função não declarada.");
		}
	}
}
