(in-package :net.aserve)

(publish :path "/"
	 :function #'(lambda (req ent)
		       (with-http-response (req ent)
			 (with-http-body (req ent)
			   (html
			    (:h1 "(Hello 'World)")
			    (:princ "Congratulations, you are running Lisp on Heroku!!!")
			    :p
			    ((:img :src "lisp-glossy.jpg"))
			    )))))

;;; Called at application initialization time.
(defun cl-user::initialize-application ()
  ;; This has to be done at app-init rather than app-build time, to point to right directory.
  (publish-directory
   :prefix "/"
;;; works but ugly
;   :destination (namestring (truename "./public/"))
   :destination (namestring (make-pathname :directory (append cl-user::*build-dir* '("public"))))
   ))



		   



