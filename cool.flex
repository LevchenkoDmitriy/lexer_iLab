/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
int cmnt = 0;
%}

%x COMMENT COMMENT_DASH STRERROR STRING

/*
 * Define names for regular expressions here.
 */

DARROW          =>
/*
 *From file cool-parser.h
 */

CLASS		?i:class
ELSE		?i:else
FI		?i:fi
IF		?i:if
IN		?i:in
INHERITS	?i:inherits
LET		?i:let
LOOP		?i:loop
POOL		?i:pool
THEN		?i:then
WHILE		?i:while
CASE		?i:case
ESAC		?i:esac
OF		?i:of
NEW		?i:new
ISVOID		?i:isvoid

 /*
  * Bool expressions
  */


TRUE		t[Rr][Uu][Ee]
FALSE		f[Aa][Ll][Ss][Ee]

TYPEID		[A-Z][a-zA-Z0-9_]*
OBJECTID	[a-z][a-zA-Z0-9_]*

DIGIT		[0-9]
CHAR		[A-Za-z]	
NOT		?i:not

SELFID         "self"
SELF_TYPEID    "SELF_TYPE"

WHITESPACE     [ \n\f\r\t\v]
%%

 /*
  *  Nested comments
  */



<INITIAL>--             {BEGIN(COMMENT_DASH);}

<COMMENT_DASH><<EOF>>   {
                          yyterminate();
                        }
<COMMENT_DASH>[\n]      {
			  ++curr_lineno;
                          BEGIN(INITIAL);
                        }
<COMMENT_DASH>[^\n]     {}


<INITIAL>"(*"           { BEGIN(COMMENT);
                          cmnt++;
                        }

<INITIAL>"*)"           {
                          cool_yylval.error_msg = "Unmatched *)";
                          return ERROR;
                        }

<COMMENT>"("+"*"        {  cmnt++;
                        }

<COMMENT>"*"+")"        {  cmnt--;
                           if (cmnt==0)
                           {
                              BEGIN(INITIAL);
                           }
                        }

<COMMENT>[\n]      	{ ++curr_lineno;}
<COMMENT>[\\\n]		{ ++curr_lineno;}

<COMMENT>[^*(]|"("[^*]|"*"[^)] {}

<COMMENT><<EOF>>        {
                            cool_yylval.error_msg = "EOF in comment";
                            BEGIN(INITIAL);
                            return ERROR;
                        }



 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

{CLASS}			{ return CLASS; }	
{ELSE}         	 	{ return ELSE; }				
{FI}    		{ return FI; }	
{IF}          		{ return IF; }				
{IN}		   	{ return IN; }	
{INHERITS}		{ return INHERITS; }		
{LET}			{ return LET; }
{LOOP}			{ return LOOP; }	
{POOL}      		{ return POOL; }	
{THEN}        	   	{ return THEN; }					
{WHILE}		  	{ return WHILE; }	
{CASE}			{ return CASE; }	
{ESAC}			{ return ESAC; }	
{NEW}			{ return NEW; }
{ISVOID}		{ return ISVOID; } 				
{OF}			{ return OF; }	
{NOT}          		{ return NOT; }

{TRUE}			{ yylval.boolean = true; return BOOL_CONST; }
{FALSE}			{ yylval.boolean = false; return BOOL_CONST; }

{DIGIT}+              	{ cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }

					


 /*
  *  Operators
  */

"("         return '(';
")"         return ')';
"."         return '.';
"@"         return '@';
"~"         return '~';
"*"         return '*';
"/"         return '/';
"+"         return '+';
"-"         return '-';
"<="        return LE;
"<"         return '<';
"="         return '=';
"<-"        return ASSIGN;
"{"         return '{';
"}"         return '}';
":"         return ':';
","         return ',';
";"         return ';';


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


<INITIAL>\"     {
                    strcpy(string_buf, "");
                    BEGIN(STRING);
                }
<STRING>\"      {   
                    BEGIN(INITIAL);
		    cool_yylval.symbol = stringtable.add_string(string_buf);
		    return STR_CONST;
                }

<STRING>\\b     { 
                    if(strlen(string_buf)+2 > MAX_STR_CONST)
                    {
                        cool_yylval.error_msg = "String constant too long";
                        BEGIN(STRERROR);
                        return ERROR;
                    }                                 
                    strcat(string_buf, "\b");
                }
<STRING>\\t     { 
                    if(strlen(string_buf)+2 > MAX_STR_CONST)
                    {
                        cool_yylval.error_msg = "String constant too long";
                        BEGIN(STRERROR);
                        return ERROR;
                    }                                 
                    strcat(string_buf, "\t");
                }                
<STRING>\\n     {   ++curr_lineno; 
                    if(strlen(string_buf)+2 > MAX_STR_CONST)
                    {
                        cool_yylval.error_msg = "String constant too long";
                        BEGIN(STRERROR);
                        return ERROR;
                    }          
                      
                    strcat(string_buf, "\n");
                }
<STRING>\\f     { 
                    if(strlen(string_buf)+2 > MAX_STR_CONST)
                    {
                        cool_yylval.error_msg = "String constant too long";
                        BEGIN(STRERROR);
                        return ERROR;
                    }                                 
                    strcat(string_buf, "\f");
                }
<STRING>\\\x00  {
                    BEGIN(STRERROR);
                    cool_yylval.error_msg = "String contains \0 symbol";
                    return ERROR;
                }
<STRING>\\.     {
                    if(strlen(string_buf)+2 > MAX_STR_CONST)
                    {
                        cool_yylval.error_msg = "String constant too long";
                        BEGIN(STRERROR);
                        return ERROR;
                    }                                 
                    strcat(string_buf, yytext+1);
                }                              
                
<STRING>\\\n    {   ++curr_lineno; 
                    if(strlen(string_buf)+2 > MAX_STR_CONST)
                    {
                        cool_yylval.error_msg = "String constant too long";
                        BEGIN(STRERROR);
                        return ERROR;
                    }           
                     
                    strcat(string_buf, "\n");
                }                
<STRING>\n      {   ++curr_lineno;
                    BEGIN(INITIAL);
                    cool_yylval.error_msg = "Unterminated string constant"; 
                    return ERROR;
                }

<STRING>\x00	{ 
                    BEGIN(STRERROR);
                    cool_yylval.error_msg = "String contains null character.";
                    return ERROR;
                }    
                    
                 
<STRING>([^"\\\n\x00])+     {
                                if(strlen(string_buf) + strlen(yytext) + 1 > MAX_STR_CONST)
                                {  
                                    cool_yylval.error_msg = "String constant too long";
                                    BEGIN(STRERROR);
                                    return (ERROR);
                                }                                 
                                strcat(string_buf, yytext);
                            }
<STRERROR>[^\\]\n    {++curr_lineno; BEGIN(INITIAL);}
<STRERROR>\"         {BEGIN(INITIAL);}
<STRERROR>.     {}
<STRERROR>\n    {++curr_lineno;}
<STRING><<EOF>> { cool_yylval.error_msg = "EOF in string constant";
                  BEGIN(INITIAL);
                   return ERROR;
                }


<INITIAL>{TYPEID}       {  cool_yylval.symbol = stringtable.add_string(yytext);               
                           return TYPEID; } 	
<INITIAL>{OBJECTID}     {  cool_yylval.symbol = stringtable.add_string(yytext);              
                           return OBJECTID; }
<INITIAL>[\t\v\f\r ]+    ;

<INITIAL>\n		{++curr_lineno;}
<INITIAL>.              { cool_yylval.error_msg = yytext; return ERROR; }

%%