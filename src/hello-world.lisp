(in-package :net.aserve)

(publish :path "/"
	 :function #'(lambda (req ent)
		       (with-http-response (req ent)
			 (with-http-body (req ent)
			   (html
			    (:h1 "Hello World")
			    (:princ "Congratulations, you are running Lisp on Heroku")
			    :p
			    ((:img :src "lisp-glossy.jpg"))
			    )))))

(publish-directory
 :prefix "/"
; :destination (namestring (make-pathname :directory (append cl-user::*build-dir* (append '("public")))))
 :destination "/app/public/"		;apparently this is where the app really lives, not *build-dir*?
 )

		   



