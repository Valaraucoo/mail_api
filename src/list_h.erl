-module(list_h).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    #{method := Method} = Req0,
    Req = case Method of
        <<"GET">> -> 
            {ok, Recordfilename} = application:get_env(mail_api, records_file_name),
            dets:open_file(records_db, [{file, Recordfilename}, {type, set}]),
            
            F = fun (Record, Acc) -> Acc1 = [Record | Acc], Acc1 end,
            Records = dets:foldl(F, [], records_db),
            dets:close(records_db),

            AllEmails = lists:sort(Records),
            #{email := EmailPattern} = cowboy_req:match_qs([{email, [], ""}], Req0),

            if
                EmailPattern /= "" ->
                    Emails = [{Id, Email} || {Id, Email} <- AllEmails, string:str(binary_to_list(Email), binary_to_list(EmailPattern)) > 0],
                    Output = [io_lib:format("\n\t\t{\n\t\t\t\"id\": \"~s\",\n\t\t\t\"email\": \"~s\"\n\t\t},",[Id, Email]) || {Id, Email} <- Emails],
                    Content = [<<"{\n\t\"emails\": [\t">>, Output,<<"\n\t]\n}">>],
                    cowboy_req:reply(200, #{
                        <<"content-type">> => <<"text/json">>
                    }, Content, Req0);
                true ->
                    Emails = AllEmails,
                    Output = [io_lib:format("\n\t\t{\n\t\t\t\"id\": \"~s\",\n\t\t\t\"email\": \"~s\"\n\t\t},",[Id, Email]) || {Id, Email} <- Emails],
                    Content = [<<"{\n\t\"emails\": [\t">>, Output,<<"\n\t]\n}">>],
                    cowboy_req:reply(200, #{
                        <<"content-type">> => <<"text/json">>
                    }, Content, Req0)
            end;  
    _ -> 
        cowboy_req:reply(405, #{
            <<"content-type">> => <<"application/json">>
        }, <<"Method not allowed. Only GET method is available.\n">>, Req0)
    end,
    {ok, Req, State}.
