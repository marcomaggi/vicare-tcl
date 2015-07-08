;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Vicare/Tcl
;;;Contents: Nausicaa API
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


#!vicare
(library (nausicaa languages tcl)
  (options visit-upon-loading tagged-language)
  (export

    ;; version numbers and strings
    vicare-tcl-version-interface-current
    vicare-tcl-version-interface-revision
    vicare-tcl-version-interface-age
    vicare-tcl-version

    ;; label
    <tcl-alpha>
    )
  (import (nausicaa)
    (vicare languages tcl))


;;;; label wrapper for struct "tcl-alpha"

(define-label <tcl-alpha>
  (predicate tcl-alpha?)
  (protocol (lambda () tcl-alpha-initialise))

;;; common objects stuff

  (virtual-fields
   (mutable {destructor <procedure>}
	    tcl-alpha-custom-destructor
	    set-tcl-alpha-custom-destructor!))

  (methods
   (alive?		tcl-alpha?/alive)
   (finalise		tcl-alpha-finalise)

   (putprop		tcl-alpha-putprop)
   (getprop		tcl-alpha-getprop)
   (remprop		tcl-alpha-remprop)
   (property-list	tcl-alpha-property-list)

   (hash		tcl-alpha-hash))

;;;

  #| end of label |# )


;;;; done

)

;;; end of file
