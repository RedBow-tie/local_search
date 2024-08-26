
#USE_ACUTE // ´ is used insted of esaping a " (\")

/*
    Example ODBC connection string

    "DRIVER={MariaDB ODBC 3.2 Driver};TCPIP=1;SERVER=localhost;UID=root;PWD=happy;PORT=3306;DB=mysql;" 
    "DSN=xls" 
    "Driver={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};DBQ='c:\\data\\test.xls';ReadOnly=0;" 
  
*/


extern int Ver
query sql
int i

func login ()
    text log_in

    REG_SECTION ( "SOFTWARE\\swec\\apps" )

    switch ( reg_int ( "auto" ) )
        case 1
            if ( POSTGRESQL_DB )        //Don't try to login if you choose a other program
                log_in = "host=" + reg_str ( "server" )
                log_in += " port=" + reg_str ( "server_port" )
                log_in += " dbname=" + reg_str ( "database" )
                log_in += " user= " + reg_str ( "login" )
                log_in += " password=" + reg_str ( "pwd" ) 
                if ( reg_str ( "adv" ) != "" )
                    log_in += " " + reg_str ( "adv" )
                end

                i = db.postgresql ( log_in ) 
                if ( i == 0 )
                    Ver = db.SERVERVERSION () / 10000
                    if ( check_not_del () == 0 )
                        return 0
                    end
                end
            end
            break
        case 2
            if ( POSTGRESQL_DB )
                log_in = "host=" + reg_str ( "server1" )
                log_in += " port=" + reg_str ( "server_port1" )
                log_in += " dbname=" + reg_str ( "database1" )
                log_in += " user= " + reg_str ( "login1" )
                log_in += " password=" + reg_str ( "pwd1" ) 
                if ( reg_str ( "adv1" ) != "" )
                    log_in += " " + reg_str ( "adv1" )
                end

                i = db.postgresql ( log_in ) 
                if ( i == 0 )
                    Ver = db.SERVERVERSION () / 10000
                    if ( check_not_del () == 0 )
                        return 0
                    end
                end
            end
            break
        case 3  //SQLite
            if ( SQLITE_DB )
                i = db.sqlite ( reg_str ( "con_sqlite" ) ) 
                if ( ! i )
                    if ( check_not_del () == 0 )
                        return 0
                    end
                end
            end
            break
        case 4  //odbc
            if ( ODBC_DB )
                i = db.odbc (  reg_str ( "con_odbc" ) ) 

                if ( ! i )
                    if ( left ( db.driver_name (), 6 ) == "SQLSRV" )
                        stop ( "SQL Express not supported" )
                    else
                        if ( check_not_del () == 0 )
                            return 0
                        end
                    end
                end
            end
            break
    end
    return login1 ()
end


func check_not_del ()
    return sql.exec_noerr ( "select * from disk_files limit 1" )
end

form odbc (), nowait
    layout "" child NOCAPTION exstyle=1

 a             a                      b           b
 a             a                      b           b
                                      b           b
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
d: TCON TB "Auto connect", display ( reg_int ( "auto" ) == 4 )
b: bt "Connect"
    select
        int i

        if ( trim ( .W_CON ) == "" )
            info ( "Please enter connection string" )
        else
            i = db.odbc ( .W_CON ) 

            if ( ! i )
                if ( left ( db.driver_name (), 6 ) == "SQLSRV" )
                    stop ( "SQL Express not supported" )
                    return
                end
                reg_int ( "auto", (.checked ( TCON ) ? 4 : 0 ) )
                reg_str ( "con_odbc", .W_CON )
                i = sql.exec_noerr ( "select * from disk_files limit 1" )
                if ( i )
                    if ( ask ( "Table ´disk_files´ is missing. Create ?" ) == IDYES )
                        cre_old ()                                
                    end
                end

                login1.close ( 0 )
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

b: BT "Templ. SqlExpress" hidden 
    select 
        .value ( W_CON, "DRIVER={SQL Server};SERVER=localhost\sqlexpress;DB=main;" )
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
    if ( reg_str ( "con_sqlite" ) == "" )
        .value ( W_CON, "lo_files.db" )
    end
end
field
2       //ESC 
    select     
    end

c: "Connect"
d: W_CON ed hscroll, display ( reg_str ( "con_sqlite" ) )
d: TCON TB "Auto connect", display ( reg_int ( "auto" ) == 3 )

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
                reg_int ( "auto", (.checked ( TCON ) ? 3 : 0) )

                i = sql.exec_noerr ( "select * from disk_files limit 1" )
                if ( i )
                    if ( ask ( "Table ´disk_files´ is missing. Create ?" ) == IDYES )
                        cre_old ()                                
                    end
                end
                
                login1.close ( 0 )
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

d: TCON TB "Auto connect", display ( reg_int ( "auto" ) == 1)
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
            reg_int ( "auto", (.checked ( TCON ) ? 1 : 0) )
            reg_str ( "adv", .E6 ) 

            if ( .checked ( TCON ) )
                reg_str ( "pwd", .E4 )
            else 
                reg_str ( "pwd", "" )
            end
            Ver = db.SERVERVERSION () / 10000
            i = sql.exec_noerr ( "select * from disk_files limit 1" )
            if ( i )
                if ( ask ( "Table ´disk_files´ is missing. Create ?" ) == IDYES )
                    if ( Ver < 9 )
                        if ( ! cre_old () )                        
                            return 0
                        end
                    else
                        if ( ! cre_df () )
                            return 0
                        end
                    end
                else
                    return 0
                end
            end
            login1.close ( 0 )
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

d: TCON TB "Auto connect", display ( reg_int ( "auto" ) == 2 )
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
            reg_int ( "auto", (.checked ( TCON ) ? 2 : 0) )
            reg_str ( "adv1", .E6 ) 

            if ( .checked ( TCON ) )
                reg_str ( "pwd", .E4 )
            else 
                reg_str ( "pwd", "" )
            end
            Ver = db.SERVERVERSION () / 10000
            i = sql.exec_noerr ( "select hd from disk_files limit 1" )
            if ( i )
                if ( ask ( "Table ´disk_files´ is missing. Create ?" ) == IDYES )
                    if ( Ver < 9 )
                        if ( ! cre_old () )                        
                            return 0
                        end
                    else
                        if ( ! cre_df () )
                            return 0
                        end
                    end
                else
                    return 0
                end
            end
            login1.close ( 0 )
        end
    end
end

form login1 ()
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


func cre_df ()
    onerror sql.abort ()    

    sql.begin ()
    sql.exec ( "CREATE TABLE disk_files (" \
        "hd character(2) NOT NULL," \
        "folder text NOT NULL," \
        "file text NOT NULL," \
        "type text COLLATE pg_catalog.´C´  NOT NULL," \
        "date timestamp without time zone," \
        "size bigint)" )

    sql.exec ( "CREATE TABLE ext ( ext text )" )
    sql.exec ( "CREATE INDEX ext_ext ON ext (ext) " )
    sql.exec ( "create table disk_settings ( bt int, label char (10), sel text, usr text, primary key (usr, bt))" )

    sql.exec ( "CREATE INDEX disk_hd_folder ON disk_files USING btree " \
        "(hd COLLATE pg_catalog.´default´, folder COLLATE pg_catalog.´default´, " \
        "file COLLATE pg_catalog.´default´)" )

    sql.exec ( "CREATE INDEX disk_folder ON disk_files USING btree " \
        "(folder COLLATE pg_catalog.´default´, " \
        "file COLLATE pg_catalog.´default´)" )

    sql.exec ( "CREATE INDEX disk_file ON disk_files USING btree " \
        "(file COLLATE pg_catalog.´default´)" )

    sql.exec ( "CREATE INDEX disk_type_file ON disk_files USING btree" \
        "(type COLLATE pg_catalog.´C´, file COLLATE pg_catalog.´default´)" )

    sql.exec ( "CREATE INDEX disk_date" \
        " ON disk_files USING btree " \
        "(date, file COLLATE pg_catalog.´default´," \
        "folder COLLATE pg_catalog.´default´)" )

    sql.exec ( "CREATE INDEX disk_size_file ON disk_files USING btree " \
        "(size, file COLLATE pg_catalog.´default´, folder COLLATE pg_catalog.´default´)" )

    sql.commit ()
end


func cre_old ()
    char x 100

    onerror sql.abort ()    

    sql.begin ( "transaction" )
    if ( db.dbtype () == ODBC_DB )
        x = ""
    else
        x = "without time zone"
    end


    sql.exec ( "CREATE TABLE disk_files (" \
        "hd character(2) NOT NULL," \
        "folder text NOT NULL," \
        "file text NOT NULL," \
        "type text NOT NULL," \
        "date timestamp [!x]," \
        "size bigint)" )

    if ( db.dbtype () == ODBC_DB )
        x = "(100)"
    else
        x = ""
    end

    sql.exec ( "CREATE TABLE ext ( ext text [!x] )" )
    sql.exec ( "CREATE INDEX ext_ext ON ext (ext) " )

    sql.exec ( "create table disk_settings ( bt int, label char (10), sel text, usr text, primary key (usr [!x], bt))" )

    sql.exec ( "CREATE INDEX disk_hd_folder ON disk_files (hd, folder [!x], file [!x])" )
    sql.exec ( "CREATE INDEX disk_folder ON disk_files (folder [!x], file [!x])" )
    sql.exec ( "CREATE INDEX disk_file ON disk_files (file [!x])" )
    sql.exec ( "CREATE INDEX disk_type_file ON disk_files (type [!x], file [!x])" )
    sql.exec ( "CREATE INDEX disk_date ON disk_files (date, file [!x],folder [!x] )" )
    sql.exec ( "CREATE INDEX disk_size_file ON disk_files (size, file [!x], folder [!x])" )

    sql.commit ()
end

