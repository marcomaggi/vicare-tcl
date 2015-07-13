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

(when #f
  (struct-guardian-logger
   (lambda (struct exc action)
     (when (eq? action 'before-destruction)
       (fprintf (stderr) "final destruction ~s\n" struct)))))


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

;;; --------------------------------------------------------------------

  (check-for-true
   (fixnum? (tcl-major-version)))

  (check-for-true
   (fixnum? (tcl-minor-version)))

  (check-for-true
   (fixnum? (tcl-release-serial)))

  (check-for-true
   (string? (tcl-patch-level)))

  #t)


(parametrise ((check-test-name		'struct-obj)
	      (struct-guardian-logger	#t))

  (define who 'test)

  (check	;this will be garbage collected
      (let ((obj (tcl-obj-make-string "")))
	#;(debug-print obj)
	(tcl-obj? obj))
    => #t)

  (check
      (tcl-obj?/alive (tcl-obj-make-string ""))
    => #t)

  (check	;single finalisation
      (let ((obj (tcl-obj-make-string "ciao")))
	#;(debug-print 'str obj)
  	(tcl-obj-finalise obj))
    => #f)

  (check	;double finalisation
      (let ((obj (tcl-obj-make-string "")))
  	(tcl-obj-finalise obj)
  	(tcl-obj-finalise obj))
    => #f)

  (check	;alive predicate after finalisation
      (let ((obj (tcl-obj-make-string "")))
  	(tcl-obj-finalise obj)
  	(tcl-obj?/alive obj))
    => #f)

;;; --------------------------------------------------------------------
;;; destructor

  (check
      (with-result
	(let ((obj (tcl-obj-make-string "")))
	  (set-tcl-obj-custom-destructor! obj (lambda (obj)
						(add-result 123)))
	  (tcl-obj-finalise obj)))
    => '(#f (123)))

;;; --------------------------------------------------------------------
;;; hash

  (check-for-true
   (integer? (tcl-obj-hash (tcl-obj-make-string ""))))

  (check
      (let ((A (tcl-obj-make-string ""))
	    (B (tcl-obj-make-string ""))
	    (T (make-hashtable tcl-obj-hash eq?)))
	(hashtable-set! T A 1)
	(hashtable-set! T B 2)
	(list (hashtable-ref T A #f)
	      (hashtable-ref T B #f)))
    => '(1 2))

;;; --------------------------------------------------------------------
;;; properties

  (check
      (let ((S (tcl-obj-make-string "")))
	(tcl-obj-property-list S))
    => '())

  (check
      (let ((S (tcl-obj-make-string "")))
	(tcl-obj-putprop S 'ciao 'salut)
	(tcl-obj-getprop S 'ciao))
    => 'salut)

  (check
      (let ((S (tcl-obj-make-string "")))
	(tcl-obj-getprop S 'ciao))
    => #f)

  (check
      (let ((S (tcl-obj-make-string "")))
	(tcl-obj-putprop S 'ciao 'salut)
	(tcl-obj-remprop S 'ciao)
	(tcl-obj-getprop S 'ciao))
    => #f)

  (check
      (let ((S (tcl-obj-make-string "")))
	(tcl-obj-putprop S 'ciao 'salut)
	(tcl-obj-putprop S 'hello 'ohayo)
	(list (tcl-obj-getprop S 'ciao)
	      (tcl-obj-getprop S 'hello)))
    => '(salut ohayo))

  (collect 'fullest))


(parametrise ((check-test-name		'struct-interp)
	      (struct-guardian-logger	#t))

  (define who 'test)

  (check	;this will be garbage collected
      (let ((interp (tcl-interp-initialise)))
;;;(debug-print interp)
	(tcl-interp? interp))
    => #t)

  (check
      (tcl-interp?/alive (tcl-interp-initialise))
    => #t)

  (check	;single finalisation
      (let ((interp (tcl-interp-initialise)))
  	(tcl-interp-finalise interp))
    => #f)

  (check	;double finalisation
      (let ((interp (tcl-interp-initialise)))
  	(tcl-interp-finalise interp)
  	(tcl-interp-finalise interp))
    => #f)

  (check	;alive predicate after finalisation
      (let ((interp (tcl-interp-initialise)))
  	(tcl-interp-finalise interp)
  	(tcl-interp?/alive interp))
    => #f)

;;; --------------------------------------------------------------------
;;; destructor

  (check
      (with-result
	(let ((interp (tcl-interp-initialise)))
	  (set-tcl-interp-custom-destructor! interp (lambda (interp)
						      (add-result 123)))
	  (tcl-interp-finalise interp)))
    => '(#f (123)))

;;; --------------------------------------------------------------------
;;; hash

  (check-for-true
   (integer? (tcl-interp-hash (tcl-interp-initialise))))

  (check
      (let ((A (tcl-interp-initialise))
	    (B (tcl-interp-initialise))
	    (T (make-hashtable tcl-interp-hash eq?)))
	(hashtable-set! T A 1)
	(hashtable-set! T B 2)
	(list (hashtable-ref T A #f)
	      (hashtable-ref T B #f)))
    => '(1 2))

;;; --------------------------------------------------------------------
;;; properties

  (check
      (let ((S (tcl-interp-initialise)))
	(tcl-interp-property-list S))
    => '())

  (check
      (let ((S (tcl-interp-initialise)))
	(tcl-interp-putprop S 'ciao 'salut)
	(tcl-interp-getprop S 'ciao))
    => 'salut)

  (check
      (let ((S (tcl-interp-initialise)))
	(tcl-interp-getprop S 'ciao))
    => #f)

  (check
      (let ((S (tcl-interp-initialise)))
	(tcl-interp-putprop S 'ciao 'salut)
	(tcl-interp-remprop S 'ciao)
	(tcl-interp-getprop S 'ciao))
    => #f)

  (check
      (let ((S (tcl-interp-initialise)))
	(tcl-interp-putprop S 'ciao 'salut)
	(tcl-interp-putprop S 'hello 'ohayo)
	(list (tcl-interp-getprop S 'ciao)
	      (tcl-interp-getprop S 'hello)))
    => '(salut ohayo))

  (collect 'fullest))


(parametrise ((check-test-name		'tcl-objs))

;;; booleans

  (check-for-true	(tcl-obj->boolean (boolean->tcl-obj #t)))
  (check-for-false	(tcl-obj->boolean (boolean->tcl-obj #f)))

  (check-for-true	(tcl-obj->boolean (string->tcl-obj "yes")))
  (check-for-false	(tcl-obj->boolean (string->tcl-obj "no")))

  (check-for-true	(tcl-obj->boolean (string->tcl-obj "true")))
  (check-for-false	(tcl-obj->boolean (string->tcl-obj "false")))

  (check-for-true	(tcl-obj->boolean (string->tcl-obj "on")))
  (check-for-false	(tcl-obj->boolean (string->tcl-obj "off")))

  (check-for-true	(tcl-obj->boolean (string->tcl-obj "1")))
  (check-for-false	(tcl-obj->boolean (string->tcl-obj "0")))

  (check		(tcl-obj->string (boolean->tcl-obj #t))		=> "1")
  (check		(tcl-obj->string (boolean->tcl-obj #f))		=> "0")

  (collect 'fullest))


(parametrise ((check-test-name		'scripts))

  (check
      (with-compensations
	(letrec ((interp (compensate
			     (tcl-interp-initialise)
			   (with
			    (tcl-interp-finalise interp)))))
	  (tcl-obj->string (tcl-interp-eval interp "puts stderr ciao"))))
    => "")

  (collect 'fullest))


;;;; done

(collect 'fullest)
(check-report)

;;; end of file
