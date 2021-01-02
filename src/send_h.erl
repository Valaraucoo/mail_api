-module(send_h).
-behavior(cowboy_handler).

-export([init/2]).
-export([
	send_email/3, 
	send_emails/2,
	len/1
]).


init(Req0, State) ->
	#{method := Method} = Req0,
	Req = case Method of
		<<"POST">> -> 
			{ok, Recordfilename} = application:get_env(mail_api, records_file_name),
            dets:open_file(records_db, [{file, Recordfilename}, {type, set}]),
            
            F = fun (Record, Acc) -> Acc1 = [Record | Acc], Acc1 end,
            Records = dets:foldl(F, [], records_db),
            dets:close(records_db),

            AllEmails = lists:sort(Records),
			send_emails(AllEmails, self()),

			receive
				finish ->
					cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, <<"{\n\t\"message:\" \"Successfully send emails.\"\n}">>, Req0);
				error ->
					cowboy_req:reply(505, #{
						<<"content-type">> => <<"application/json">>
					}, <<"{\n\t\"error:\" \"Something gone wrong during sending emails.\"\n}">>, Req0)
			end;
		_ ->
			cowboy_req:reply(405, #{
				<<"content-type">> => <<"application/json">>
			}, <<"Method not allowed. Only POST method is available.\n">>, Req0)
		end,
	{ok, Req, State}.


send_emails(Emails, Pid) -> 
	N = len(Emails),
	CounterRef = counters:new(1, [atomics]),

	[spawn(?MODULE, send_email, [binary_to_list(E), self(), CounterRef]) || {_, E} <- Emails],

	receive 
		ok -> 
			case counters:get(CounterRef, 1) of 
				N ->
					Pid ! finish;
				_ -> 
					io:fwrite("witam ~w", [counters:get(CounterRef, 1)])
				end;
		error -> 
			Pid ! error
	end, ok.


send_email(Email_To, Pid, CounterRef) ->
	{ok, Gmail_Login} = application:get_env(mail_api, gmail_login),
	{ok, Gmail_Password} = application:get_env(mail_api, gmail_password),

	Response = gen_smtp_client:send({
		Email_To, [Email_To],	
		"Subject: Hello\r\nFrom: Kamil Wozniak <jestem.kamil.wozniak@gmail.com>\r\nTo: \r\n\r\nYou've recived this email from Erlang Mailing API."}, 
		[{relay, "smtp.gmail.com"}, {username, Gmail_Login}, {password, Gmail_Password}]
	),

	case Response of
		{ok, _} ->
			counters:add(CounterRef, 1, 1),
			Pid ! ok;
		_ -> 
			Pid ! error
	end,
	ok.


len([]) -> 0;
len(L) -> len(L, 0).

len([_|T], Count) -> len(T, Count + 1);
len([], Count) -> Count.
