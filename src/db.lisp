(in-package :net.aserve)

(publish :path "/db-demo"
	 :function
	 #'(lambda (req ent)
	     (with-http-response (req ent)
	       (with-http-body (req ent)
		 (maybe-setup-db)
		 (labels ((render-table ()
			    (html
			      ((:form :id "table"
				      :method "POST"
				      :onsubmit (wu:remote-function
						 (wu:ajax-continuation (:args (first last email))
						   (let ((new (make-instance 'employee
									     :emplid (incf *employee-counter*)
									     :first-name first
									     :last-name last
									     :email email)))
						     (clsql:update-records-from-instance new)
						     (wu:render-update
						       (:replace "table"
								 (render-table)))))
						 :form t))
			       ((:table)
				(:tr (:th "First Name") (:th "Last Name") (:th "Email"))
				(dolist (elt (clsql:select 'net.aserve::employee :caching nil))
				  (let ((elt (car elt)))
				  (html
				    (:tr (:td (:princ (first-name elt)))
					 (:td (:princ (last-name elt)))
					 (:td (:princ (employee-email elt)))
					 (:td (wu:link-to-remote 
					       (wu:html-string ((:img :src "delete-icon.png" :border 0)))
					       (wu:ajax-continuation ()
						 (clsql:delete-instance-records elt)
						 (wu:render-update
						   (:replace "table"
							     (render-table)))))
					      )))))
				(:tr

				 (:td ((:input :name "first")))
				 (:td ((:input :name "last")))
				 (:td ((:input :name "email")))
				 (:td ((:input :type "submit" :value "Add"))))
				)))))
		   (html
		     (:head
		      (wu:javascript-includes "prototype.js")
		      (wu:css-includes "wuwei.css")
		      (:style "
table {
border: 1px solid gray;
border-collapse: collapse;

}

th {
border: 1px solid gray;
background-color: #FFF5EE;
}

td {
border: 1px solid gray;
padding: 4px;
}
")


		      )
		     (:body
		      (:h1 "DB demo")
		      (render-table))))))
	     ))





;;; Courtesy of jaeschliman
(defun parse-heroku-db (string)
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

(defvar *db-spec*)
(defvar *local-db-password*)		;set by hand

(defun maybe-setup-db ()
  (unless (clsql:connected-databases)
    (if (on-heroku?)
	(setup-heroku-db)
	(setup-local-test-db ))))

(defun setup-heroku-db ()
  (setq *db-spec* (parse-heroku-db (ccl:getenv "DATABASE_URL"))))

(defun setup-local-test-db ()
  (setq *db-spec*
	`("localhost" "clsql-test" "travers" ,*local-db-password*)))



(defvar *employee-counter* 2)

(clsql:def-view-class employee ()
  ((emplid
    :db-kind :key
    :db-constraints :not-null
    :auto-increment t			;would be nice...
    :type integer
    :initarg :emplid)
   (first-name
    :accessor first-name
    :type (string 30)
    :initarg :first-name)
   (last-name
    :accessor last-name
    :type (string 30)
    :initarg :last-name)
   (email
    :accessor employee-email
    :type (string 100)
    :initarg :email)
   (companyid
    :type integer
    :initarg :companyid)
   (company
    :accessor employee-company
    :db-kind :join
    :db-info (:join-class company
                          :home-key companyid
                          :foreign-key companyid
                          :set nil))
   (managerid
    :type integer
    :initarg :managerid)
   (manager
    :accessor employee-manager
    :db-kind :join
    :db-info (:join-class employee
                          :home-key managerid
                          :foreign-key emplid
                          :set nil)))
  (:base-table employee))

(clsql:def-view-class company ()
  ((companyid
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :companyid)
   (name
    :type (string 100)
    :initarg :name)
   (presidentid
    :type integer
    :initarg :presidentid)
   (president
    :reader president
    :db-kind :join
    :db-info (:join-class employee
                          :home-key presidentid
                          :foreign-key emplid
                          :set nil))
   (employees
    :reader company-employees
    :db-kind :join
    :db-info (:join-class employee
                          :home-key companyid
                          :foreign-key companyid
                          :set t)))
  (:base-table company))


;;; This URL inits and performs some tests on the DB, logging output
(publish :path "/db-init"
	 :function #'(lambda (req ent)
		       (with-http-response (req ent)
			 (with-http-body (req ent)
			   (html
			     (:h1 "DB init")
			     (html-lines-out
			      (with-output-to-string (s)
				(maybe-setup-db)
				(db-init s))))))))


;;; Not necessarily the best test, presumably won't work on apps with db not installed
(defun on-heroku? ()
  (ccl:getenv "DATABASE_URL"))

(defun html-lines-out (string)
  (dolist (line (cl-ppcre:split "\\n" string))
    (html (:princ-safe line)
	  :br)))

(defmacro successively ((stream) &body body)
  `(progn
     ,@(mapcar #'(lambda (form)
		   `(progn (format ,stream "~%>> ~A" ',form)
			   (let ((result (multiple-value-list (ignore-errors ,form))))
			     (if (typep (cadr result) 'error)
				 (format ,stream "~%Error: ~A" (cadr result))
				 (format ,stream "~%<< ~A" (car result))))))
	       body)))

(defun db-init (stream)
  (successively (stream)
    (clsql:connect *db-spec* :database-type :postgresql)
    (clsql:start-sql-recording)
    (ignore-errors
      (clsql:drop-view-from-class 'employee)
      (clsql:drop-view-from-class 'company))   
    (clsql:create-view-from-class 'employee)
    (clsql:create-view-from-class 'company)
    (defvar company1 (make-instance 'company
		       :companyid 1
		       :name "Widgets Inc."
		       ;; Lenin is president of Widgets Inc.
		       :presidentid 1))

    (defvar employee1 (make-instance 'employee
			:emplid 1
			:first-name "Vladamir"
			:last-name "Lenin"
			:email "lenin@soviet.org"
			:companyid 1))
    (defvar employee2 (make-instance 'employee
			:emplid 2
			:first-name "Josef"
			:last-name "Stalin"
			:email "stalin@soviet.org"
			:companyid 1
			;; Lenin manages Stalin (for now)
			:managerid 1))

    (clsql:update-records-from-instance employee1)
    (clsql:update-records-from-instance employee2)
    (clsql:update-records-from-instance company1)))
