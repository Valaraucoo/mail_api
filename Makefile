PROJECT = mail_api
PROJECT_DESCRIPTION = A simple mailing API
PROJECT_VERSION = 1.0.0

DEPS = cowboy

# In case of errors with application dependencies, try comment/uncomment this line
DEPS = gen_smtp

dep_cowboy_commit = 2.8.0

DEP_PLUGINS = cowboy


include erlang.mk
