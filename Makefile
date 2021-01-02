PROJECT = mail_api
PROJECT_DESCRIPTION = A simple mailing API
PROJECT_VERSION = 1.0.0

DEPS = cowboy
dep_cowboy_commit = 2.8.0

DEP_PLUGINS = cowboy

DEPS = gen_smtp

include erlang.mk
