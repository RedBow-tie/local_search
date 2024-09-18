
```
3.04.00     MariaDb interface added. Dynamical load of MariaDB/MyDB interface.
            The Shell variable SWE_MARIA/SWE64_MARIA can set to the name of the driver or 
                the driver can be loaded with init_maria ( "dll_file" ).
            A change to the MariaDB-interface. The change is published in the LGPL folder. 
                For more info read the README.md file in the folder.                
            An experimental try with predefined variables: (int) _I1, (long) _L1.
            Function: getenv ( "env" ) added.
            Index ptr for Query variables added as "Sql_var = varindex" can't be used here.
                Sql_var.index () - Read index var
                Sql_var.index ( set value ) - Write            

3.03.02     Initial public version
```
