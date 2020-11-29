======
Setup
======


Environment
===========

cat <<EOF > .env
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

EOF

mkdir -p data logs/uwsgi .ipython conf/traefik conf/nginx
#chown -R www-data data logs
setfacl -R -m u:www-data:rxw data logs


Scenarios
=========

djankiproject, django
---------------------

``djankiserv`` is a django **application** (a simple component you can snap into
any django **project**), ``djangiservproj`` is the complete
project (a standing-alone one).

database
--------

Djankiserv uses a database to store its data. To limit the numer of different
possible setup I choose to only show postresql that is my preffered one.

syncronization
---------------

The syncronization process requires data are sent using::

  Transfer-encoding: chunked

so that the easiest way is to have a proxy in front of it. In this
`docker-compose.yml` I give you the choice between:

* nginx (very simple)
* traefik (goot if you're online, it manages certificates for you)
* ngrok (it proxies call creating a tunnel and manages the certificate for
  you, but changes the name each time you restart it)

debugging
-----------

to be able to introspect what is going on this docker-compose file offers 2
possibilities:

* mitmproxy: I like it, if you use it, it will open on port 8081 a rich
  web-interface where you see all the request/response cicles.
  You don't address that drectly as it's a proxy. You set:

  export http_proxy=http://localhost:8080
  anki

  as you can add plugin I think we can develop a plugin to inspect specifically
  the content of anki syncronization, but I need to study more...


* ngrok: it also offer a web interface with request/resposnse cycle. The
  interface is at port 4040 and you need to visit that page to know which
  address you got. That addres needs to be set in anki. Wikk change any time you
  restart the container


The easiest way
---------------

* All these solutions require you to use Djankiserv connect (id: 1724518526)
  and setting the server in "network" tab of the preferences ank flag
  "use personal sync server" with terminating /djs as in
   `http://djankiserv/djs`

* All these setups end with using django and postgresql
* All different setup share what follows:

  git clone https://.../
  cd djankiserve
  docker-compose ... (see below)

install docker and docker-compose, look at the configuration to be sure you
don't occupy ports,

on your desktop
................

* ngrock:

  docker-compose up -d ngrock
  # visit page http://localhost:4040/ to see ngrok address and set it in anki ( +
  # /djs)
  # visit page http://localhost:4040/ to browse request/response
  # good for ankidroid as well (https link)


* mitmproxy + nginx:

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

* traefik

  [I suggest starting traefik separately as you would use it with other
   container, but that's not the point]

  # set dns to point here
  docker-compose up -d traefik
  # set anki/android to whatever name you choose, add /djs
  # ok for android (traefik handles certificates autonomously)

