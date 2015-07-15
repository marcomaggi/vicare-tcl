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
    (vicare languages tcl)
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


#;(parametrise ((check-test-name		'struct-obj)
	      (struct-guardian-logger	#t))

  (define who 'test)

;;; --------------------------------------------------------------------

  (check	;this will be garbage collected
      (let (({A <tcl-obj>} (<tcl-obj> ("ciao"))))
	;;;(debug-print A)
	(is-a? A <tcl-obj>))
    => #t)

  (check
      (let (({A <tcl-obj>} (<tcl-obj> ("ciao"))))
	(A alive?))
    => #t)

  (check	;single finalisation
      (let (({A <tcl-obj>} (<tcl-obj> ("ciao"))))
  	(A finalise))
    => #f)

  (check	;double finalisation
      (let (({A <tcl-obj>} (<tcl-obj> ("ciao"))))
  	(A finalise)
  	(A finalise))
    => #f)

  (check	;alive predicate after finalisation
      (let (({A <tcl-obj>} (<tcl-obj> ("ciao"))))
  	(A finalise)
  	(A alive?))
    => #f)

;;; --------------------------------------------------------------------
;;; destructor

  (check
      (with-result
       (let (({A <tcl-obj>} (<tcl-obj> ("ciao"))))
	 (set! (A destructor) (lambda (A)
				(add-result 123)))
	 (A finalise)))
    => '(#f (123)))

;;; --------------------------------------------------------------------
;;; hash

  (check-for-true
   (let (({V <tcl-obj>} (<tcl-obj> ("ciao"))))
     (integer? (V hash))))

  (check
      (let ((A (<tcl-obj> ("ciao")))
	    (B (<tcl-obj> ("ciao")))
	    (T (make-hashtable (lambda ({V <tcl-obj>})
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
      (let (({S <tcl-obj>} (<tcl-obj> ("ciao"))))
	(S property-list))
    => '())

  (check
      (let (({S <tcl-obj>} (<tcl-obj> ("ciao"))))
	(S putprop 'ciao 'salut)
	(S getprop 'ciao))
    => 'salut)

  (check
      (let (({S <tcl-obj>} (<tcl-obj> ("ciao"))))
	(S getprop 'ciao))
    => #f)

  (check
      (let (({S <tcl-obj>} (<tcl-obj> ("ciao"))))
	(S putprop 'ciao 'salut)
	(S remprop 'ciao)
	(S getprop 'ciao))
    => #f)

  (check
      (let (({S <tcl-obj>} (<tcl-obj> ("ciao"))))
	(S putprop 'ciao 'salut)
	(S putprop 'hello 'ohayo)
	(list (S getprop 'ciao)
	      (S getprop 'hello)))
    => '(salut ohayo))

  (collect 'fullest))


#;(parametrise ((check-test-name		'tcl-objs))

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

  (check-for-tcl-conversion
      (tcl-obj->boolean (string->tcl-obj "ciao"))
    (=> tcl-obj=?)
    (string->tcl-obj "ciao"))

;;; --------------------------------------------------------------------
;;; integers

  (check (tcl-obj->integer (integer->tcl-obj +123))	=> +123)
  (check (tcl-obj->integer (integer->tcl-obj -123))	=> -123)
  (check
      (tcl-obj->integer (integer->tcl-obj (words.least-c-signed-int)))
    => (words.least-c-signed-int))
  (check
      (tcl-obj->integer (integer->tcl-obj (words.greatest-c-signed-int)))
    => (words.greatest-c-signed-int))

  (check-for-tcl-conversion
      (tcl-obj->integer (string->tcl-obj "ciao"))
    (=> tcl-obj=?)
    (string->tcl-obj "ciao"))

;;; --------------------------------------------------------------------
;;; longs

  (check (tcl-obj->long (long->tcl-obj +123))	=> +123)
  (check (tcl-obj->long (long->tcl-obj -123))	=> -123)
  (check
      (tcl-obj->long (long->tcl-obj (words.least-c-signed-long)))
    => (words.least-c-signed-long))
  (check
      (tcl-obj->long (long->tcl-obj (words.greatest-c-signed-long)))
    => (words.greatest-c-signed-long))

  (check-for-tcl-conversion
      (tcl-obj->long (string->tcl-obj "ciao"))
    (=> tcl-obj=?)
    (string->tcl-obj "ciao"))

;;; --------------------------------------------------------------------
;;; wide ints

  (check (tcl-obj->wide-int (wide-int->tcl-obj +123))	=> +123)
  (check (tcl-obj->wide-int (wide-int->tcl-obj -123))	=> -123)
  (check
      (tcl-obj->wide-int (wide-int->tcl-obj (words.least-s64)))
    => (words.least-s64))
  (check
      (tcl-obj->wide-int (wide-int->tcl-obj (words.greatest-s64)))
    => (words.greatest-s64))

  (check-for-tcl-conversion
      (tcl-obj->wide-int (string->tcl-obj "ciao"))
    (=> tcl-obj=?)
    (string->tcl-obj "ciao"))

;;; --------------------------------------------------------------------
;;; doubles

  (check (tcl-obj->flonum (flonum->tcl-obj +123.0))	=> +123.0)
  (check (tcl-obj->flonum (flonum->tcl-obj -123.0))	=> -123.0)
  (check
      (tcl-obj->flonum (flonum->tcl-obj +123.456e7))
    => +123.456e7)
  (check
      (tcl-obj->flonum (flonum->tcl-obj -123.456e-7))
    => -123.456e-7)

  (check-for-tcl-conversion
      (tcl-obj->flonum (string->tcl-obj "ciao"))
    (=> tcl-obj=?)
    (string->tcl-obj "ciao"))

;;; --------------------------------------------------------------------
;;; bytearrays

  (check (tcl-obj->bytevector (bytevector->tcl-obj '#vu8()))		=> '#vu8())
  (check (tcl-obj->bytevector (bytevector->tcl-obj '#vu8(1 2 3 4)))	=> '#vu8(1 2 3 4))

;;; --------------------------------------------------------------------
;;; lists

  (check (tcl-obj->list (list->tcl-obj '()))		=> '())

  (check
      (map tcl-obj->integer
	(tcl-obj->list (list->tcl-obj (map integer->tcl-obj '(1 2 3 4)))))
    => '(1 2 3 4))

  (collect 'fullest))


(parametrise ((check-test-name		'scripts))

  (define (doit script)
    (with-compensations
      (letrec (({interp <tcl-interp>} (compensate
					  (<tcl-interp> ())
					(with
					 (tcl-interp-finalise interp)))))
	(interp eval script))))

  (check
      (tcl-obj->string (doit "puts stderr ciao"))
    => "")

#|
  (check
      (map tcl-obj->integer (tcl-obj->list (doit "list 1 2 3 4")))
    => '(1 2 3 4))

  (check
      (with-compensations
	(letrec (({interp <tcl-interp>} (compensate
					    (<tcl-interp> ())
					  (with
					   (tcl-interp-finalise interp)))))
	  (interp eval "set a 123" '())
	  (tcl-obj->integer (interp eval "set a" '()))))
    => 123)

  ;;Arguments to script.
  ;;
  (check
      (with-compensations
	(letrec (({interp <tcl-interp>} (compensate
					    (<tcl-interp> ())
					  (with
					   (tcl-interp-finalise interp)))))
	  (interp eval "set a " (list (integer->tcl-obj 123)))
	  (tcl-obj->integer (interp eval "set a" '()))))
    => 123)
|#
  (collect 'fullest))


;;;; done

(check-report)

#| end of program |# )

;;; end of file
