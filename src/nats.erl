% Copyright 2016 Yuce Tekol <yucetekol@gmail.com>

% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at

%     http://www.apache.org/licenses/LICENSE-2.0

% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

-module(nats).

-export([new/0,
         new/1]).
-export([connect/2,
         connect/3,
         pub/2,
         pub/3,
         hpub/3,
         sub/2,
         sub/3,
         unsub/2,
         unsub/3,
         disconnect/1,
         is_ready/1]).

-include("teacup_nats_common.hrl").

%% == API

new() ->
    new(#{}).
 
new(Opts) ->
    teacup:new(?HANDLER, Opts).

connect(Host, Port) ->
    connect(Host, Port, #{}).
    
connect(Host, Port, #{verbose := true} = Opts) ->
    {ok, Conn} = teacup:new(?HANDLER, Opts),
    case teacup:call(Conn, {connect, Host, Port}) of
        ok ->
            {ok, Conn};
        {error, _Reason} = Error ->
            Error
    end;
  
connect(Host, Port, Opts) ->
    {ok, Conn} = teacup:new(?HANDLER, Opts),
    teacup:connect(Conn, Host, Port),
    {ok, Conn}.
    
pub(Ref, Subject) ->
    pub(Ref, Subject, #{}).

-spec pub(Ref :: teacup:teacup_ref(), Subject :: binary(), Opts :: map()) ->
    ok | {error, Reason :: term()}.

pub(Ref, Subject, Opts) ->
    teacup:cast(Ref, {pub, Subject, Opts}).

hpub(Ref, Subject, Opts) ->
    teacup:cast(Ref, {hpub, Subject, Opts}).

sub(Ref, Subject) ->
    sub(Ref, Subject, #{}).

-spec sub(Ref :: teacup:teacup_ref(), Subject :: binary(), Opts :: map()) ->
    ok | {error, Reason :: term()}.

sub(Ref, Subject, Opts) ->
    teacup:cast(Ref, {sub, Subject, Opts, self()}).    

unsub(Ref, Subject) ->
    unsub(Ref, Subject, #{}).

-spec unsub(Ref :: teacup:teacup_ref(), Subject :: binary(), Opts :: map()) ->
    ok | {error, Reason :: term()}.

unsub(Ref, Subject, Opts) ->
    teacup:cast(Ref, {unsub, Subject, Opts, self()}).

-spec disconnect(Ref :: teacup:teacup_ref()) ->
    ok | {error, Reason :: term()}.

disconnect(Ref) ->
    teacup:call(Ref, {disconnect, self()}).

-spec is_ready(Ref :: teacup:teacup_ref()) ->
    true | false.

is_ready(Ref) ->
    teacup:call(Ref, is_ready).