======
Setup
======

This ``docker-compose`` file aims at making it trivial easy to create setup to
test and analize request/response cicle. It's probably not the best solution
for production and that was not the goal.

Really I didn't use kubernetes just becouse I don't (yet) know it enought
and I stumbled in an error I didn't understand, not as a suggestion this is
any better.

I decided to use:

* ``traefik`` as I believe it's a great load balancer.

* ``uwsgi`` (rather than gunicorn) as I have been using it for over 8 years and
  has the possibility to serve also static files so that you don't need nginx
  for that (but we need one for chunked anyhow...)

* ``mitmproxy`` as I believe I need to understand the protocol, and I think it
  helps to *see* request/response

* ``postgresql`` rather that mysql as I didn't manage to pip install the wheel
  but I don't feel like I want developer tools in the docker for such a minor
  thing. And I've been using Postgresql for over 24 years now...

* ``django_extensions`` as it has `show_urls` that I find very usefull!

Please, keep in mind this is just an exercise to play with this nice
gadgets.

So If you share the same need to test djankiserv w/o the hussle to setup all
the staff read on.

If I missed some information that would have helped, let me know.


Scenarios
=========

djankiproject, django
---------------------

``djankiserv`` is a django **application** (a simple component you can snap into
any django **project**), ``djangiservproj`` is the complete
project (a stand-alone one).

database
--------

Djankiserv uses a database to store its data. To limit the numer of different
possible setup I choose to only show postresql that is my preferred one.
Djankiserv currently uses 2 database, one for the users and one for the anki staff.

syncronization
---------------

The syncronization process requires data are sent using::

  Transfer-encoding: chunked

so that the easiest way is to have a proxy in front of it. In this
``docker-compose.yml`` I give you the choice between:

* ``nginx`` (very simple)
* ``traefik`` (goot if you're online, it manages certificates for you)
* ``ngrok`` (it proxies call creating a tunnel and manages the certificate for
  you, but changes the name each time you restart it)

debugging
-----------

to be able to introspect what is going on this `docker-compose` file offers 2
possibilities:

* ``mitmproxy``: I like it, if you use it, it will open on port 8081 a rich
  web-interface where you see all the request/response cicles.
  You don't address that drectly as it's a proxy. You set::

    export http_proxy=http://localhost:8080
    anki

  as you can add plugin I think we can develop a plugin to inspect specifically
  the content of anki syncronization, but I need to study more...


* ``ngrok``: it also offer a web interface with request/response cycle. The
  interface is at port 4040 and you need to visit that page to know which
  address you got. That address needs to be set in anki.
  Will change any time you restart the container


The easiest way
---------------

* All these solutions require you to tell Anki to sync to this server.
  Use ``Djankiserv connect`` (id: ``1724518526``) and set the server in
  "network" tab of the preferences ank flag
  "use personal sync server" with terminating ``/djs`` as in::

   http://djankiserv/djs

* All these setups end with using django and postgresql

* All different setup share what follows::

    git clone https://github.com/wikidattica/djankiserv
    cd djankiserve
    git checkout docker-compose
    docker-compose ... (see below)

* configuration is made via environment variable that will be read from `.env` if
  you like. Chapter Environment below explains it

install ``docker`` and ``docker-compose``, look at the configuration to be sure you
you don't have port clashes.

Environment
-------------

``docker-compose`` reads environment variables defined in ``.env``, so you can just copy
paste this block::

  cat <<-EOF > .env
  DJANKISERV_MAINDB_ENGINE=django.db.backends.postgresql
  DJANKISERV_MAINDB_NAME=djankiserv
  DJANKISERV_MAINDB_USER=anki
  DJANKISERV_MAINDB_PASSWORD=<your-pwd>
  DJANKISERV_MAINDB_HOST=127.0.0.1
  DJANKISERV_MAINDB_PORT=5432

  DJANKISERV_USERDB_ENGINE=django.db.backends.postgresql
  DJANKISERV_USERDB_NAME=djankiserv_user
  DJANKISERV_USERDB_USER=anki
  DJANKISERV_USERDB_PASSWORD=<your-pwd>
  DJANKISERV_USERDB_HOST=127.0.0.1

  DJANKISERV_DEBUG=True
  DJANKISERV_DATA_ROOT=/code/data
  DJANKISERV_SECRET_KEY='iuaeykuiywqhnriywerkiuyfnowuyrnlj'
  DJANKISERV_ALLOWED_HOSTS='localhost,127.0.0.1,djankiserv,.ngrok.io'

  POSTGRES_USER=postgres
  POSTGRES_PASSWORD=djankiserv
  POSTGRES_DB=postgres
  # how to reach traefik internal dashboard - nice but not needed
  TRAEFIK_HOST=traefik.local
  # hostname for the djankiserv. Must be dns-resolved if you're on a public server
  DJANKISERV_HOSTS=djankiserv


  EOF

  mkdir -p data logs/uwsgi .ipython conf/traefik conf/nginx
  sudo setfacl -R -m u:www-data:rxw data logs

if you don't have setfacl and used debian like: ``apt install acl``


on your desktop
................

* ``ngrock``::

    docker-compose up -d ngrock
    # visit page http://localhost:4040/ to see ngrok address and set it in anki ( +
    # /djs)
    # visit page http://localhost:4040/ to browse request/response
    # good for ankidroid as well (https link)


* ``mitmproxy + nginx``::

    docker-compose up -d mitmproxy nginx
    # set in /etc/hosts:   127.0.0.1 djankiserv
    # export http_proxy=http://127.0.0.1:8080
    # set in anki http://djankiserv/djs
    # visit page localhost:4040/ to see ngrok address and set it in anki
    # visit page localhost:4040/ to browse request/response
    # good for ankidroid as well (https link)
    # visit http://127.0.0.1:8081 to browse request/response


on a server with public ip
----------------------------

* ``traefik``::

    # set dns to point here
    docker-compose up -d traefik
    # set anki/android to whatever name you choose, add /djs
    # ok for android (traefik handles certificates autonomously)

  [I suggest starting traefik separately as you would use it with other
   container, but that's not the point]
