(in-package :net.aserve)

(defun parse-db (string)
  "parse the heroku db url"
  (let* ((s (subseq string 11))
	 (colon (position #\: s))
	 (at (position #\@ s))
	 (slash (position #\/ s :from-end t)))
    (let ((user (subseq s 0 colon))
	 (pass (subseq s (1+ colon) at))
	 (server (subseq s (1+ at) slash))
	 (database (subseq s (1+ slash))))
      (list server database user pass))))

(publish :path "/"
	 :function #'(lambda (req ent)
		       (with-http-response (req ent)
			 (with-http-body (req ent)
			   (html
			    (:h1 "(Hello 'World)")
			    (:princ "Congratulations, you are running Lisp on Heroku!!!")
			    :p
			    (if *conn*
				(html (:princ " postgres connected!")))
			    ;(:princ *conn*)
			    :p
			    ((:img :src "lisp-glossy.jpg"))
			    )))))

(defparameter *conn* nil)

(defun cl-user::initialize-application ()

  ;;open the postgres connection
  (setf *conn* (clsql:connect (parse-db (ccl:getenv "DATABASE_URL"))
			      :database-type :postgresql))
  
  ;; This has to be done at app-init rather than app-build time, to point to right directory.
  (publish-directory
   :prefix "/"
   :destination "./public/")  )





