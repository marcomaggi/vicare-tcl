;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Vicare/Tcl
;;;Contents: demo for documentation
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


#!r6rs
(import (vicare)
  (vicare languages tcl)
  (vicare languages tcl constants)
  #;(prefix (vicare ffi) ffi.)
  #;(vicare language-extensions syntaxes))


;;;; helpers

(define-inline (%pretty-print ?thing)
  (pretty-print ?thing (current-error-port)))


;;;; version functions

(let ()

  (%pretty-print (list (vicare-tcl-version-interface-current)
		       (vicare-tcl-version-interface-revision)
		       (vicare-tcl-version-interface-age)
		       (vicare-tcl-version)))

  (%pretty-print (list (tcl-major-version)
		       (tcl-minor-version)
		       (tcl-release-serial)
		       (tcl-patch-level)))

  #t)


;;;; Tk script

;;This makes use of [vwait].
;;
(begin

  (with-compensations
    (letrec ((interp (compensate
			 (tcl-interp-initialise)
		       (with
			(tcl-interp-finalise interp)))))
      (tcl-interp-eval interp "
package require Tk
button .b -text Ok -command cmd
bind .b <Return> cmd
pack .b
proc cmd {} {
   global X
   set X 1
}
set X 0
focus .b
vwait X")))

  (void))

;;This makes use of TCL-DO-ONE-EVENT.
;;
#;(begin

  (with-compensations
    (letrec ((interp (compensate
			 (tcl-interp-initialise)
		       (with
			(tcl-interp-finalise interp)))))
      (tcl-interp-eval interp "
package require Tk
button .b -text Ok -command cmd
bind .b <Return> cmd
pack .b
proc cmd {} {
   global X
   set X 1
}
set X 0
focus .b
")
      (tcl-do-one-event (tcl-events window))))

  (void))


;;;; done


;;; end of file
