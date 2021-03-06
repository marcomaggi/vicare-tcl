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
 ** Tcl_Obj struct: finalisation.
 ** ----------------------------------------------------------------- */

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
 ** Tcl_Obj struct: strings.
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

ikptr_t
ikrt_tcl_obj_string_pointer_from_general_string (ikptr_t s_str, ikptr_t s_str_len, ikpcb_t * pcb)
/* Build  a new  "Tcl_Obj" representing  a string  initialised from  the
   general C string referenced by S_STR.

   This  function  is called  from  a  constructor of  "tcl-obj"  Scheme
   struct; it must  make sure that the "Tcl_Obj" is  not finalised until
   the "tcl-obj" struct is finalised. */
{
  Tcl_Obj *	objPtr = ik_tcl_obj_string_from_general_c_string(s_str, s_str_len);
  if (objPtr) {
    Tcl_IncrRefCount(objPtr);
    return ika_pointer_alloc(pcb, (ikuword_t)objPtr);
  } else {
    return IK_FALSE;
  }
}
ikptr_t
ikrt_tcl_obj_string_to_bytevector_string (ikptr_t s_obj, ikpcb_t * pcb)
/* Return  a   new  Scheme  bytevector  object   containing  the  string
   representation of the "Tcl_Obj" referenced by S_OBJ, which must be an
   instance of "tcl-obj" Scheme struct. */
{
  return ika_tcl_obj_string_to_bytevector(pcb, IK_TCL_OBJ(s_obj));
}


/** --------------------------------------------------------------------
 ** Tcl_Obj struct: booleans.
 ** ----------------------------------------------------------------- */

static Tcl_Obj *
ik_tcl_obj_boolean_from_boolean (ikptr_t s_bool)
{
  return Tcl_NewBooleanObj(IK_BOOLEAN_TO_INT(s_bool));
}
static ikptr_t
ik_tcl_obj_boolean_to_boolean (ikpcb_t * pcb, Tcl_Obj * objPtr)
{
  int	result;
  if (TCL_ERROR == Tcl_GetBooleanFromObj(NULL, objPtr, &result)) {
    return IK_NULL;
  } else {
    /* ik_debug_message("%s: result %d", __func__, result); */
    return IK_BOOLEAN_FROM_INT(result);
  }
}

/* ------------------------------------------------------------------ */

ikptr_t
ikrt_tcl_obj_boolean_pointer_from_boolean (ikptr_t s_bool, ikpcb_t * pcb)
/* Build a new "Tcl_Obj" representing a boolean initialised from S_BOOL.

   This  function  is called  from  a  constructor of  "tcl-obj"  Scheme
   struct; it must  make sure that the "Tcl_Obj" is  not finalised until
   the "tcl-obj" struct is finalised. */
{
  Tcl_Obj *	objPtr = ik_tcl_obj_boolean_from_boolean(s_bool);
  if (objPtr) {
    Tcl_IncrRefCount(objPtr);
    return ika_pointer_alloc(pcb, (ikuword_t)objPtr);
  } else {
    return IK_FALSE;
  }
}
ikptr_t
ikrt_tcl_obj_boolean_to_boolean (ikptr_t s_obj, ikpcb_t * pcb)
/* Return a  Scheme boolean  object as  representation of  the "Tcl_Obj"
   referenced by  S_OBJ, which must  be an instance of  "tcl-obj" Scheme
   struct. */
{
  return ik_tcl_obj_boolean_to_boolean(pcb, IK_TCL_OBJ(s_obj));
}


/** --------------------------------------------------------------------
 ** Tcl_Obj struct: integers.
 ** ----------------------------------------------------------------- */

static Tcl_Obj *
ik_tcl_obj_integer_from_integer (ikptr_t s_obj)
{
  return Tcl_NewIntObj(ik_integer_to_int(s_obj));
}
static ikptr_t
ika_tcl_obj_integer_to_integer (ikpcb_t * pcb, Tcl_Obj * objPtr)
{
  int	result;
  if (TCL_ERROR == Tcl_GetIntFromObj(NULL, objPtr, &result)) {
    return IK_FALSE;
  } else {
    return ika_integer_from_int(pcb, result);
  }
}

/* ------------------------------------------------------------------ */

ikptr_t
ikrt_tcl_obj_int_pointer_from_integer (ikptr_t s_obj, ikpcb_t * pcb)
/* Build  a  new  "Tcl_Obj"  representing an  integer  initialised  from
   S_OBJ.

   This  function  is called  from  a  constructor of  "tcl-obj"  Scheme
   struct; it must  make sure that the "Tcl_Obj" is  not finalised until
   the "tcl-obj" struct is finalised. */
{
  Tcl_Obj *	objPtr = ik_tcl_obj_integer_from_integer(s_obj);
  if (objPtr) {
    Tcl_IncrRefCount(objPtr);
    return ika_pointer_alloc(pcb, (ikuword_t)objPtr);
  } else {
    return IK_FALSE;
  }
}
ikptr_t
ikrt_tcl_obj_int_to_integer (ikptr_t s_obj, ikpcb_t * pcb)
/* Return a new  Scheme integer object containing  the representation of
   the  "Tcl_Obj" referenced  by S_OBJ,  which  must be  an instance  of
   "tcl-obj" Scheme struct. */
{
  return ika_tcl_obj_integer_to_integer(pcb, IK_TCL_OBJ(s_obj));
}


/** --------------------------------------------------------------------
 ** Tcl_Obj struct: long.
 ** ----------------------------------------------------------------- */

static Tcl_Obj *
ik_tcl_obj_long_from_integer (ikptr_t s_obj)
{
  return Tcl_NewLongObj(ik_integer_to_long(s_obj));
}
static ikptr_t
ika_tcl_obj_long_to_integer (ikpcb_t * pcb, Tcl_Obj * objPtr)
{
  long	result;
  if (TCL_ERROR == Tcl_GetLongFromObj(NULL, objPtr, &result)) {
    return IK_FALSE;
  } else {
    return ika_integer_from_long(pcb, result);
  }
}

/* ------------------------------------------------------------------ */

ikptr_t
ikrt_tcl_obj_long_pointer_from_integer (ikptr_t s_obj, ikpcb_t * pcb)
/* Build a new "Tcl_Obj" representing  a "long" integer initialised from
   S_OBJ.

   This  function  is called  from  a  constructor of  "tcl-obj"  Scheme
   struct; it must  make sure that the "Tcl_Obj" is  not finalised until
   the "tcl-obj" struct is finalised. */
{
  Tcl_Obj *	objPtr = ik_tcl_obj_long_from_integer(s_obj);
  if (objPtr) {
    Tcl_IncrRefCount(objPtr);
    return ika_pointer_alloc(pcb, (ikuword_t)objPtr);
  } else {
    return IK_FALSE;
  }
}
ikptr_t
ikrt_tcl_obj_long_to_integer (ikptr_t s_obj, ikpcb_t * pcb)
/* Return   a   new  Scheme   exact   integer   object  containing   the
   representation of the "Tcl_Obj" referenced by S_OBJ, which must be an
   instance of "tcl-obj" Scheme struct representing a "long". */
{
  return ika_tcl_obj_long_to_integer(pcb, IK_TCL_OBJ(s_obj));
}


/** --------------------------------------------------------------------
 ** Tcl_Obj struct: wide int.
 ** ----------------------------------------------------------------- */

static Tcl_Obj *
ik_tcl_obj_wide_from_integer (ikptr_t s_obj)
{
  return Tcl_NewWideIntObj(ik_integer_to_sint64(s_obj));
}
static ikptr_t
ika_tcl_obj_wide_to_integer (ikpcb_t * pcb, Tcl_Obj * objPtr)
{
  Tcl_WideInt	result;
  if (TCL_ERROR == Tcl_GetWideIntFromObj(NULL, objPtr, &result)) {
    return IK_FALSE;
  } else {
    return ika_integer_from_sint64(pcb, (int64_t)result);
  }
}

/* ------------------------------------------------------------------ */

ikptr_t
ikrt_tcl_obj_wide_int_pointer_from_integer (ikptr_t s_obj, ikpcb_t * pcb)
/* Build   a  new   "Tcl_Obj"  representing   a  "Tcl_WideInt"   integer
   initialised from S_OBJ; the  "Tcl_WideInt" represents a singed 64-bit
   value.  For details see the manual page "Tcl_NewWideIntObj()".

   This  function  is called  from  a  constructor of  "tcl-obj"  Scheme
   struct; it must  make sure that the "Tcl_Obj" is  not finalised until
   the "tcl-obj" struct is finalised. */
{
  Tcl_Obj *	objPtr = ik_tcl_obj_wide_from_integer(s_obj);
  if (objPtr) {
    Tcl_IncrRefCount(objPtr);
    return ika_pointer_alloc(pcb, (ikuword_t)objPtr);
  } else {
    return IK_FALSE;
  }
}
ikptr_t
ikrt_tcl_obj_wide_int_to_integer (ikptr_t s_obj, ikpcb_t * pcb)
/* Return   a   new  Scheme   exact   integer   object  containing   the
   representation of the "Tcl_Obj" referenced by S_OBJ, which must be an
   instance of "tcl-obj" Scheme struct representing a "Tcl_WideInt". */
{
  return ika_tcl_obj_wide_to_integer(pcb, IK_TCL_OBJ(s_obj));
}


/** --------------------------------------------------------------------
 ** Tcl_Obj struct: double.
 ** ----------------------------------------------------------------- */

static Tcl_Obj *
ik_tcl_obj_double_from_flonum (ikptr_t s_obj)
{
  return Tcl_NewDoubleObj(IK_FLONUM_DATA(s_obj));
}
static ikptr_t
ika_tcl_obj_double_to_flonum (ikpcb_t * pcb, Tcl_Obj * objPtr)
{
  double	result;
  if (TCL_ERROR == Tcl_GetDoubleFromObj(NULL, objPtr, &result)) {
    return IK_FALSE;
  } else {
    return ika_flonum_from_double(pcb, result);
  }
}

/* ------------------------------------------------------------------ */

ikptr_t
ikrt_tcl_obj_double_pointer_from_flonum (ikptr_t s_obj, ikpcb_t * pcb)
/* Build a new "Tcl_Obj" representing  a "double" number initialised from
   S_OBJ.

   This  function  is called  from  a  constructor of  "tcl-obj"  Scheme
   struct; it must  make sure that the "Tcl_Obj" is  not finalised until
   the "tcl-obj" struct is finalised. */
{
  Tcl_Obj *	objPtr = ik_tcl_obj_double_from_flonum(s_obj);
  if (objPtr) {
    Tcl_IncrRefCount(objPtr);
    return ika_pointer_alloc(pcb, (ikuword_t)objPtr);
  } else {
    return IK_FALSE;
  }
}
ikptr_t
ikrt_tcl_obj_double_to_flonum (ikptr_t s_obj, ikpcb_t * pcb)
/* Return a  new Scheme flonum  object containing the  representation of
   the  "Tcl_Obj" referenced  by S_OBJ,  which  must be  an instance  of
   "tcl-obj" Scheme struct representing a "double". */
{
  return ika_tcl_obj_double_to_flonum(pcb, IK_TCL_OBJ(s_obj));
}


/** --------------------------------------------------------------------
 ** Tcl_Obj struct: byte array.
 ** ----------------------------------------------------------------- */

static Tcl_Obj *
ik_tcl_obj_bytearray_from_bytevector (ikptr_t s_obj)
{
  size_t	bv_len = IK_BYTEVECTOR_LENGTH(s_obj);
  uint8_t *	bv_ptr = IK_BYTEVECTOR_DATA_UINT8P(s_obj);
  return Tcl_NewByteArrayObj(bv_ptr, bv_len);
}
static ikptr_t
ika_tcl_obj_bytearray_to_bytevector (ikpcb_t * pcb, Tcl_Obj * objPtr)
{
  int		bv_len;
  uint8_t *	bv_ptr;
  bv_ptr = Tcl_GetByteArrayFromObj(objPtr, &bv_len);
  return ika_bytevector_from_memory_block(pcb, bv_ptr, (size_t)bv_len);
}

/* ------------------------------------------------------------------ */

ikptr_t
ikrt_tcl_obj_bytearray_pointer_from_bytevector (ikptr_t s_obj, ikpcb_t * pcb)
/* Build  a new  "Tcl_Obj" representing  a byte  array initialised  from
   S_OBJ.

   This  function  is called  from  a  constructor of  "tcl-obj"  Scheme
   struct; it must  make sure that the "Tcl_Obj" is  not finalised until
   the "tcl-obj" struct is finalised. */
{
  Tcl_Obj *	objPtr = ik_tcl_obj_bytearray_from_bytevector(s_obj);
  if (objPtr) {
    Tcl_IncrRefCount(objPtr);
    return ika_pointer_alloc(pcb, (ikuword_t)objPtr);
  } else {
    return IK_FALSE;
  }
}
ikptr_t
ikrt_tcl_obj_bytearray_to_bytevector (ikptr_t s_obj, ikpcb_t * pcb)
/* Return a  new Scheme bytevector object  containing the representation
   of the  "Tcl_Obj" referenced by S_OBJ,  which must be an  instance of
   "tcl-obj" Scheme struct representing a byte array. */
{
  return ika_tcl_obj_bytearray_to_bytevector(pcb, IK_TCL_OBJ(s_obj));
}


/** --------------------------------------------------------------------
 ** Tcl_Obj struct: list.
 ** ----------------------------------------------------------------- */

#undef IK_TCL_MAX_TCL_LIST_LENGTH
#define IK_TCL_MAX_TCL_LIST_LENGTH		1024

static Tcl_Obj *
ik_tcl_obj_list_from_list (ikptr_t s_obj)
/* Convert a Scheme  list of "tcl-obj" structs into a  TCL list.  If the
   conversion is  successful: return  a pointer to  "Tcl_Obj"; otherwise
   return NULL. */
{
  Tcl_Obj *	listObj;
  if (0) ik_debug_message("%s enter", __func__);
  ikuword_t	objc = ik_list_length(s_obj);
  /* Arbitrary limit to list length. */
  if (IK_TCL_MAX_TCL_LIST_LENGTH <= objc) {
    listObj = NULL;
  } else {
    Tcl_Obj *	objv[objc];
    for (ikuword_t i=0; i<objc; ++i) {
      objv[i] = IK_TCL_OBJ(IK_CAR(s_obj));
      s_obj   = IK_CDR(s_obj);
    }
    /* This call  to "Tcl_NewListObj()"  takes care of  incrementing the
       reference counter of the "Tcl_Obj" structures in "objv". */
    listObj = Tcl_NewListObj(objc, objv);
  }
  if (0) ik_debug_message("%s leave", __func__);
  return listObj;
}
static ikptr_t
ika_tcl_obj_list_to_list (ikpcb_t * pcb, Tcl_Obj * objPtr)
/* Convert a TCL  list into a Scheme list of  pointers to "Tcl_Obj".  If
   the conversion  is successful: return  null or a proper  list object;
   otherwise return the Scheme false object.

   Makes use of the PCB fields "root8" and "root9". */
{
  ikptr_t	s_list;
  if (0) ik_debug_message("%s enter", __func__);
  int		objc;
  Tcl_Obj **	objv;
  if (TCL_ERROR == Tcl_ListObjGetElements(NULL, objPtr, &objc, &objv)) {
    s_list = IK_FALSE;
  } else if (!objc) {
    s_list = IK_NULL;
  } else {
    ikptr_t	s_spine;
    s_list = s_spine = ika_pair_alloc(pcb);
    pcb->root9 = &s_list;
    pcb->root8 = &s_spine;
    {
      for (int i=0; i<objc;) {
	/* We allocate a Scheme pointer object referencing the "Tcl_Obj"
	   in  "objv[i]"; this  pointer object  will go  in a  "tcl-obj"
	   Scheme struct.   We have  to increment the  reference counter
	   here. */
	Tcl_IncrRefCount(objv[i]);
	IK_ASS(IK_CAR(s_spine), ika_pointer_alloc(pcb, (ikuword_t)objv[i]));
	ik_signal_dirt_in_page_of_pointer(pcb, (ikptr_t)IK_CAR_PTR(s_spine));
	if (++i < objc) {
	  IK_ASS(IK_CDR(s_spine), ika_pair_alloc(pcb));
	  ik_signal_dirt_in_page_of_pointer(pcb, (ikptr_t)IK_CDR_PTR(s_spine));
	  s_spine = IK_CDR(s_spine);
	} else {
	  IK_CDR(s_spine) = IK_NULL;
	  break;
	}
      }
    }
    pcb->root8 = NULL;
    pcb->root9 = NULL;
  }
  if (0) ik_debug_message("%s leave", __func__);
  return s_list;
}

/* ------------------------------------------------------------------ */

ikptr_t
ikrt_tcl_obj_list_pointer_from_list (ikptr_t s_obj, ikpcb_t * pcb)
/* Build a new "Tcl_Obj" representing a list initialised from S_OBJ.

   This  function  is called  from  a  constructor of  "tcl-obj"  Scheme
   struct; it must  make sure that the "Tcl_Obj" is  not finalised until
   the "tcl-obj" struct is finalised. */
{
  Tcl_Obj *	objPtr = ik_tcl_obj_list_from_list(s_obj);
  if (objPtr) {
    Tcl_IncrRefCount(objPtr);
    return ika_pointer_alloc(pcb, (ikuword_t)objPtr);
  } else {
    return IK_FALSE;
  }
}
ikptr_t
ikrt_tcl_obj_list_to_list (ikptr_t s_obj, ikpcb_t * pcb)
/* Return a new Scheme list  object containing the representation of the
   "Tcl_Obj" referenced by S_OBJ, which must be an instance of "tcl-obj"
   Scheme struct representing a list. */
{
  return ika_tcl_obj_list_to_list(pcb, IK_TCL_OBJ(s_obj));
}


/** --------------------------------------------------------------------
 ** Interp struct.
 ** ----------------------------------------------------------------- */

static int
ik_tcl_interp_finalise (Tcl_Interp * interp)
/* Actually finalise the INTERP.  This  function is registered as interp
   destructor with "Tcl_EventuallyFree()" and  it is called whenever the
   last "Tcl_Release()" is  applied to the INTERP  causing its reference
   counter to reach zero. */
{
  if (0)
    ik_debug_message("%s: finalising interp %p", __func__, (void*)interp);
  if (! Tcl_InterpDeleted(interp)) {
    Tcl_DeleteInterp(interp);
  }
  return TCL_OK;
}
static ikptr_t
ika_tcl_interp_get_error_info (ikpcb_t * pcb, Tcl_Interp * interp)
/* Retrieve  the current  value of  the global  variable "errorInfo"  in
   INTERP; return a bytevector representing  an ASCII string.  It should
   hold the  last error message  caused by  the evaluation of  TCL code.
   For details see the "errorInfo(n)" manual page. */
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
ika_tcl_interp_get_result (ikpcb_t * pcb, Tcl_Interp * interp)
/* Allocate  and return  a  new Scheme  pointer  object referencing  the
   "Tcl_Obj" structure  representing the  result of evaluating  the last
   script in INTERP. */
{
  Tcl_Obj *	resultObj = Tcl_GetObjResult(interp);
  Tcl_IncrRefCount(resultObj);
  return ika_pointer_alloc(pcb, (ikuword_t)resultObj);
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
    /* Register  the destruction  function to  be used  to finalise  the
       interp. */
    Tcl_EventuallyFree(interp, (Tcl_FreeProc*)ik_tcl_interp_finalise);
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
ikrt_tcl_interp_eval (ikptr_t s_interp, ikptr_t s_script, ikptr_t s_script_len, ikptr_t s_args, ikpcb_t * pcb)
{
#if (defined HAVE_TCL_EVALOBJ)
  Tcl_Interp *	interp = IK_TCL_INTERP(s_interp);
  /* The Tcl object representing the script. */
  Tcl_Obj *	scriptObj;
  /* The Scheme result returned to the caller. */
  ikptr_t	s_result;
  /* The return value form Tcl  functions.  It is TCL_ERROR is something
     goes wrong. */
  int		rv;
  scriptObj = ik_tcl_obj_string_from_general_c_string(s_script, s_script_len);
  /* Append script arguments to the script. */
  if (IK_NULL != s_args) {
    ikuword_t	argc = ik_list_length(s_args);
    /* We are  going to  append elements to  the list  representation of
       "scriptObj";  this means  we mutate  it;  this means  we have  to
       duplicated it if it is shared. */
    if (Tcl_IsShared(scriptObj)) {
      scriptObj = Tcl_DuplicateObj(scriptObj);
    }
    for (ikuword_t i=0; i<argc; ++i) {
      rv = Tcl_ListObjAppendElement(interp, scriptObj, IK_TCL_OBJ(IK_CAR(s_args)));
      if (TCL_ERROR == rv) {
	goto tcl_error;
      } else {
	s_args = IK_CDR(s_args);
      }
    }
  }
  /* Evaluate the script. */
  {
    rv = Tcl_EvalObj(interp, scriptObj);
    if (TCL_OK != rv) {
      goto tcl_error;
    } else {
      s_result = ika_tcl_interp_get_result(pcb, interp);
    }
  }
  return s_result;
 tcl_error:
  {
    ikptr_t	s_error_info = ika_tcl_interp_get_error_info(pcb, interp);
    pcb->root0 = &s_error_info;
    {
      s_result = IKA_PAIR_ALLOC(pcb);
      IK_CAR(s_result) = IK_FIX(rv);
      IK_CDR(s_result) = s_error_info;
    }
    pcb->root0 = NULL;
  }
  return s_result;
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
