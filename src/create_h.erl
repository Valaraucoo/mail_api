-module(create_h).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
	#{method := Method} = Req0,
	Req = case Method of
		<<"POST">> -> 
			{ok, Email, Req1} = cowboy_req:read_body(Req0),
			case re:run(Email, "\\b[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,4}\\b") of
				{match, _} -> 
					RecordId = generate_record_id(),
					{ok, Recordfilename} = application:get_env(mail_api, records_file_name),
					{ok, _} = dets:open_file(records_db, [{file, Recordfilename}, {type, set}]),

					ok = dets:insert(records_db, {RecordId, Email}),
					ok = dets:sync(records_db),
					ok = dets:close(records_db),

					cowboy_req:reply(201, #{
						<<"content-type">> => <<"application/json">>
					}, [<<"{\n\t\"id\": \"">>, RecordId, <<"\"\n\t\"email\": \"">>, Email, <<"\"\n}">>], Req1);
				nomatch -> 
					cowboy_req:reply(404, #{
						<<"content-type">> => <<"application/json">>
					}, [<<"{\n\terror: \"">>, "email address is not correct", <<"\"\n}">>], Req0)
				end;
		_ ->
			cowboy_req:reply(405, #{
				<<"content-type">> => <<"application/json">>
			}, <<"Method not allowed. Only POST method is available.\n">>, Req0)
		end,
	{ok, Req, State}.


generate_record_id() -> 
    {ok, Statefilename} = application:get_env(mail_api, state_file_name),
    dets:open_file(state_db, [{file, Statefilename}, {type, set}]),
    Records = dets:lookup(state_db, current_id),
    Response = case Records of
        [{current_id, CurrentId}] ->
            NextId = CurrentId + 1,
            dets:insert(state_db, {current_id, NextId}),
            Id = lists:flatten(io_lib:format("~4..0B", [CurrentId])),
            Id;
        [] ->
            error
    end,
    dets:close(state_db),
    Response.
