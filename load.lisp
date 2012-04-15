(in-package :cl-user)
;;; local load for debug

(defvar *build-dir* (pathname-directory *load-pathname*))

(load (make-pathname :directory *build-dir* :defaults "heroku-setup.lisp"))

(load (make-pathname :directory *build-dir* :defaults "local.lisp"))

(initialize-application)

(net.aserve:start :port 1666)

