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

    ;; tcl alpha struct
    tcl-alpha-initialise
    tcl-alpha-finalise
    tcl-alpha?
    tcl-alpha?/alive		$tcl-alpha-alive?
    tcl-alpha-custom-destructor	set-tcl-alpha-custom-destructor!
    tcl-alpha-putprop		tcl-alpha-getprop
    tcl-alpha-remprop		tcl-alpha-property-list
    tcl-alpha-hash

;;; --------------------------------------------------------------------
;;; still to be implemented

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
    #;(vicare arguments general-c-buffers)
    #;(vicare language-extensions syntaxes)
    #;(prefix (vicare platform words) words.))


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


;;;; data structures: alpha

(ffi.define-foreign-pointer-wrapper tcl-alpha
  (ffi.foreign-destructor capi.tcl-alpha-finalise)
  #;(ffi.foreign-destructor #f)
  (ffi.collector-struct-type #f)
  (ffi.collected-struct-type tcl-beta))

(module ()
  (set-rtd-printer! (type-descriptor tcl-alpha)
    (lambda (S port sub-printer)
      (define-inline (%display thing)
	(display thing port))
      (define-inline (%write thing)
	(write thing port))
      (%display "#[tcl-alpha")
      (%display " pointer=")	(%display ($tcl-alpha-pointer  S))
      (%display "]"))))

;;; --------------------------------------------------------------------

(define* (tcl-alpha-initialise)
  (cond ((capi.tcl-alpha-initialise)
	 => (lambda (rv)
	      (make-tcl-alpha/owner rv)))
	(else
	 (error __who__ "unable to create alpha object"))))

(define* (tcl-alpha-finalise {alpha tcl-alpha?})
  ($tcl-alpha-finalise alpha))


;;;; data structures: beta

(ffi.define-foreign-pointer-wrapper tcl-beta
  (ffi.foreign-destructor #f)
  (ffi.collector-struct-type tcl-alpha))


;;;; done

#| end of library |# )

;;; end of file
;; Local Variables:
;; eval: (put 'ffi.define-foreign-pointer-wrapper 'scheme-indent-function 1)
;; End:
