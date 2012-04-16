(in-package :cl-user)

(print ">>> Building system....")

(load (make-pathname :directory *build-dir* :defaults "example.asd"))

(ql:quickload :example)

;;; Copy wuwei public files to build
(wu:heroku-install-wupub-files)

(print ">>> Done building system")
