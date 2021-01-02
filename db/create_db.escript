#!/usr/bin/env escript

main([Filename]) ->
    Filename1 = io_lib:format("~s_records.dets", [Filename]),
    Filename2 = io_lib:format("~s_state.dets", [Filename]),
    dets:open_file(record_tab, [{file, Filename1}, {type, set}]),
    dets:open_file(record_state_tab, [{file, Filename2}, {type, set}]),
    dets:insert(record_state_tab, {current_id, 1}),
    dets:close(record_state_tab),
    dets:close(record_tab);
main(["--help"]) ->
    help();
main([]) ->
    help().

help() ->
    io:fwrite("usage: create_db.escript <db-file-stem>~n", []).
