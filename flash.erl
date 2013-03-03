%% Proof of concept: Event generation through user button
%% This module also provides interface to manipulate gpio values through linux drivers
%% Bypassing linux is nearly impossible using erlang. (or am i wrong, is there a easy solution like coke and mentos for a rocket)

%% Developer Notes: FO(Ex(P)) -> CL(F) -> O(PND) -> xfxf
-module(flash).

-compile(export_all).

-define(Pin,132).


start()->
    init(),
    loop(),
    ok.

init()->
    release(?Pin),
    export(?Pin),
    set_direction(?Pin,in),
    ok.

loop()->
    receive 
	stop->
	    release(?Pin),
	    ok;
    after 40 ->
	    State = read_state(?Pin),
	    blink(State),
	    loop()
    end.

%internal Functions
blink(State)->
    case State of
	1->
	    io:format("Click");
	0->
	    io:format("released")
    end.

release(Pin) ->
    {ok, IoDevice} = file:open("/sys/class/gpio/unexport", [write]),
    file:write(IoDevice, integer_to_list(Pin)),
    file:close(IoDevice).


export(Pin)->
    {ok, IODevice} = file:open("/sys/class/gpio/export", [write]),
    file:write(IODevice, integer_to_list(Pin)),
    file:close(IODevice),

%% Make sure that you exported the pin
set_direction(Pin,Direction)->   
     {ok, IODevice} = file:open("/sys/class/gpio/gpio" ++ integer_to_list(Pin) ++ "/direction", [write]),
    case Direction of
	in  ->
	    file:write(IODevice, "in");
	out -> file:write(IODevice, "out")
    end,
    file:close(IODevice).

read_state(Pin)->
    os:cmd("cat sys/class/gpio/gpio"++integer_to_list(Pin)++"/value").
