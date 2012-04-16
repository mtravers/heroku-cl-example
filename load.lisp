(in-package :cl-user)
;;; local load for debug. Replicates some of the things in buildpack/compile.lisp
;;; Note: you have to be cd'd to the toplevel app directory for things to work.

(defvar *build-dir* (pathname-directory (truename *load-pathname*)))

;;; Load local copies of portableaserve and wuwei, since quicklisp's are broken
;;; (You can get these from github.com/mtravers.  Put them the repos directory).
(mapc #'load (directory (make-pathname :directory  '(:relative "repos" :wild-inferiors)
				       :name :wild
				       :type "asd")))

(load "~/repos/wuwei/wuwei.asd")	;Use local copy of wuwei;

(load (make-pathname :directory *build-dir* :defaults "heroku-setup.lisp"))

(load (make-pathname :directory *build-dir* :defaults "local.lisp"))

(initialize-application)

(net.aserve:start :port 1666)

