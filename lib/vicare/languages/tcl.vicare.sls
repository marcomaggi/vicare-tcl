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
;;;Copyright (C) 2015 Marco Maggi <marco.maggi-ipsu@poste.it>
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
(library (vicare languages tcl)
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

    ;; tcl obj
    tcl-obj-finalise
    tcl-obj?
    tcl-obj?/alive			$tcl-obj-alive?
    tcl-obj-custom-destructor		set-tcl-obj-custom-destructor!
    tcl-obj-putprop			tcl-obj-getprop
    tcl-obj-remprop			tcl-obj-property-list
    tcl-obj-hash

    tcl-obj-make-string
    tcl-obj->bytevector-string
    tcl-obj->string

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
  (import (vicare (or (0 4 2015 5 (>= 26))
		      (0 4 2015 (>= 6))
		      (0 4 (>= 2016))))
    (vicare languages tcl constants)
    (prefix (vicare languages tcl unsafe-capi) capi.)
    #;(prefix (vicare ffi (or (0 4 2015 5 (>= 27))
			    (0 4 2015 (>= 6))
			    (0 4 (>= 2016))))
	    ffi.)
    (prefix (vicare ffi foreign-pointer-wrapper) ffi.)
    (vicare arguments general-c-buffers)
    (vicare language-extensions c-enumerations))


;;;; arguments validation



;;;; version functions

(define (vicare-tcl-version-interface-current)
  (capi.vicare-tcl-version-interface-current))

(define (vicare-tcl-version-interface-revision)
  (capi.vicare-tcl-version-interface-revision))

(define (vicare-tcl-version-interface-age)
  (capi.vicare-tcl-version-interface-age))

(define (vicare-tcl-version)
  (ascii->string (capi.vicare-tcl-version)))

;;; --------------------------------------------------------------------

(define (tcl-major-version)
  (capi.tcl-major-version))

(define (tcl-minor-version)
  (capi.tcl-minor-version))

(define (tcl-release-serial)
  (capi.tcl-release-serial))

(define (tcl-patch-level)
  (ascii->string (capi.tcl-patch-level)))


;;;; data structures: obj

(ffi.define-foreign-pointer-wrapper tcl-obj
  (ffi.foreign-destructor capi.tcl-obj-finalise)
  (ffi.collector-struct-type #f))

(module ()
  (set-rtd-printer! (type-descriptor tcl-obj)
    (lambda (S port sub-printer)
      (define-syntax-rule (%display thing)
	(display thing port))
      (define-syntax-rule (%write thing)
	(write thing port))
      (%display "#[tcl-obj")
      (%display " pointer=")	(%display ($tcl-obj-pointer  S))
      (when ($tcl-obj-pointer S)
	(let ((bv (capi.tcl-obj-to-bytevector-string S)))
	  (if (bytevector-empty? bv)
	      (%display " string-rep=\"\"")
	    (begin
	      (%display " string-rep=")
	      (%write (utf8->string bv))))))
      (%display "]"))))

(define* (tcl-obj-finalise {obj tcl-obj?})
  ($tcl-obj-finalise obj))

;;; --------------------------------------------------------------------

(case-define* tcl-obj-make-string
  ((str)
   (tcl-obj-make-string str #f))
  ((str str.len)
   (assert-general-c-string-and-length __who__ str str.len)
   (with-general-c-strings
       ((str^	str))
     (cond ((capi.tcl-obj-pointer-from-general-string str^ str.len)
	    => (lambda (rv)
		 (make-tcl-obj/owner rv)))
	   (else
	    (error __who__ "unable to create Tcl string object" str str.len))))))

(define* (tcl-obj->bytevector-string {tclobj tcl-obj?/alive})
  (capi.tcl-obj-to-bytevector-string tclobj))

(define* (tcl-obj->string {tclobj tcl-obj?/alive})
  (utf8->string (capi.tcl-obj-to-bytevector-string tclobj)))


;;;; data structures: interp

(ffi.define-foreign-pointer-wrapper tcl-interp
  (ffi.foreign-destructor capi.tcl-interp-finalise)
  (ffi.collector-struct-type #f))

(module ()
  (set-rtd-printer! (type-descriptor tcl-interp)
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
  (cond ((capi.tcl-interp-initialise)
	 => (lambda (rv)
	      (make-tcl-interp/owner rv)))
	(else
	 (error __who__ "unable to create interp object"))))

(define* (tcl-interp-finalise {interp tcl-interp?})
  ($tcl-interp-finalise interp))

;;; --------------------------------------------------------------------

(case-define* tcl-interp-eval
  ((interp script)
   (tcl-interp-eval interp script #f))
  (({interp tcl-interp?/alive} script script.len)
   (assert-general-c-string-and-length __who__ script script.len)
   (with-general-c-strings
       ((script^	script))
     (let ((rv (capi.tcl-interp-eval interp script^ script.len)))
       (cond ((pointer? rv)
	      ;;Successful  evaluation  of  the  script.   RV is  a  pointer  to  the
	      ;;resulting "Tcl_Obj" structure.
	      (make-tcl-obj/owner rv))
	     ((pair? rv)
	      ;;An error occurred.  The car of RV is a fixnum representing the return
	      ;;value of "Tcl_EvalObj()".  The cdr of RV is a bytevector representing
	      ;;the TCL stack trace of the error.
	      (error __who__ (ascii->string (cdr rv)) interp script))
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
  (capi.tcl-do-one-event (tcl-events->value flags)))


;;;; done

(foreign-call "ikrt_tcl_global_initialisation" (vicare-argv0))

#| end of library |# )

;;; end of file
;; Local Variables:
;; eval: (put 'ffi.define-foreign-pointer-wrapper 'scheme-indent-function 1)
;; End:
