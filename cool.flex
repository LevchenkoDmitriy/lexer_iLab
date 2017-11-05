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

%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
/*
 *From file cool-parser.h
 */

CLASS		?i:class
ELSE		?i:if
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
ESAC		?i:case
OF		?i:of
NEW		?i:new
ISVOID		?i:isvoid

/*
 *Bool expressions
 */


TRUE		(?-i:t)(?i:rue)
FALSE		(?-i:f)(?i:alse)
BOOL		{TRUE}|{FALSE}

DIGIT		[0-9]
CHAR		[A-Za-z]	
NOT		?i:not
%%

 /*
  *  Nested comments
  */


 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }




 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

<INITIAL>{CLASS}        {  curr_lineno = yylineno;  return CLASS; }	
<INITIAL>{ELSE}         {  curr_lineno = yylineno;  return ELSE;  }				
<INITIAL>{FI}    		{  curr_lineno = yylineno;  return FI;    }	
<INITIAL>{IF}           {  curr_lineno = yylineno;  return IF;    }				
<INITIAL>{IN}		   	{  curr_lineno = yylineno;  return IN;    }	
<INITIAL>{INHERITS}		{  curr_lineno = yylineno;  return INHERITS;  }		
<INITIAL>{LET}			{  curr_lineno = yylineno;  return LET;   }
<INITIAL>{LOOP}			{  curr_lineno = yylineno;  return LOOP;  }	
<INITIAL>{POOL}      	{  curr_lineno = yylineno;  return POOL;  }	
<INITIAL>{THEN}        	{  curr_lineno = yylineno;  return THEN;  }					
<INITIAL>{WHILE}		{  curr_lineno = yylineno;  return WHILE; }	
<INITIAL>{CASE}			{  curr_lineno = yylineno;  return CASE;  }	
<INITIAL>{ESAC}			{  curr_lineno = yylineno;  return ESAC;  }	
<INITIAL>{NEW}			{  curr_lineno = yylineno;  return NEW;   }
<INITIAL>{ISVOID}		{  curr_lineno = yylineno;  return ISVOID;} 				
<INITIAL>{OF}			{  curr_lineno = yylineno;  return OF;    }	
<INITIAL>{NOT}          {  curr_lineno = yylineno;  return NOT;   }
<INITIAL>{FALSE}	    {  cool_yylval.boolean = false;
                                curr_lineno = yylineno;
				return BOOL_CONST;}
<INITIAL>{TRUE}			{  cool_yylval.boolean = true;
                       		   curr_lineno = yylineno;
				   return BOOL_CONST;}	


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%
