;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Vicare/Tcl
;;;Contents: tests for Tcl bindings
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
;;;  (prefix (vicare ffi) ffi.)
  (vicare checks))

(check-set-mode! 'report-failed)
(check-display "*** testing Vicare Tcl bindings\n")


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


(parametrise ((check-test-name		'struct-alpha)
	      (struct-guardian-logger	#t))

  (define who 'test)

  (check	;this will be garbage collected
      (let ((voice (tcl-alpha-initialise)))
;;;(debug-print voice)
	(tcl-alpha? voice))
    => #t)

  (check
      (tcl-alpha?/alive (tcl-alpha-initialise))
    => #t)

  (check	;single finalisation
      (let ((voice (tcl-alpha-initialise)))
  	(tcl-alpha-finalise voice))
    => #f)

  (check	;double finalisation
      (let ((voice (tcl-alpha-initialise)))
  	(tcl-alpha-finalise voice)
  	(tcl-alpha-finalise voice))
    => #f)

  (check	;alive predicate after finalisation
      (let ((voice (tcl-alpha-initialise)))
  	(tcl-alpha-finalise voice)
  	(tcl-alpha?/alive voice))
    => #f)

;;; --------------------------------------------------------------------
;;; destructor

  (check
      (with-result
       (let ((voice (tcl-alpha-initialise)))
	 (set-tcl-alpha-custom-destructor! voice (lambda (voice)
							(add-result 123)))
	 (tcl-alpha-finalise voice)))
    => '(#f (123)))

;;; --------------------------------------------------------------------
;;; hash

  (check-for-true
   (integer? (tcl-alpha-hash (tcl-alpha-initialise))))

  (check
      (let ((A (tcl-alpha-initialise))
	    (B (tcl-alpha-initialise))
	    (T (make-hashtable tcl-alpha-hash eq?)))
	(hashtable-set! T A 1)
	(hashtable-set! T B 2)
	(list (hashtable-ref T A #f)
	      (hashtable-ref T B #f)))
    => '(1 2))

;;; --------------------------------------------------------------------
;;; properties

  (check
      (let ((S (tcl-alpha-initialise)))
	(tcl-alpha-property-list S))
    => '())

  (check
      (let ((S (tcl-alpha-initialise)))
	(tcl-alpha-putprop S 'ciao 'salut)
	(tcl-alpha-getprop S 'ciao))
    => 'salut)

  (check
      (let ((S (tcl-alpha-initialise)))
	(tcl-alpha-getprop S 'ciao))
    => #f)

  (check
      (let ((S (tcl-alpha-initialise)))
	(tcl-alpha-putprop S 'ciao 'salut)
	(tcl-alpha-remprop S 'ciao)
	(tcl-alpha-getprop S 'ciao))
    => #f)

  (check
      (let ((S (tcl-alpha-initialise)))
	(tcl-alpha-putprop S 'ciao 'salut)
	(tcl-alpha-putprop S 'hello 'ohayo)
	(list (tcl-alpha-getprop S 'ciao)
	      (tcl-alpha-getprop S 'hello)))
    => '(salut ohayo))

  (collect 'fullest))


;;;; done

(check-report)

;;; end of file
