(in-package :net.aserve)

(publish :path "/"
	 :function #'(lambda (req ent)
		       (with-http-response (req ent)
			 (with-http-body (req ent)
			   (html
			     (:head 
			      (:title "Hello Lisp on Heroku"))
			     ((:body :style "font-family: 'Arial'")
			      (:h1 "(Hello 'World)")
			      "Congratulations, you are running Lisp on "
			      ((:a :href "http://heroku.com") "Heroku") 
			      "!!!"
			      :p
			      ((:a :href "/db-demo") "Database demo")
			      :p
			      "More details at "
			      ((:a :href "https://github.com/mtravers/heroku-cl-example/blob/master/README.md") "the README on github")
			      :p
			      ((:img :src "lisp-glossy.jpg"))
			      ))))))

;;; Called at application initialization time.
(defun cl-user::initialize-application ()
  ;; This has to be done at app-init rather than app-build time, to point to right directory.
  (publish-directory
   :prefix "/"
   :destination (namestring (truename "./public/")))
  (wu:wuwei-initialize-application))





		   



