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

(define* (tcl-interp-eval {interp tcl-interp?/alive} {script general-c-string?})
  (with-general-c-strings
      ((script^	script))
    (let ((rv (capi.tcl-interp-eval interp script^)))
      (if (pair? rv)
	  (error __who__ (ascii->string (cdr rv)) interp script)
	rv))))


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
  (capi.tcl-do-one-event (tcl-events->value)))


;;;; done

#| end of library |# )

;;; end of file
;; Local Variables:
;; eval: (put 'ffi.define-foreign-pointer-wrapper 'scheme-indent-function 1)
;; End:
