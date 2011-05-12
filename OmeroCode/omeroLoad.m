function output_args = omeroLoad(function_args)

client_server = function_args.Server.Value;
client_user_name = function_args.UserName.Value;
client_password = function_args.Password.Value;
client_port = function_args.Port.Value;

loadOmero;

output_args.Client = omero.client(client_server, client_port);
output_args.Session = output_args.Client.createSession(client_user_name, client_password);
output_args.Gateway = output_args.Session.createGateway();


end