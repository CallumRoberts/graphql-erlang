-module(graphql).

-include("graphql_internal.hrl").

%% GraphQL Documents
-export([
         parse/1,
         elaborate/1,
         type_check/1, type_check_params/3,
         validate/1,
         execute/1, execute/2
        ]).

%% Schema Definitions
-export([
         load_schema/2,
         insert_schema_definition/1,
         validate_schema/0
]).

-type json() :: number() | binary() | true | false | null | #{ binary() => json() }.
-type param_context() :: json().

-type schema_definition() :: {atom(), #{ atom() => term() }}.

-export_type([ast/0, json/0, param_context/0]).

-type schema_field() :: #{ atom() => any() }.
-export_type([schema_field/0]).

-spec parse( binary() | string()) ->
                   {ok, ast()} | {error, {scanner_error | parser_error, term()}}.
parse(Input) when is_binary(Input) -> parse(binary_to_list(Input));
parse(Input) when is_list(Input) ->
    case graphql_scanner:string(Input) of
        {ok, Tokens, _EndLine} ->
            case graphql_parser:parse(Tokens) of
                {ok, Res} ->
                    {ok, Res};
                {error, Err} ->
                    {error, {parser_error, Err}}
            end;
        {error, Err, _EndLine} ->
            {error, {scanner_error, Err}}
    end.

load_schema(Mapping, Input) when is_binary(Input) ->
    load_schema(Mapping, binary_to_list(Input));
load_schema(Mapping, Input) when is_list(Input) ->
    case graphql_scanner:string(Input) of
        {ok, Tokens, _EndLine} ->
            case graphql_parser:parse(Tokens) of
                {ok, _} = Result ->
                    graphql_schema_parse:inject(Mapping, Result);
                {error, Err} ->
                    {error, Err}
            end;
        {error, Err, _EndLine} ->
            {error, Err}
    end.

-spec validate(ast()) -> ok | {error, term()}.
validate(AST) ->
    graphql_validate:x(AST).
    
-spec type_check(ast()) -> {ok, #{ atom() => term() }}.
type_check(AST) ->
    graphql_type_check:x(AST).

-spec elaborate(ast()) -> ast().
elaborate(AST) ->
   graphql_elaborate:x(AST).

-spec type_check_params(any(), any(), any()) -> param_context().
type_check_params(FunEnv, OpName, Vars) ->
    graphql_type_check:x_params(FunEnv, OpName, Vars).

-spec execute(ast()) -> #{ atom() => json() }.
execute(AST) -> execute(#{ params => #{} }, AST).

-spec execute(context(), ast()) -> #{ atom() => json() }.
execute(Ctx, AST) ->
    graphql_execute:x(Ctx, AST).

%% @doc insert_schema_definition/1 loads a schema definition into the Graph Schema
%% @end
-spec insert_schema_definition(schema_definition()) -> ok | {error, Reason}
  when Reason :: term().
insert_schema_definition(Defn) ->
    graphql_schema:load(Defn).

%% STUB for now
-spec validate_schema() -> ok | {error, any()}.
validate_schema() ->
    graphql_schema_validate:x().

