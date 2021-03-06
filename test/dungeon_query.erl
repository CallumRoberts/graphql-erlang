-module(dungeon_query).
-include("dungeon.hrl").

-export([execute/4]).

execute(_Ctx, _, <<"monster">>, #{ <<"id">> := InputID }) ->
    case dungeon:unwrap(InputID) of
        {monster, _ID} = OID ->
            dungeon:dirty_load(OID)
    end;
execute(_Ctx, _, <<"monsters">>, #{ <<"ids">> := InputIDs }) ->
    {ok, [begin
              {monster, _} = OID = dungeon:unwrap(ID),
              dungeon:dirty_load(OID)
          end || ID <- InputIDs]};
execute(_Ctx, _, <<"thing">>, #{ <<"id">> := InputID }) ->
    case dungeon:unwrap(InputID) of
        {monster, _ID} = OID -> dungeon:dirty_load(OID);
        {item, _ID} = OID -> dungeon:dirty_load(OID);
        {kraken, _ID} = OID -> {ok, kraken}
    end;
execute(_Ctx, _, <<"room">>, #{ <<"id">> := InputID }) ->
    case dungeon:unwrap(InputID) of
        {room, _ID} = OID -> dungeon:dirty_load(OID)
    end;
execute(_Ctx, _, <<"rooms">>, #{ <<"ids">> := InputIDs }) ->
    {ok, [begin
              {room, _} = OID = dungeon:unwrap(ID),
              dungeon:dirty_load(OID)
          end || ID <- InputIDs]}.

