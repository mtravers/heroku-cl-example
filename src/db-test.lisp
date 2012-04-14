(in-package :net.aserve)

(publish :path "/db-test"
	 :function #'(lambda (req ent)
		       (with-http-response (req ent)
			 (with-http-body (req ent)
			   (html
			     (:h1 "DB test")
			     (html-lines-out
			      (with-output-to-string (s)
				(if (on-heroku?)
				    (setup-heroku-db)
				    (setup-local-test-db ))
				(db-test s))))))))

(publish :path "/db-demo"
	 :function #'(lambda (req ent)
		       (with-http-response (req ent)
			 (with-http-body (req ent)
			   (html
			     (:h1 "DB demo")
			     (:table
			      (dolist (elt (clsql:select 'net.aserve::employee))
				(html
				(:tr (:td (:princ (first-name (car elt))))
				     (:td (:princ (last-name (car elt))))
				     (:td (:princ (employee-email (car elt)))))))))))))




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

;;; Not necessarily the best test, presumably won't work on apps with db not installed
(defun on-heroku? ()
  (ccl:getenv "DATABASE_URL"))

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

(defun setup-heroku-db ()
  (setq *db-spec* (parse-heroku-db (ccl:getenv "DATABASE_URL"))))

(defun setup-local-test-db ()
  (setq *db-spec*
	`("localhost" "clsql-test" "travers" ,*local-db-password*)))

(defun db-test (stream)
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

(clsql:def-view-class employee ()
  ((emplid
    :db-kind :key
    :db-constraints :not-null
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


