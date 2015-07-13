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
#include <string.h>


/** --------------------------------------------------------------------
 ** Global initialisation.
 ** ----------------------------------------------------------------- */

ikptr_t
ikrt_tcl_global_initialisation (ikptr_t s_executable, ikpcb_t * pcb)
/* This must be called before calling any Tcl function to perform global
   initialisation operations. */
{
  Tcl_FindExecutable(IK_BYTEVECTOR_DATA_CHARP(s_executable));
  return IK_VOID;
}


/** --------------------------------------------------------------------
 ** Tcl/Scheme objects conversion.
 ** ----------------------------------------------------------------- */

static Tcl_Obj *
ik_tcl_obj_string_from_general_c_string (ikptr_t s_buf, ikptr_t s_buf_len)
{
  size_t	len = ik_generalised_c_buffer_len(s_buf, s_buf_len);
  const char *	str = IK_GENERALISED_C_STRING(s_buf);
  if (0)
    ik_debug_message("%s: creating new string: %d, \"%s\"", __func__, len, str);
  return Tcl_NewStringObj(str, len);
}
static ikptr_t
ika_tcl_obj_string_to_bytevector (ikpcb_t * pcb, Tcl_Obj * objPtr)
{
  int		len;
  const char *	str = Tcl_GetStringFromObj(objPtr, &len);
  return ika_bytevector_from_cstring_len(pcb, str, len);
}

/* ------------------------------------------------------------------ */

#if 0
static Tcl_Obj *
scm_bytevector_to_tcl_string (ikptr_t s_bv)
{
  ikuword_t	len	= IK_BYTEVECTOR_LENGTH(s_bv);
  const char *	str	= IK_BYTEVECTOR_DATA_CHARP(s_bv);
  return Tcl_NewStringObj(str, (int)len);
}
static ikptr_t
scm_bytevector_from_tcl_string (ikpcb_t * pcb, Tcl_Obj * stringObj)
{
  int		len;
  const char *	str;
  str = Tcl_GetStringFromObj(stringObj, &len);
  return ika_bytevector_from_cstring_len(pcb, str, len);
}
#endif


/** --------------------------------------------------------------------
 ** Obj struct.
 ** ----------------------------------------------------------------- */

ikptr_t
ikrt_tcl_obj_pointer_from_general_string (ikptr_t s_str, ikptr_t s_str_len, ikpcb_t * pcb)
/* Build  a new  "Tcl_Obj" representing  a string  initialised from  the
   general C string referenced by S_STR.

   This  function  is called  from  a  constructor of  "tcl-obj"  Scheme
   struct; it must  make sure that the "Tcl_Obj" is  not finalised until
   the "tcl-obj" struct is finalised. */
{
  Tcl_Obj *	objPtr = ik_tcl_obj_string_from_general_c_string(s_str, s_str_len);
  Tcl_IncrRefCount(objPtr);
  return ika_pointer_alloc(pcb, (ikuword_t)objPtr);
}
ikptr_t
ikrt_tcl_obj_to_bytevector_string (ikptr_t s_obj, ikpcb_t * pcb)
/* Return  a   new  Scheme  bytevector  object   containing  the  string
   representation of the "Tcl_Obj" referenced by S_OBJ, which must be an
   instance of "tcl-obj" Scheme struct. */
{
  return ika_tcl_obj_string_to_bytevector(pcb, IK_TCL_OBJ(s_obj));
}

/* ------------------------------------------------------------------ */

ikptr_t
ikrt_tcl_obj_finalise (ikptr_t s_obj, ikpcb_t * pcb)
/* This  function is  called from  Scheme code  to finalise  a "tcl-obj"
   Scheme struct. */
{
  ikptr_t	s_pointer	= IK_TCL_OBJ_POINTER(s_obj);
  if (ik_is_pointer(s_pointer)) {
    Tcl_Obj *	objPtr	= IK_POINTER_DATA_VOIDP(s_pointer);
    int		owner	= IK_BOOLEAN_TO_INT(IK_TCL_OBJ_OWNER(s_obj));
    if (0)
      ik_debug_message("%s: finalising obj %p, owner %d, type=%p, refCount=%d, bytes=%p",
		       __func__, (void*)objPtr, owner,
		       objPtr->typePtr, objPtr->refCount, (void *)objPtr->bytes);
    if (objPtr && owner) {
      Tcl_DecrRefCount(objPtr);
      IK_POINTER_SET_NULL(s_pointer);
    }
  }
  /* Return false  so that  the return  value of  "$tcl-obj-finalise" is
     always false. */
  return IK_FALSE;
}


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
static ikptr_t
ik_tcl_interp_get_error_info (ikpcb_t * pcb, Tcl_Interp * interp)
{
  Tcl_Obj *	varNameObj;
  Tcl_Obj *	errorInfoObj;
  const char *	error_info_ptr;
  int		error_info_len;
  varNameObj = Tcl_NewStringObj("::errorInfo", -1);
  Tcl_IncrRefCount(varNameObj);
  errorInfoObj = Tcl_ObjGetVar2(interp, varNameObj, NULL, TCL_GLOBAL_ONLY);
  Tcl_DecrRefCount(varNameObj);
  error_info_ptr = Tcl_GetStringFromObj(errorInfoObj, &error_info_len);
  return ika_bytevector_from_cstring_len(pcb, error_info_ptr, error_info_len);
}
static ikptr_t
ik_tcl_interp_get_result (ikpcb_t * pcb, Tcl_Interp * interp)
{
  Tcl_Obj *	resultObj = Tcl_GetObjResult(interp);
  ikptr_t	s_result;
  Tcl_IncrRefCount(resultObj);
  {
    //s_result = ik_tcl_scm_from_tcl_obj(pcb, resultObj);
    s_result = IK_TRUE;
  }
  Tcl_DecrRefCount(resultObj);
  return s_result;
}

/* ------------------------------------------------------------------ */

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
    if (0)
      ik_debug_message("%s: finalising interp %p, owner %d", __func__, (void*)interp, owner);
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

/* ------------------------------------------------------------------ */

ikptr_t
ikrt_tcl_interp_eval (ikptr_t s_interp, ikptr_t s_script, ikptr_t s_script_len, ikpcb_t * pcb)
{
#if (defined HAVE_TCL_EVALOBJ)
  Tcl_Interp *	interp = IK_TCL_INTERP(s_interp);
  Tcl_Obj *	scriptObj;
  scriptObj = ik_tcl_obj_string_from_general_c_string(s_script, s_script_len);
  Tcl_IncrRefCount(scriptObj);
  {
    int		rv = Tcl_EvalObj(interp, scriptObj);
    if (TCL_OK != rv) {
      ikptr_t	s_error_info	= ik_tcl_interp_get_error_info (pcb, interp);
      ikptr_t	s_pair;
      pcb->root0 = &s_error_info;
      {
	s_pair = IKA_PAIR_ALLOC(pcb);
	IK_CAR(s_pair) = IK_FIX(rv);
	IK_CDR(s_pair) = s_error_info;
      }
      pcb->root0 = NULL;
      return s_pair;
    } else {
      return ik_tcl_interp_get_result(pcb, interp);
    }
  }
  Tcl_DecrRefCount(scriptObj);
  return IK_TRUE;
#else
  feature_failure(__func__);
#endif
}


/** --------------------------------------------------------------------
 ** Events loop.
 ** ----------------------------------------------------------------- */

ikptr_t
ikrt_tcl_do_one_event (ikptr_t s_flags, ikpcb_t * pcb)
{
#if (defined HAVE_TCL_DOONEEVENT)
  int		flags = ik_integer_to_int(s_flags);
  return IK_BOOLEAN_FROM_INT(Tcl_DoOneEvent(flags));
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
