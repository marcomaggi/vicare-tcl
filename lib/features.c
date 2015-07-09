/*
  Part of: Vicare/Tcl
  Contents: print platform features library
  Date: Wed Jul  8, 2015

  Abstract



  Copyright (C) 2015 Marco Maggi <marco.maggi-ipsu@poste.it>

  This program is  free software: you can redistribute  it and/or modify
  it under the  terms of the GNU General Public  License as published by
  the Free Software Foundation, either version  3 of the License, or (at
  your option) any later version.

  This program  is distributed in the  hope that it will  be useful, but
  WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of
  MERCHANTABILITY  or FITNESS  FOR A  PARTICULAR PURPOSE.   See the  GNU
  General Public License for more details.

  You should  have received  a copy  of the  GNU General  Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif
#include <stdio.h>
#include <stdlib.h>


int
main (int argc, const char *const argv[])
{
  printf(";;; -*- coding: utf-8-unix -*-\n\
;;;\n\
;;;Part of: Vicare/Tcl\n\
;;;Contents: static platform inspection\n\
;;;Date: Wed Jul  8, 2015\n\
;;;\n\
;;;Abstract\n\
;;;\n\
;;;\n\
;;;\n\
;;;Copyright (C) 2015 Marco Maggi <marco.maggi-ipsu@poste.it>\n\
;;;\n\
;;;This program is free software:  you can redistribute it and/or modify\n\
;;;it under the terms of the  GNU General Public License as published by\n\
;;;the Free Software Foundation, either version 3 of the License, or (at\n\
;;;your option) any later version.\n\
;;;\n\
;;;This program is  distributed in the hope that it  will be useful, but\n\
;;;WITHOUT  ANY   WARRANTY;  without   even  the  implied   warranty  of\n\
;;;MERCHANTABILITY or  FITNESS FOR  A PARTICULAR  PURPOSE.  See  the GNU\n\
;;;General Public License for more details.\n\
;;;\n\
;;;You should  have received a  copy of  the GNU General  Public License\n\
;;;along with this program.  If not, see <http://www.gnu.org/licenses/>.\n\
;;;\n\
\n\
\n\
#!r6rs\n\
(library (vicare languages tcl features)\n\
  (export\n\
    HAVE_TCL_CREATEINTERP\n\
    HAVE_TCL_DELETEINTERP\n\
    HAVE_TCL_INIT\n\
    HAVE_TCL_INTERPDELETED\n\
    HAVE_TCL_PRESERVE\n\
    HAVE_TCL_RELEASE\n\
    HAVE_TCL_SETVAR\n\
    )\n\
  (import (rnrs))\n\
\n\
;;;; helpers\n\
\n\
(define-syntax define-inline-constant\n\
  (syntax-rules ()\n\
    ((_ ?name ?value)\n\
     (define-syntax ?name (identifier-syntax ?value)))))\n\
\n\
\n\
;;;; code\n\n");


printf("(define-inline-constant HAVE_TCL_CREATEINTERP %s)\n",
#ifdef HAVE_TCL_CREATEINTERP
  "#t"
#else
  "#f"
#endif
  );

printf("(define-inline-constant HAVE_TCL_DELETEINTERP %s)\n",
#ifdef HAVE_TCL_DELETEINTERP
  "#t"
#else
  "#f"
#endif
  );

printf("(define-inline-constant HAVE_TCL_INIT %s)\n",
#ifdef HAVE_TCL_INIT
  "#t"
#else
  "#f"
#endif
  );

printf("(define-inline-constant HAVE_TCL_INTERPDELETED %s)\n",
#ifdef HAVE_TCL_INTERPDELETED
  "#t"
#else
  "#f"
#endif
  );

printf("(define-inline-constant HAVE_TCL_PRESERVE %s)\n",
#ifdef HAVE_TCL_PRESERVE
  "#t"
#else
  "#f"
#endif
  );

printf("(define-inline-constant HAVE_TCL_RELEASE %s)\n",
#ifdef HAVE_TCL_RELEASE
  "#t"
#else
  "#f"
#endif
  );

printf("(define-inline-constant HAVE_TCL_SETVAR %s)\n",
#ifdef HAVE_TCL_SETVAR
  "#t"
#else
  "#f"
#endif
  );


  printf("\n\
;;;; done\n\
\n\
)\n\
\n\
;;; end of file\n");
  exit(EXIT_SUCCESS);
}

/* end of file */
