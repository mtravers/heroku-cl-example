(in-package :cl-user)

(print ">>> Building system....")


;;load postgres
(ql:quickload :clsql)
(push (truename (make-pathname :directory (pathname-directory (asdf:system-definition-pathname :clsql))))
      asdf:*central-registry*)
(ql:quickload :clsql-postgresql)


(load (make-pathname :directory *build-dir* :defaults "example.asd"))

(ql:quickload :example)

;;; Redefine / extend heroku-toplevel here if necessary.

(print ">>> Done building system")
