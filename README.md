# This project is an example of how to use the [Heroku Common Lisp Buildpack](https://github.com/mtravers/heroku-buildpack-cl)

## Instructions
* Have a Heroku account and Heroku command line set up
* Fork this
* heroku create -s cedar --buildpack http://github.com/mtravers/heroku-buildpack-cl.git
* git push heroku master

That's it!  And of course, modify to taste.

## More details

* The file heroku-setup.lisp gets loaded at compile time, and needs to load any Lisp files or packages required.  It can also move 

