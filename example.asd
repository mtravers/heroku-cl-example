(in-package :asdf)

(defsystem :example
    :name "example"
    :description "Example cl-heroku application"
    :depends-on (:aserve 
		 :clsql :clsql-postgresql ;for database access
		 :wuwei)		  ;for database demo
    :components
    ((:static-file "example.asd")
     (:module :src
	      :serial t      
	      :components
	      ((:file "hello-world")
	       (:file "db"))
	      )))

