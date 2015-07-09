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
 ** Interp struct.
 ** ----------------------------------------------------------------- */

static int
ik_tcl_interp_finalise (Tcl_Interp * interp)
{
  if (0)
    ik_debug_message("%s: finalising interp %p", __func__, (void*)interp);
  if (! Tcl_InterpDeleted(interp)) {
    Tcl_DeleteInterp(interp);
  }
  return TCL_OK;
}
ikptr_t
ikrt_tcl_interp_initialise (ikpcb_t * pcb)
{
#if ((defined HAVE_TCL_CREATEINTERP) && (defined HAVE_TCL_INIT) && \
     (defined HAVE_TCL_PRESERVE) && (defined HAVE_TCL_SETVAR) && \
     (defined HAVE_TCL_EVAL))
  Tcl_Interp *	interp = Tcl_CreateInterp();
  if (TCL_OK == Tcl_Init(interp)) {
    /* Implement reference counting for the  interp.  The interp is kept
       alive until "Tcl_Release()" is applied to the pointer. */
    Tcl_Preserve(interp);
    /* We want  the interp  to see  the commands  coming from  Vicare as
       non-interactive. */
    Tcl_SetVar(interp, "tcl_interactive", "0", TCL_GLOBAL_ONLY);
    /* Remove the [exit] command from  the Tcl interp, because it causes
       the whole process to terminate. */
    Tcl_Eval(interp, "rename exit \"\"");
    /* If, in future, we want to add  some Tcl command, we have to do it
       here. */
#if 0
    Tcl_CreateObjCommand(interp, "vicare", vicare_command, NULL, NULL);
#endif
    return ika_pointer_alloc(pcb, (ikuword_t)interp);
  } else {
    return IK_FALSE;
  }
#else
  feature_failure(__func__);
#endif
}
ikptr_t
ikrt_tcl_interp_finalise (ikptr_t s_interp, ikpcb_t * pcb)
{
#if ((defined HAVE_TCL_RELEASE) && (defined HAVE_TCL_INTERPDELETED) && (defined HAVE_TCL_DELETEINTERP))
  ikptr_t		s_pointer	= IK_TCL_INTERP_POINTER(s_interp);
  if (ik_is_pointer(s_pointer)) {
    Tcl_Interp *	interp	= IK_POINTER_DATA_VOIDP(s_pointer);
    int			owner	= IK_BOOLEAN_TO_INT(IK_TCL_INTERP_OWNER(s_interp));
    if (interp && owner) {
      /* Register the  destruction function to  be used to  finalise the
	 interp. */
      Tcl_EventuallyFree(interp, (Tcl_FreeProc*)ik_tcl_interp_finalise);
      /* Release the interp. */
      Tcl_Release(interp);
      IK_POINTER_SET_NULL(s_pointer);
    }
  }
  /* Return false so that the  return value of "$tcl-interp-finalise" is
     always false. */
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
