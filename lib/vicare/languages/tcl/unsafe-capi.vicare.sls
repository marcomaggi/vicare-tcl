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

    ;; tcl alpha
    tcl-alpha-initialise
    tcl-alpha-finalise

;;; --------------------------------------------------------------------
;;; still to be implemented

    )
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


;;;; tcl alpha struct

(define-syntax-rule (tcl-alpha-initialise)
  (foreign-call "ikrt_tcl_alpha_initialise"))

(define-syntax-rule (tcl-alpha-finalise alpha)
  (foreign-call "ikrt_tcl_alpha_finalise" alpha))


;;;; still to be implemented

#;(define-syntax-rule (vicare-tcl)
  (foreign-call "ikrt_tcl"))


;;;; done

#| end of library |# )

;;; end of file
