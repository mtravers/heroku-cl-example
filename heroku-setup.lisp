(in-package :cl-user)

(print ">>> Building system....")

(load (make-pathname :directory *build-dir* :defaults "example.asd"))

(ql:quickload :example)

;;; Copy wuwei public files to build (+++ move this to wuwei to hide uglies)
;;; Note: destination and initialize-application need to be in sync
(asdf:run-shell-command
 (format nil "cp -r ~Apublic ~A"
	 (namestring (asdf:component-pathname (asdf:find-system :wuwei)))
 	 (namestring (make-pathname :directory (append *build-dir* '("wupub")))) 
	 ))

(print ">>> Done building system")
