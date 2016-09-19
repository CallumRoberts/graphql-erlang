%% Schema definitions

-type ty_ground() :: binary() | {scalar, string | int | bool | float | id | binary()}.
-type ty() ::
	  {non_null, ty_ground()}
	| {non_null, [ty_ground()]}
	| [ty_ground()]
	| ty_ground().

-type resolver_args() :: #{ binary() => term() }.
-type ctx() :: #{ atom() => term() }.
-type resolver() :: fun ((ctx, term(), resolver_args()) -> term()).

-record(enum_value, {
    val :: binary(),
    description :: binary(),
    deprecation = undefined :: undefined | binary()
}).
-type enum_value() :: #enum_value{}.

-record(enum_type, {
	id :: binary(),
	description :: binary(),
	repr = tagged :: tagged | atom | binary,
	values :: #{ integer() => enum_value() }
}).
-type enum_type() :: #enum_type{}.

-record(interface_type, {
	id :: binary(),
	description :: binary(),
	resolve_type :: fun ((any()) -> {ok, atom()} | {error, term()}),
	fields :: #{ binary() => schema_field() }
}).
-type interface_type() :: #interface_type{}.

-record(union_type, {
	id :: binary(),
	description :: binary(),
	resolve_type :: fun ((any()) -> {ok, atom()} | {error, term()}),
	types :: [binary()]
}).
-type union_type() :: #union_type{}.

-record(schema_arg, {
	ty :: ty(),
	default = null :: any(),
	description :: binary()
}).
-type schema_arg() :: #schema_arg{}.

-record(schema_field, {
	ty :: ty(),
	description :: binary() | undefined,
	resolve = undefined :: undefined | resolver(),
	deprecation = undefined :: undefined | binary(),
	args = #{} :: #{ binary() => schema_arg() }
}).
-type schema_field() :: #schema_field{}.

-record(scalar_type, {
	id :: binary(),
	description :: binary(),
	output_coerce = fun(X) -> {ok, X} end :: fun ((any()) -> {ok, any()} | {error, any()}),
	input_coerce = fun(X) -> {ok, X} end :: fun((any()) -> {ok, any()} | {error, any()})
}).
-type scalar_type() :: #scalar_type{}.

-record(input_object_type, {
	id :: binary(),
	description :: binary(),
	fields = #{} :: #{ binary() => schema_arg() }
}).
-type input_object_type() :: #input_object_type{}.

-record(object_type, {
	id :: binary(),
	description :: binary(),
	fields = #{} :: #{ binary() => schema_field() },
	interfaces = [] :: [binary()]
}).
-type object_type() :: #object_type{}.


-record(root_schema, {
	id = 'ROOT' :: atom(),
	query :: binary(),
	mutation = undefined :: undefined | binary(),
	subscription = undefined :: undefined | binary(),
	interfaces = [] :: [binary()]
}).
-type root_schema() :: #root_schema{}.

-type schema_object() ::
	  object_type() | interface_type() | scalar_type()
	| input_object_type() | union_type() | enum_type()
	| root_schema().