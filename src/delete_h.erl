-module(delete_h).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
	#{method := Method} = Req0,
	Req = case Method of
		<<"POST">> -> 
			{ok, Recordfilename} = application:get_env(mail_api, records_file_name),
            
			Id = cowboy_req:binding(id, Req0),
			RecordId = binary_to_list(Id),

			{ok, _} = dets:open_file(records_db, [{file, Recordfilename}, {type, set}]),
			DBResponse = dets:lookup(records_db, RecordId),
			case DBResponse of
				[_] -> 
					ok = dets:delete(records_db, RecordId),
					ok = dets:sync(records_db),

					cowboy_req:reply(204, #{
						<<"content-type">> => <<"text/json">>
					}, <<"">>, Req0);
				_ -> 
					Output = <<"Record not found.">>,
					cowboy_req:reply(404, #{
						<<"content-type">> => <<"text/json">>
					}, Output, Req0)
			end;
		_ ->
			cowboy_req:reply(405, #{
				<<"content-type">> => <<"application/json">>
			}, <<"Method not allowed. Only POST method is available.\n">>, Req0)
		end,
	{ok, Req, State}.
