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

(defun cl-user::initialize-application ()
  ;; This has to be done at app-init rather than app-build time, to point to right directory.
  ;; Sometimes the static files just don't show up -- no idea why, sigh
  (publish-directory
   :prefix "/"
   :destination (namestring (truename "./public/"))))


		   



