-module(mail_api_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).


start(_Type, _Args) ->
	    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", cowboy_static, {priv_file, mail_api, "index.html"}},
			{"/api/info", info_h, []},
            {"/api", list_h, []},
            {"/api/create", create_h, []},
            {"/api/get/:id", retrieve_h, []},
            {"/api/update/:id", update_h, []},
            {"/api/delete/:id", delete_h, []},
            {"/api/send", send_h, []}
		]}
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
	mail_api_sup:start_link().

stop(_State) ->
	ok.
