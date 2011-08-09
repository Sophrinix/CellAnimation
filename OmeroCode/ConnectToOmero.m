function [c,s,g] = ConnectToOmero()

    %load the omero jars and directories, so they can be used anywhere
    loadOmero;

    %establish a connection with omero
    c = omero.client('omero.accre.vanderbilt.edu', 4064);

    %user input for username and password
    username = input('Omero username: ', 's');
    clc
    password = input('Omero password: ', 's');
    clc

    %use these credentials to log in and set up an omero session
    s = c.createSession(username, password);
    g = s.createGateway();
   
    clear username password
end
