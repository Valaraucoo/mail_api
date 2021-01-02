-module(update_h).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
	#{method := Method} = Req0,
	Req = case Method of
		<<"POST">> -> 
			{ok, Recordfilename} = application:get_env(mail_api, records_file_name),
            
			Id = cowboy_req:binding(id, Req0),
			RecordId = binary_to_list(Id),

			{ok, Email, Req1} = cowboy_req:read_body(Req0),

			case re:run(Email, "\\b[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,4}\\b") of
				{match, _} -> 
					{ok, _} = dets:open_file(records_db, [{file, Recordfilename}, {type, set}]),
					DBResponse = dets:lookup(records_db, RecordId),
					case DBResponse of
						[_] -> 
							ok = dets:insert(records_db, {RecordId, Email}),
                    		ok = dets:sync(records_db),

							cowboy_req:reply(200, #{
								<<"content-type">> => <<"text/json">>
							}, [<<"{\n\t\"id\": \"">>, RecordId, <<"\"\n\t\"email\": \"">>, Email, <<"\"\n}">>], Req1);
						_ -> 
							cowboy_req:reply(404, #{
								<<"content-type">> => <<"text/json">>
							}, <<"Record not found.">>, Req1)
					end;
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
