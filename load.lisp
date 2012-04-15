(in-package :cl-user)
;;; local load for debug.
;;; Note: you have to be cd'd to the toplevel app directory for things to work.

(defvar *build-dir* (pathname-directory *load-pathname*))

(load (make-pathname :directory *build-dir* :defaults "heroku-setup.lisp"))

(load (make-pathname :directory *build-dir* :defaults "local.lisp"))

(initialize-application)

(net.aserve:start :port 1666)

