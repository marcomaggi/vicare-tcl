;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Vicare/Tcl
;;;Contents: tests for Tcl bindings, Nausicaa API
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
(program (test)
  (options tagged-language)
  (import (nausicaa)
    (nausicaa languages tcl)
    (vicare checks))

(check-set-mode! 'report-failed)
(check-display "*** testing Vicare Tcl bindings: Nausicaa API\n")


;;;; helpers



(parametrise ((check-test-name	'version))

  (check
      (fixnum? (vicare-tcl-version-interface-current))
    => #t)

  (check
      (fixnum? (vicare-tcl-version-interface-revision))
    => #t)

  (check
      (fixnum? (vicare-tcl-version-interface-age))
    => #t)

  (check
      (string? (vicare-tcl-version))
    => #t)

  #t)


(parametrise ((check-test-name		'struct-interp)
	      (struct-guardian-logger	#t))

  (define who 'test)

;;; --------------------------------------------------------------------

  (check	;this will be garbage collected
      (let (({A <tcl-interp>} (<tcl-interp> ())))
	;;;(debug-print A)
	(is-a? A <tcl-interp>))
    => #t)

  (check
      (let (({A <tcl-interp>} (<tcl-interp> ())))
	(A alive?))
    => #t)

  (check	;single finalisation
      (let (({A <tcl-interp>} (<tcl-interp> ())))
  	(A finalise))
    => #f)

  (check	;double finalisation
      (let (({A <tcl-interp>} (<tcl-interp> ())))
  	(A finalise)
  	(A finalise))
    => #f)

  (check	;alive predicate after finalisation
      (let (({A <tcl-interp>} (<tcl-interp> ())))
  	(A finalise)
  	(A alive?))
    => #f)

;;; --------------------------------------------------------------------
;;; destructor

  (check
      (with-result
       (let (({A <tcl-interp>} (<tcl-interp> ())))
	 (set! (A destructor) (lambda (A)
				(add-result 123)))
	 (A finalise)))
    => '(#f (123)))

;;; --------------------------------------------------------------------
;;; hash

  (check-for-true
   (let (({V <tcl-interp>} (<tcl-interp> ())))
     (integer? (V hash))))

  (check
      (let ((A (<tcl-interp> ()))
	    (B (<tcl-interp> ()))
	    (T (make-hashtable (lambda ({V <tcl-interp>})
				 (V hash))
			       eq?)))
	(hashtable-set! T A 1)
	(hashtable-set! T B 2)
	(list (hashtable-ref T A #f)
	      (hashtable-ref T B #f)))
    => '(1 2))

;;; --------------------------------------------------------------------
;;; properties

  (check
      (let (({S <tcl-interp>} (<tcl-interp> ())))
	(S property-list))
    => '())

  (check
      (let (({S <tcl-interp>} (<tcl-interp> ())))
	(S putprop 'ciao 'salut)
	(S getprop 'ciao))
    => 'salut)

  (check
      (let (({S <tcl-interp>} (<tcl-interp> ())))
	(S getprop 'ciao))
    => #f)

  (check
      (let (({S <tcl-interp>} (<tcl-interp> ())))
	(S putprop 'ciao 'salut)
	(S remprop 'ciao)
	(S getprop 'ciao))
    => #f)

  (check
      (let (({S <tcl-interp>} (<tcl-interp> ())))
	(S putprop 'ciao 'salut)
	(S putprop 'hello 'ohayo)
	(list (S getprop 'ciao)
	      (S getprop 'hello)))
    => '(salut ohayo))

  (collect 'fullest))


;;;; done

(check-report)

#| end of program |# )

;;; end of file
