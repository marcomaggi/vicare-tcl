;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Vicare/Tcl
;;;Contents: Tcl binding backend
;;;Date: Wed Jul  8, 2015
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (C) 2015, 2017 Marco Maggi <marco.maggi-ipsu@poste.it>
;;;
;;;This program is free software:  you can redistribute it and/or modify
;;;it under the terms of the  GNU General Public License as published by
;;;the Free Software Foundation, either version 3 of the License, or (at
;;;your option) any later version.
;;;
;;;This program is  distributed in the hope that it  will be useful, but
;;;WITHOUT  ANY   WARRANTY;  without   even  the  implied   warranty  of
;;;MERCHANTABILITY  or FITNESS FOR  A PARTICULAR  PURPOSE.  See  the GNU
;;;General Public License for more details.
;;;
;;;You should  have received  a copy of  the GNU General  Public License
;;;along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;


#!vicare
(library (vicare languages tcl (0 4 2015 7 15))
  (options typed-language)
  (foreign-library "vicare-tcl")
  (export

    ;; version numbers and strings
    vicare-tcl-version-interface-current
    vicare-tcl-version-interface-revision
    vicare-tcl-version-interface-age
    vicare-tcl-version

    tcl-major-version
    tcl-minor-version
    tcl-release-serial
    tcl-patch-level

    ;; condition object types
    &tcl-conversion
    make-tcl-conversion-error
    tcl-conversion-error?
    tcl-conversion-error.value

    &tcl-evaluation
    make-tcl-evaluation-error
    tcl-evaluation-error?
    tcl-evaluation-error.interp
    tcl-evaluation-error.script
    tcl-evaluation-error.args

    ;; tcl obj
    tcl-obj-finalise
    tcl-obj?
    tcl-obj?/alive			$tcl-obj-alive?
    tcl-obj-custom-destructor		set-tcl-obj-custom-destructor!
    tcl-obj-putprop			tcl-obj-getprop
    tcl-obj-remprop			tcl-obj-property-list
    tcl-obj-hash

    tcl-obj=?

    tcl-obj->utf8
    string->tcl-obj			tcl-obj->string
    boolean->tcl-obj			tcl-obj->boolean
    integer->tcl-obj			tcl-obj->integer
    long->tcl-obj			tcl-obj->long
    wide-int->tcl-obj			tcl-obj->wide-int
    flonum->tcl-obj			tcl-obj->flonum
    bytevector->tcl-obj			tcl-obj->bytevector
    list->tcl-obj			tcl-obj->list

    ;; tcl interp struct
    tcl-interp-initialise
    tcl-interp-finalise
    tcl-interp?
    tcl-interp?/alive			$tcl-interp-alive?
    tcl-interp-custom-destructor	set-tcl-interp-custom-destructor!
    tcl-interp-putprop			tcl-interp-getprop
    tcl-interp-remprop			tcl-interp-property-list
    tcl-interp-hash

    tcl-interp-eval

    ;; event loop
    tcl-events
    tcl-do-one-event
    )
  (import (vicare (0 4 2017 1 (>= 10)))
    (prefix (vicare system structs) structs::)
    (vicare languages tcl constants)
    (prefix (vicare languages tcl unsafe-capi) capi::)
    #;(prefix (vicare ffi (or (0 4 2015 5 (>= 27))
			    (0 4 2015 (>= 6))
			    (0 4 (>= 2016))))
	    ffi::)
    (prefix (vicare ffi foreign-pointer-wrapper) ffi::)
    (vicare arguments general-c-buffers)
    (vicare language-extensions c-enumerations)
    (prefix (vicare platform words) words::)
    (only (vicare language-extensions syntaxes)
	  define-list-of-type-predicate))


;;;; arguments validation



;;;; condition object types

(define-condition-type &tcl-conversion
    &assertion
  make-tcl-conversion-error
  tcl-conversion-error?
  (value	tcl-conversion-error.value))

(define (raise-tcl-conversion-error who message value . irritants)
  (raise
   (condition (make-tcl-conversion-error value)
	      (make-who-condition who)
	      (make-message-condition message)
	      (make-irritants-condition irritants))))

;;; --------------------------------------------------------------------

(define-condition-type &tcl-evaluation
    &error
  make-tcl-evaluation-error
  tcl-evaluation-error?
  (interp	tcl-evaluation-error.interp)
  (script	tcl-evaluation-error.script)
  (args		tcl-evaluation-error.args))

(define (raise-tcl-evaluation-error who message interp script args . irritants)
  (raise
   (condition (make-tcl-evaluation-error interp script args)
	      (make-who-condition who)
	      (make-message-condition message)
	      (make-irritants-condition irritants))))

;;;; version functions

(define (vicare-tcl-version-interface-current)
  (capi::vicare-tcl-version-interface-current))

(define (vicare-tcl-version-interface-revision)
  (capi::vicare-tcl-version-interface-revision))

(define (vicare-tcl-version-interface-age)
  (capi::vicare-tcl-version-interface-age))

(define (vicare-tcl-version)
  (ascii->string (capi::vicare-tcl-version)))

;;; --------------------------------------------------------------------

(define (tcl-major-version)
  (capi::tcl-major-version))

(define (tcl-minor-version)
  (capi::tcl-minor-version))

(define (tcl-release-serial)
  (capi::tcl-release-serial))

(define (tcl-patch-level)
  (ascii->string (capi::tcl-patch-level)))


;;;; data structures: tcl-obj

(ffi::define-foreign-pointer-wrapper tcl-obj
  (ffi::foreign-destructor capi::tcl-obj-finalise)
  (ffi::collector-struct-type #f))

(module ()
  (structs::set-struct-type-printer! (type-descriptor tcl-obj)
    (lambda (S port sub-printer)
      (define-syntax-rule (%display thing)
	(display thing port))
      (define-syntax-rule (%write thing)
	(write thing port))
      (%display "#[tcl-obj")
      (%display " pointer=")	(%display ($tcl-obj-pointer  S))
      (when ($tcl-obj-pointer S)
	(let ((bv (capi::tcl-obj-string-to-bytevector-string S)))
	  (if (bytevector-empty? bv)
	      (%display " string-rep=\"\"")
	    (begin
	      (%display " string-rep=")
	      (%write (utf8->string bv))))))
      (%display "]"))))

(define* (tcl-obj-finalise {obj tcl-obj?})
  ($tcl-obj-finalise obj))

(define-list-of-type-predicate list-of-tcl-objs?/alive tcl-obj?/alive)

;;; --------------------------------------------------------------------

(define* (tcl-obj=? {obj1 tcl-obj?/alive} {obj2 tcl-obj?/alive})
  (string=? (tcl-obj->string obj1)
	    (tcl-obj->string obj2)))

;;; --------------------------------------------------------------------
;;; string objects

(define* (tcl-obj->utf8 {tclobj tcl-obj?/alive})
  (capi::tcl-obj-string-to-bytevector-string tclobj))

(case-define* string->tcl-obj
  ((str)
   (string->tcl-obj str #f))
  ((str str.len)
   (assert-general-c-string-and-length __who__ str str.len)
   (with-general-c-strings
       ((str^	str))
     (cond ((capi::tcl-obj-string-pointer-from-general-string str^ str.len)
	    => (lambda (rv)
		 (make-tcl-obj/owner rv)))
	   (else
	    (raise-tcl-conversion-error __who__
	      "unable to create Tcl string object" str str.len))))))

(define* (tcl-obj->string {tclobj tcl-obj?/alive})
  (utf8->string (capi::tcl-obj-string-to-bytevector-string tclobj)))

;;; --------------------------------------------------------------------
;;; boolean objects

(define* (boolean->tcl-obj bool)
  (cond ((capi::tcl-obj-boolean-pointer-from-boolean bool)
	 => (lambda (rv)
	      (make-tcl-obj/owner rv)))
	(else
	 (raise-tcl-conversion-error __who__
	   "unable to create Tcl boolean object" bool))))

(define* (tcl-obj->boolean {tclobj tcl-obj?/alive})
  (let ((rv (capi::tcl-obj-boolean-to-boolean tclobj)))
    (if (null? rv)
	;;TCLOBJ does not represent a boolean.
	(raise-tcl-conversion-error __who__
	  "unable to create boolean representation of Tcl_Obj" tclobj)
      rv)))

;;; --------------------------------------------------------------------
;;; integer objects

(define* (integer->tcl-obj {obj words::signed-int?})
  (cond ((capi::tcl-obj-int-pointer-from-integer obj)
	 => (lambda (rv)
	      (make-tcl-obj/owner rv)))
	(else
	 (raise-tcl-conversion-error __who__
	   "unable to create Tcl \"signed int\" object" obj))))

(define* (tcl-obj->integer {tclobj tcl-obj?/alive})
  (or (capi::tcl-obj-int-to-integer tclobj)
      ;;TCLOBJ does not represent a integer.
      (raise-tcl-conversion-error __who__
	"unable to create \"signed int\" representation of Tcl_Obj" tclobj)))

;;; --------------------------------------------------------------------
;;; long objects

(define* (long->tcl-obj {obj words::signed-long?})
  (cond ((capi::tcl-obj-long-pointer-from-integer obj)
	 => (lambda (rv)
	      (make-tcl-obj/owner rv)))
	(else
	 (raise-tcl-conversion-error __who__
	   "unable to create Tcl \"singed long\" object" obj))))

(define* (tcl-obj->long {tclobj tcl-obj?/alive})
  (or (capi::tcl-obj-long-to-integer tclobj)
      ;;TCLOBJ does not represent a long.
      (raise-tcl-conversion-error __who__
	"unable to create \"signed long\" representation of Tcl_Obj" tclobj)))

;;; --------------------------------------------------------------------
;;; wide objects

(define* (wide-int->tcl-obj {obj words::word-s64?})
  (cond ((capi::tcl-obj-wide-int-pointer-from-integer obj)
	 => (lambda (rv)
	      (make-tcl-obj/owner rv)))
	(else
	 (raise-tcl-conversion-error __who__
	   "unable to create Tcl \"Tcl_WideInt\" object" obj))))

(define* (tcl-obj->wide-int {tclobj tcl-obj?/alive})
  (or (capi::tcl-obj-wide-int-to-integer tclobj)
      ;;TCLOBJ does not represent a wide int.
      (raise-tcl-conversion-error __who__
	"unable to create \"Tcl_WideInt\" representation of Tcl_Obj" tclobj)))

;;; --------------------------------------------------------------------
;;; double objects

(define* (flonum->tcl-obj {obj flonum?})
  (cond ((capi::tcl-obj-double-pointer-from-flonum obj)
	 => (lambda (rv)
	      (make-tcl-obj/owner rv)))
	(else
	 (raise-tcl-conversion-error __who__
	   "unable to create Tcl \"double\" object" obj))))

(define* (tcl-obj->flonum {tclobj tcl-obj?/alive})
  (or (capi::tcl-obj-double-to-flonum tclobj)
      ;;TCLOBJ does not represent a flonum.
      (raise-tcl-conversion-error __who__
	"unable to create \"double\" representation of Tcl_Obj" tclobj)))

;;; --------------------------------------------------------------------
;;; bytearray objects

(define* (bytevector->tcl-obj {obj bytevector?})
  (cond ((capi::tcl-obj-bytearray-pointer-from-bytevector obj)
	 => (lambda (rv)
	      (make-tcl-obj/owner rv)))
	(else
	 (raise-tcl-conversion-error __who__
	   "unable to create Tcl byte array object" obj))))

(define* (tcl-obj->bytevector {tclobj tcl-obj?/alive})
  (or (capi::tcl-obj-bytearray-to-bytevector tclobj)
      ;;TCLOBJ does not represent a byte array.
      (raise-tcl-conversion-error __who__
	"unable to create byte array representation of Tcl_Obj" tclobj)))

;;; --------------------------------------------------------------------
;;; list objects

(define* (list->tcl-obj {obj list-of-tcl-objs?/alive})
  (cond ((capi::tcl-obj-list-pointer-from-list obj)
	 => (lambda (rv)
	      (make-tcl-obj/owner rv)))
	(else
	 (raise-tcl-conversion-error __who__
	   "unable to create Tcl list object" obj))))

(define* (tcl-obj->list {tclobj tcl-obj?/alive})
  (cond ((capi::tcl-obj-list-to-list tclobj)
	 => (lambda (rv)
	      ;;RV is a list of pointers to "Tcl_Obj".
	      (map (lambda ({_ tcl-obj} item)
		     (make-tcl-obj/owner item))
		rv)))
	(else
	 ;;TCLOBJ does not represent a list.
	 (raise-tcl-conversion-error __who__
	   "unable to create list representation of Tcl_Obj" tclobj))))


;;;; data structures: tcl-interp

(ffi::define-foreign-pointer-wrapper tcl-interp
  (ffi::foreign-destructor capi::tcl-interp-finalise)
  (ffi::collector-struct-type #f))

(module ()
  (structs::set-struct-type-printer! (type-descriptor tcl-interp)
    (lambda (S port sub-printer)
      (define-inline (%display thing)
	(display thing port))
      (define-inline (%write thing)
	(write thing port))
      (%display "#[tcl-interp")
      (%display " pointer=")	(%display ($tcl-interp-pointer  S))
      (%display "]"))))

;;; --------------------------------------------------------------------

(define* (tcl-interp-initialise)
  (cond ((capi::tcl-interp-initialise)
	 => (lambda (rv)
	      (make-tcl-interp/owner rv)))
	(else
	 (error __who__ "unable to create interp object"))))

(define* (tcl-interp-finalise {interp tcl-interp?})
  ($tcl-interp-finalise interp))

;;; --------------------------------------------------------------------

(case-define* tcl-interp-eval
  ((interp script)
   (tcl-interp-eval interp script #f '()))
  ((interp script args)
   (tcl-interp-eval interp script #f args))
  (({interp tcl-interp?/alive} script script.len {args list-of-tcl-objs?/alive})
   (assert-general-c-string-and-length __who__ script script.len)
   (with-general-c-strings
       ((script^	script))
     (let ((rv (capi::tcl-interp-eval interp script^ script.len args)))
       (cond ((pointer? rv)
	      ;;Successful  evaluation  of  the  script.   RV is  a  pointer  to  the
	      ;;resulting "Tcl_Obj" structure.
	      (make-tcl-obj/owner rv))
	     ((pair? rv)
	      ;;An error occurred.  The car of RV is a fixnum representing the return
	      ;;value of "Tcl_EvalObj()".  The cdr of RV is a bytevector representing
	      ;;the TCL stack trace of the error.
	      (raise-tcl-evaluation-error __who__
		(ascii->string (cdr rv))
		interp script args))
	     (else
	      (assertion-violation __who__
		"invalid return value from" rv)))))))


;;;; event loop

(define-c-ior-flags tcl-events
  (TCL_ALL_EVENTS
   TCL_DONT_WAIT
   TCL_FILE_EVENTS
   TCL_IDLE_EVENTS
   TCL_TIMER_EVENTS
   TCL_WINDOW_EVENTS)
  (all
   dont-wait
   file
   idle
   timer
   window))

(define (tcl-do-one-event flags)
  (capi::tcl-do-one-event (tcl-events->value flags)))


;;;; done

(foreign-call "ikrt_tcl_global_initialisation" (vicare-argv0))

#| end of library |# )

;;; end of file
;; Local Variables:
;; eval: (put 'ffi::define-foreign-pointer-wrapper	'scheme-indent-function 1)
;; eval: (put 'raise-tcl-conversion-error		'scheme-indent-function 1)
;; eval: (put 'raise-tcl-evaluation-error		'scheme-indent-function 1)
;; End:
