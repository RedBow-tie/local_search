
 
This folder contains changes to program with LGPL license (for now only MariaDb).
It’s only an export of the function "_mariadb_set_conf_option", but I think I must published it.
As I would like connect to the database the same way as I connect to a PostgreSQL database.
This function is otherwise used when you put the settings in a file, now I can have 
the settings in the code instead.

You can define "EMBEDDED_LIBRARY" when you compile "mariadb_obj".
So can you connect to the database without SSL, no need if you is using it 
only locally. Don’t forget you must recompile the whole connector-c project
after you have made the changes.

You can use a non modified dll-file if you like but then you can only use the default
connect function.
