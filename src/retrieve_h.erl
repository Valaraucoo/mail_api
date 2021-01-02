-module(retrieve_h).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
    #{method := Method} = Req0,
    Req = case Method of
        <<"GET">> -> 
            {ok, Recordfilename} = application:get_env(mail_api, records_file_name),
            
			Id = cowboy_req:binding(id, Req0),
			RecordId = binary_to_list(Id),

			{ok, _} = dets:open_file(records_db, [{file, Recordfilename}, {type, set}]),
    		Records = dets:lookup(records_db, RecordId),
			ok = dets:close(records_db),

			case Records of
				[{RecordId2, Email}] ->
					Output = [
						<<"{\n\t\"id\": \"">>, RecordId2, <<"\",\n\t\"email\": \"">>, Email, <<"\"\n}">>
					],
					cowboy_req:reply(200, #{
						<<"content-type">> => <<"text/json">>
					}, Output, Req0);
				_ -> 
					Output = <<"Record not found.">>,
					cowboy_req:reply(404, #{
						<<"content-type">> => <<"text/json">>
					}, Output, Req0)
			end;
    _ -> 
        cowboy_req:reply(405, #{
            <<"content-type">> => <<"application/json">>
        }, <<"Method not allowed. Only GET method is available.\n">>, Req0)
    end,
    {ok, Req, State}.
