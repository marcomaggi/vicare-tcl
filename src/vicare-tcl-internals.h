/*
  Part of: Vicare/Tcl
  Contents: internal header file
  Date: Wed Jul  8, 2015

  Abstract

	Internal header file.

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

#ifndef VICARE_TCL_INTERNALS_H
#define VICARE_TCL_INTERNALS_H 1


/** --------------------------------------------------------------------
 ** Headers.
 ** ----------------------------------------------------------------- */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif
#include <vicare.h>
#include <tcl.h>


/** --------------------------------------------------------------------
 ** Handling of Scheme objects.
 ** ----------------------------------------------------------------- */

/* Accessors for the fields of the Scheme structure "tcl_interp". */
#define IK_TCL_INTERP_POINTER(INTERP)	IK_FIELD((INTERP),0)
#define IK_TCL_INTERP_OWNER(INTERP)	IK_FIELD((INTERP),1)
#define IK_TCL_INTERP(INTERP)	\
  IK_POINTER_DATA_VOIDP(IK_TCL_INTERP_POINTER(INTERP))

/* Accessors for the fields of the Scheme structure "Tcl_Obj". */
#define IK_TCL_OBJ_POINTER(OBJ)		IK_FIELD((OBJ),0)
#define IK_TCL_OBJ_OWNER(OBJ)		IK_FIELD((OBJ),1)
#define IK_TCL_OBJ(OBJ)	\
  IK_POINTER_DATA_VOIDP(IK_TCL_OBJ_POINTER(OBJ))


/** --------------------------------------------------------------------
 ** Support for missing functions.
 ** ----------------------------------------------------------------- */

static IK_UNUSED void
feature_failure_ (const char * funcname)
{
  ik_abort("called unavailable Tcl specific function, %s\n", funcname);
}

#define feature_failure(FN)     { feature_failure_(FN); return IK_VOID; }


/** --------------------------------------------------------------------
 ** Done.
 ** ----------------------------------------------------------------- */

#endif /* VICARE_TCL_INTERNALS_H */

/* end of file */
