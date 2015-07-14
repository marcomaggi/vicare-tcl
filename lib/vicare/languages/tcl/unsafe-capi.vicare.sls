;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Vicare/Tcl
;;;Contents: unsafe interface to the C language API
;;;Date: Wed Jul  8, 2015
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (C) 2015 Marco Maggi <marco.maggi-ipsu@poste.it>
;;;
;;;This program is free software:  you can redistribute it and/or modify
;;;it under the terms of the  GNU General Public License as published by
;;;the Free Software Foundation, either version 3 of the License, or (at
;;;your option) any later version.
;;;
;;;This program is  distributed in the hope that it  will be useful, but
;;;WITHOUT  ANY   WARRANTY;  without   even  the  implied   warranty  of
;;;MERCHANTABILITY or  FITNESS FOR  A PARTICULAR  PURPOSE.  See  the GNU
;;;General Public License for more details.
;;;
;;;You should  have received a  copy of  the GNU General  Public License
;;;along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;


#!r6rs
(library (vicare languages tcl unsafe-capi)
  (export

    ;; version functions
    vicare-tcl-version-interface-current
    vicare-tcl-version-interface-revision
    vicare-tcl-version-interface-age
    vicare-tcl-version

    tcl-major-version
    tcl-minor-version
    tcl-release-serial
    tcl-patch-level

    ;; tcl interp
    tcl-interp-initialise
    tcl-interp-finalise
    tcl-interp-eval

    ;; tcl obj
    tcl-obj-finalise
    tcl-obj-string-pointer-from-general-string	tcl-obj-string-to-bytevector-string
    tcl-obj-boolean-pointer-from-boolean	tcl-obj-boolean-to-boolean
    tcl-obj-int-pointer-from-integer		tcl-obj-int-to-integer
    tcl-obj-long-pointer-from-integer		tcl-obj-long-to-integer
    tcl-obj-wide-int-pointer-from-integer	tcl-obj-wide-int-to-integer
    tcl-obj-double-pointer-from-flonum		tcl-obj-double-to-flonum
    tcl-obj-bytearray-pointer-from-bytevector	tcl-obj-bytearray-to-bytevector
    tcl-obj-list-pointer-from-list		tcl-obj-list-to-list

    ;; event loop
    tcl-do-one-event)
  (import (vicare))


;;;; version functions

(define-syntax-rule (vicare-tcl-version-interface-current)
  (foreign-call "ikrt_tcl_version_interface_current"))

(define-syntax-rule (vicare-tcl-version-interface-revision)
  (foreign-call "ikrt_tcl_version_interface_revision"))

(define-syntax-rule (vicare-tcl-version-interface-age)
  (foreign-call "ikrt_tcl_version_interface_age"))

(define-syntax-rule (vicare-tcl-version)
  (foreign-call "ikrt_tcl_version"))

;;; --------------------------------------------------------------------

(define-syntax-rule (tcl-major-version)
  (foreign-call "ikrt_tcl_major_version"))

(define-syntax-rule (tcl-minor-version)
  (foreign-call "ikrt_tcl_minor_version"))

(define-syntax-rule (tcl-release-serial)
  (foreign-call "ikrt_tcl_release_serial"))

(define-syntax-rule (tcl-patch-level)
  (foreign-call "ikrt_tcl_patch_level"))


;;;; tcl interp struct

(define-syntax-rule (tcl-interp-initialise)
  (foreign-call "ikrt_tcl_interp_initialise"))

(define-syntax-rule (tcl-interp-finalise interp)
  (foreign-call "ikrt_tcl_interp_finalise" interp))

;;; --------------------------------------------------------------------

(define-syntax-rule (tcl-interp-eval interp script script.len)
  (foreign-call "ikrt_tcl_interp_eval" interp script script.len))


;;;; tcl obj struct

(define-syntax-rule (tcl-obj-finalise obj)
  (foreign-call "ikrt_tcl_obj_finalise" obj))

;;; --------------------------------------------------------------------
;;; string objects

(define-syntax-rule (tcl-obj-string-pointer-from-general-string str str.len)
  (foreign-call "ikrt_tcl_obj_string_pointer_from_general_string" str str.len))

(define-syntax-rule (tcl-obj-string-to-bytevector-string tclobj)
  (foreign-call "ikrt_tcl_obj_string_to_bytevector_string" tclobj))

;;; --------------------------------------------------------------------
;;; boolean objects

(define-syntax-rule (tcl-obj-boolean-pointer-from-boolean bool)
  (foreign-call "ikrt_tcl_obj_boolean_pointer_from_boolean" bool))

(define-syntax-rule (tcl-obj-boolean-to-boolean tclobj)
  (foreign-call "ikrt_tcl_obj_boolean_to_boolean" tclobj))

;;; --------------------------------------------------------------------
;;; int objects

(define-syntax-rule (tcl-obj-int-pointer-from-integer obj)
  (foreign-call "ikrt_tcl_obj_int_pointer_from_integer" obj))

(define-syntax-rule (tcl-obj-int-to-integer tclobj)
  (foreign-call "ikrt_tcl_obj_int_to_integer" tclobj))

;;; --------------------------------------------------------------------
;;; long int objects

(define-syntax-rule (tcl-obj-long-pointer-from-integer obj)
  (foreign-call "ikrt_tcl_obj_long_pointer_from_integer" obj))

(define-syntax-rule (tcl-obj-long-to-integer tclobj)
  (foreign-call "ikrt_tcl_obj_long_to_integer" tclobj))

;;; --------------------------------------------------------------------
;;; wide int objects

(define-syntax-rule (tcl-obj-wide-int-pointer-from-integer obj)
  (foreign-call "ikrt_tcl_obj_wide_int_pointer_from_integer" obj))

(define-syntax-rule (tcl-obj-wide-int-to-integer tclobj)
  (foreign-call "ikrt_tcl_obj_wide_int_to_integer" tclobj))

;;; --------------------------------------------------------------------
;;; double objects

(define-syntax-rule (tcl-obj-double-pointer-from-flonum obj)
  (foreign-call "ikrt_tcl_obj_double_pointer_from_flonum" obj))

(define-syntax-rule (tcl-obj-double-to-flonum tclobj)
  (foreign-call "ikrt_tcl_obj_double_to_flonum" tclobj))

;;; --------------------------------------------------------------------
;;; bytearray objects

(define-syntax-rule (tcl-obj-bytearray-pointer-from-bytevector obj)
  (foreign-call "ikrt_tcl_obj_bytearray_pointer_from_bytevector" obj))

(define-syntax-rule (tcl-obj-bytearray-to-bytevector tclobj)
  (foreign-call "ikrt_tcl_obj_bytearray_to_bytevector" tclobj))

;;; --------------------------------------------------------------------
;;; list objects

(define-syntax-rule (tcl-obj-list-pointer-from-list obj)
  (foreign-call "ikrt_tcl_obj_list_pointer_from_list" obj))

(define-syntax-rule (tcl-obj-list-to-list tclobj)
  (foreign-call "ikrt_tcl_obj_list_to_list" tclobj))


;;;; events loop

(define-syntax-rule (tcl-do-one-event flags)
  (foreign-call "ikrt_tcl_do_one_event" flags))


;;;; done

#| end of library |# )

;;; end of file
