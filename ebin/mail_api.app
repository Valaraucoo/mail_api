{application, 'mail_api', [
	{description, "A simple mailing API"},
	{vsn, "1.0.0"},
	{modules, ['create_h','delete_h','info_h','list_h','mail_api_app','mail_api_sup','retrieve_h','send_h','update_h']},
	{registered, [mail_api_sup]},
	{applications, [kernel,stdlib,gen_smtp]},
	{mod, {mail_api_app, []}},
	{env, []}
]}.