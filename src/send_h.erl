-module(send_h).
-behavior(cowboy_handler).

-export([init/2]).
-export([send_email/1]).


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
			[spawn(?MODULE, send_email, [binary_to_list(E)]) || {_, E} <- AllEmails],

			cowboy_req:reply(200, #{
				<<"content-type">> => <<"application/json">>
			}, <<"{\n\t\"message:\" \"Successfully send emails.\"\n}">>, Req0);
		_ ->
			cowboy_req:reply(405, #{
				<<"content-type">> => <<"application/json">>
			}, <<"Method not allowed. Only POST method is available.\n">>, Req0)
		end,
	{ok, Req, State}.


send_email(Email_To) ->
	{ok, Gmail_Login} = application:get_env(mail_api, gmail_login),
	{ok, Gmail_Password} = application:get_env(mail_api, gmail_password),

	gen_smtp_client:send({
		Email_To, [Email_To],	
		"Subject: Hello\r\nFrom: Kamil Wozniak <jestem.kamil.wozniak@gmail.com>\r\nTo: \r\n\r\nYou've recived this email from Erlang Mailing API."}, 
		[{relay, "smtp.gmail.com"}, {username, Gmail_Login}, {password, Gmail_Password}]),
	ok.
