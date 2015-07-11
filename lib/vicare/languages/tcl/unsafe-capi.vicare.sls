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

(define-syntax-rule (tcl-interp-eval interp script)
  (foreign-call "ikrt_tcl_interp_eval" interp script))


;;;; events loop

(define-syntax-rule (tcl-do-one-event flags)
  (foreign-call "ikrt_tcl_do_one_event" flags))


;;;; done

#| end of library |# )

;;; end of file
