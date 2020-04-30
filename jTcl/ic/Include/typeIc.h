/* $Header: /Master/jTcl/jTcl/ic/Include/typeIc.h,v 1.2 1999/03/08 08:34:17 fulup Exp $
 *
 *  Copyright(c) 1996-97 FRIDU a Free Software Company [fridu@fridu.bzh]
 *
 * File      :   typeIc.h common type between lex and yacc
 * Projet    :   Fridu a Realtime Booster
 * SubModule :   Ic rule engine
 * Auteur    :   Fulup Ar Foll [fulup@fridu.bzh]
 *
 * Last
 *      Modification: Written
 *      Author      : $Author: fulup $
 *      Date        : $Date: 1999/03/08 08:34:17 $
 *      Revision    : $Revision: 1.2 $
 *      Source      : $Source: /Master/jTcl/jTcl/ic/Include/typeIc.h,v $
 *      State       : $State: Exp $
 *
 * Modification History
 * ---------------------
 * 01a, 15may97, fulup written from jDoc
 *
 */

// Wlist store a list of string usualy a list of word from one line
typedef struct swList {
 char   *word;
 struct swList *next;;
} Wlist;

// Llist store a list of list usualy a list of lines
typedef struct slList {
 Wlist  *wList;
 struct slList *next;
} Llist;

// mList store a list of word + a list of line
// usualy a keyword followed by an explanation [ex: sub-class extention
typedef struct klList {
 char   *word;
 Wlist  *wList;
 struct klList *next;
} Klist;

// pList store a list of procedure description
typedef struct plList {
 int    type;
 Llist  *code;
 struct plList *next;
} Plist;
