
#USE_ACUTE // ´ is used insted of esaping a " (\")

/*
    Example ODBC connection string

    "DRIVER={MariaDB ODBC 3.2 Driver};TCPIP=1;SERVER=localhost;UID=root;PWD=happy;PORT=3306;DB=mysql;" 
    "DSN=xls" 
    "Driver={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};DBQ='c:\\data\\test.xls';ReadOnly=0;" 
  
*/


query sql
int i


form odbc (), nowait
    layout "" child NOCAPTION exstyle=1

 a             a                      b           b
 a             a                      b           b
                                      b           b


 c    cd                                          d
       d              d
end
pre
    .display ()
end
    tooltip
        B_DNS, "Reg database connection in ODBC Data Source (" + ( _win64 ? "64)" : "32)" ) 

field
2       //ESC 
    select     
    end

c: "Connect"
d: W_CON ed hscroll, display ( reg_str ( "con_odbc" ) )
b: bt "Connect"
    select
        int i

        if ( trim ( .W_CON ) == "" )
            info ( "Please enter connection string" )
        else
            i = db.odbc ( .W_CON ) 

            if ( ! i )
                reg_str ( "con_odbc", .W_CON )

                db_con.close ( 0 )
            end
        end
    end
b: BT "Templ. MariaDB"
    select
        .value ( W_CON, "DRIVER={MariaDB ODBC 3.2 Driver};TCPIP=1;SERVER=localhost;UID=root;PWD=happy;PORT=3306;DB=mysql;" )
    end
b: B_DNS BT "Templ. DNS" 
    select
        .value ( W_CON, "DSN=MyDatabase" )
    end
end

form sqlite (), nowait
    layout "" child NOCAPTION exstyle=1

 a             a                         b        b
 a             a      



 c    cd                                          d
       d           d 

end
pre
    .display ()
end
field
2       //ESC 
    select     
    end

c: "Connect"
d: W_CON ed hscroll, display ( reg_str ( "con_sqlite" ) )

b: bt "Open"
    select
        if ( trim ( .W_CON ) == "" )
            info ( "Please enter file name" )
        else
            i = db.sqlite ( .W_CON ) 
            if ( i )
                warning ( sql.error () )        
            else
                reg_str ( "con_sqlite", .W_CON )
                db_con.close ( 0 )
            end
        end
    end
end


form postgres (), nowait
    layout "" child NOCAPTION exstyle=1

 a     ab                        b  c       c
 a     ab   b
 a     ab                        b
 a     ab                        b
 a     ab                        b
 a     ab                        b

        d           d 
    end
    pre 
        if ( reg_str ( "server" ) == "" )
            .value ( E1, "localhost" )
            .value ( E2, "5432" )
            .value ( E3, "postgres" )
            .value ( E5, "postgres" )
        else
            .display ()        
        end
    end
field
2       //ESC 
    select     
    end
a: "Server"
b: E1 EDIT, display ( reg_str ( "server" ) )
a: "Port"
b: E2 EDIT num, display ( reg_str ( "server_port" ) )
a: "Database"
b: E5 EDIT, display ( reg_str ( "database" ) )
a: "Login"
b: E3 EDIT, display ( reg_str ( "login" ) )
a: "Password"
b: E4 EDIT 
a: "Extra"
b: E6 EDIT, display ( reg_str ( "adv" ) ) 

c: AL BT "Login"
    select
//db.ssl_cert () sslmode=require 
        i = db.postgresql ( "host=[#.E1] port=[#.E2] dbname=[#.E5] user=[#.E3] password=[#.E4] [#.E6]" ) 
        if ( i )
            warning ( sql.error () )        
        else
            reg_str ( "server", .E1 )

            reg_str ( "server_port", .E2 )
            reg_str ( "database", .E5 ) 
            reg_str ( "login", .E3 )
            reg_str ( "adv", .E6 ) 

            db_con.close ( 0 )
        end
    end
end

form postgres1 (), nowait
    layout "" child NOCAPTION exstyle=1

 a     ab                        b  c       c
 a     ab   b
 a     ab                        b
 a     ab                        b
 a     ab                        b
 a     ab                        b

        d           d 
    end
    pre 
        if ( reg_str ( "server1" ) == "" )
            .value ( E1, "localhost" )
            .value ( E2, "5432" )
            .value ( E3, "postgres" )
            .value ( E5, "postgres" )
        else
            .display ()        
        end
    end
field
2       //ESC 
    select    
    end
a: "Server"
b: E1 EDIT, display ( reg_str ( "server1" ) )
a: "Port"
b: E2 EDIT num, display ( reg_str ( "server_port1" ) )
a: "Database"
b: E5 EDIT, display ( reg_str ( "database1" ) )
a: "Login"
b: E3 EDIT, display ( reg_str ( "login1" ) )
a: "Password"
b: E4 EDIT 
a: "Extra"
b: E6 EDIT, display ( reg_str ( "adv" ) ) 

c: AL BT "Login"
    select
//db.ssl_cert () sslmode=require 
        i = db.postgresql ( "host=[#.E1] port=[#.E2] dbname=[#.E5] user=[#.E3] password=[#.E4] [#.E6]" ) 
        if ( i )
            warning ( sql.error () )        
        else

            reg_str ( "server1", .E1 )

            reg_str ( "server_port1", .E2 )
            reg_str ( "database1", .E5 ) 
            reg_str ( "login1", .E3 )
            reg_str ( "adv1", .E6 ) 

            db_con.close ( 0 )
        end
    end
end

form db_con ()
    layout "Login" sysmenu

 a













                                                        a

end
pre
    int i

    if ( USEPOSTGRESQL_DB )
        .addpage ( W_TAB, i ++, "PostgeSQL 1", postgres )
        .addpage ( W_TAB, i ++, "PostgeSQL 2", postgres1 )
    end
    if ( USESQLITE_DB )
        .addpage ( W_TAB, i ++, "Sqlite", sqlite )
    end
    if ( USEODBC_DB )
        .addpage ( W_TAB, i ++, "Odbc", odbc )
    end

    .selectpage ( W_TAB, 0 )  
end

field
a: W_TAB tc

end

