(in-package :cl-user)

(print ">>> Building system....")

(load (make-pathname :directory *build-dir* :defaults "example.asd"))

(ql:quickload :example)

(print ">>> Done building system")
