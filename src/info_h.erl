-module(info_h).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
    Content = <<"{
    \"author\": \"Kamil Wozniak\",
    \"email\": \"jestem.kamil.wozniak@gmail.com\",
    \"repository\": \"https://github.com/Valaraucoo/erl-api\",
    \"about\": \"A Erlang/OTP Cowboy REST application that exposes a CRUD API.\"
}">>,
    Req = cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json">>
    }, Content, Req0),
    {ok, Req, State}.
