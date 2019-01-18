(in-package :cl-user)

(print ">>> Building system....")
(print *build-dir*)
(print ">> now loading example.asd...")

(load (make-pathname :directory (namestring *build-dir*) :defaults "example.asd"))
(print ">>>> loading example now...")
(ql:quickload :example)

;;; Redefine / extend heroku-toplevel here if necessary.

(print ">>> Done building system")
