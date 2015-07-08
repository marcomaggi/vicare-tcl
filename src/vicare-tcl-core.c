/*
  Part of: Vicare/Tcl
  Contents: Tcl for Vicare
  Date: Wed Jul  8, 2015

  Abstract

	Core functions.

  Copyright (C) 2015 Marco Maggi <marco.maggi-ipsu@poste.it>

  This program is  free software: you can redistribute  it and/or modify
  it under the  terms of the GNU General Public  License as published by
  the Free Software Foundation, either  version 3 of the License, or (at
  your option) any later version.

  This program  is distributed in the  hope that it will  be useful, but
  WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of
  MERCHANTABILITY  or FITNESS  FOR A  PARTICULAR PURPOSE.   See  the GNU
  General Public License for more details.

  You  should have received  a copy  of the  GNU General  Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** --------------------------------------------------------------------
 ** Headers.
 ** ----------------------------------------------------------------- */

#include "vicare-tcl-internals.h"


/** --------------------------------------------------------------------
 ** Alpha struct.
 ** ----------------------------------------------------------------- */

#define HAVE_TCL_ALPHA_INITIALISE		1
#define HAVE_TCL_ALPHA_FINALISE		1

typedef struct tcl_alpha_tag_t {
  int	num;
} tcl_alpha_t;


ikptr_t
ikrt_tcl_alpha_initialise (ikpcb_t * pcb)
{
#ifdef HAVE_TCL_ALPHA_INITIALISE
  tcl_alpha_t *	rv;
  rv = malloc(sizeof(tcl_alpha_t));
  if (NULL != rv) {
    rv->num = 123;
    return ika_pointer_alloc(pcb, (ik_ulong)rv);
  } else
    return IK_FALSE;
#else
  feature_failure(__func__);
#endif
}
ikptr_t
ikrt_tcl_alpha_finalise (ikptr_t s_alpha, ikpcb_t * pcb)
{
#ifdef HAVE_TCL_ALPHA_FINALISE
  ikptr_t		s_pointer	= IK_TCL_ALPHA_POINTER(s_alpha);
  if (ik_is_pointer(s_pointer)) {
    tcl_alpha_t *	alpha	= IK_POINTER_DATA_VOIDP(s_pointer);
    int		owner		= IK_BOOLEAN_TO_INT(IK_TCL_ALPHA_OWNER(s_alpha));
    if (alpha && owner) {
      free(alpha);
      IK_POINTER_SET_NULL(s_pointer);
    }
  }
  /* Return false so that the return value of "$tcl-alpha-finalise"
     is always false. */
  return IK_FALSE;
#else
  feature_failure(__func__);
#endif
}


/** --------------------------------------------------------------------
 ** Still to be implemented.
 ** ----------------------------------------------------------------- */

#if 0
ikptr_t
ikrt_tcl_doit (ikpcb_t * pcb)
{
#ifdef HAVE_TCL_DOIT
  return IK_VOID;
#else
  feature_failure(__func__);
#endif
}
#endif

/* end of file */
