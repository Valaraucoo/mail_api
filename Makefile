PROJECT = mail_api
PROJECT_DESCRIPTION = A simple mailing API
PROJECT_VERSION = 1.0.0

DEPS = cowboy gen_smtp

dep_cowboy = https://github.com/ninenines/cowboy 2.8.0
dep_gen_smtp = https://github.com/gen-smtp/gen_smtp 1.0.0


include erlang.mk
