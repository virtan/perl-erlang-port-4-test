-module(ept).
-export([
         test/1
        ]).

test(N) ->
    Obj = gen_list(N),
    if
        N < 15 ->
            io:format("data generated: ~p~n", [Obj]);
        true -> 
            io:format("data generated: list of ~b elements~n", [N])
    end,
    process_flag(trap_exit, true),
    Port = erlang:open_port({spawn_executable, "priv/test.pl"}, [{packet, 4}, binary]),
    ToSend = term_to_binary(Obj),
    io:format("serialized data size: ~b bytes~n", [size(ToSend)]),
    Port ! {self(), {command, ToSend}},
    Begin = os:timestamp(),
    receive
        {Port, closed} ->
            io:format("port closed~n", []);
        {Port, {data, Data}} ->
            Data1 = binary_to_term(Data),
            S = case is_list(Data1) of
                    true -> length(Data1);
                    _ -> size(Data1)
                end,
            case S of
                X when X < 15 ->
                    io:format("port returned: ~p~n", [Data1]);
                _ ->
                    io:format("port returned: tuple of ~b elements~n", [S])
            end;
        {'EXIT', Port, Reason} ->
            io:format("port exited: ~p~n", [Reason])
    end,
    End = os:timestamp(),
    DelayMS = vutil:calculate_delay_mcs(Begin, End) div 1000,
    io:format("~b elements, ~b ms, ~b els/sec~n", [N, DelayMS, round(N / max(DelayMS div 1000, 1))]),
    catch erlang:port_close(Port).

gen_list(N) ->
    [base64:encode(crypto:rand_bytes(10)) || _ <- lists:seq(1, N)].
