


#define DIR_READONLY     0x0001  
#define DIR_HIDDEN       0x0002  
#define DIR_SYSTEM       0x0004  
#define DIR_DIR          0x0010  
#define DIR_ARCHIVE      0x0020  
#define DIR_NORMAL       0x0080  
#define DIR_TEMPORARY    0x0100  
#define DIR_COMPRESSED   0x0800  
#define DIR_ENCRYPTED    0x4000  

query sql

extern func cre_ext ()
extern int Ver

int Trans_len = 20000
int Trans_c

int i
int Mode2
long j
int P
int Dir
char h 100
char h1 300

func start ()
    file_index ( )
end

lfunc file1 ( long j, char search 300, int id, char _file 300, int flag, long _size, char date1 100 )
    onerror 
        terminate ()
    end
    
    long i
    char c 100
    text search1 
    if ( _file == "." || _file == ".." )
        return ( j )
    end

    search1 = right ( search, 2 )
    search1 = left ( search1, len ( search1 ) - 1 )
    search = left ( search, len ( search ) - 1 )
//~ message ( itoa ( _file == "." ) + "!" + search1 + "!" + search + "#" + _file  + "#")

    j += _size
    
    if ( flag & DIR_DIR )
        if ( toupper ( _file ) != "$RECYCLE.BIN" )
            i = file_find ( search + _file + "/*", id + 1, file1 )
            switch ( db.DBTYPE () )
                case POSTGRESQL_DB
                    db.COPYIN ( "[#h]|[#search1]|[#_file]|<DIR>|[date1]|[#i]\n" )
                    break
                case SQLITE_DB
                    db.exec_prep ( h, search1, _file, "<DIR>", date1, i )

                    if ( ++ Trans_c >= Trans_len )
                        sql.commit ()
                        db.prep_end ()
                        sql.begin ()
                        db.prepare ( "insert into disk_files values(?,?,?,?,?,?)" )
                        Trans_c = 0
                    end
                    break
                default
                    sql.insert ( "disk_files values([h],[search1],[_file],'<DIR>',[date1],[i])" )
                    break
            end
            j += i 
            file_index.value ( T2, search + _file ) 
            if ( id < 102 )            
                file_index.value ( P1, ++ Dir )
            end
        end
    else
        if ( strrchr ( _file, '.' ) < 1 )  //a .xxxx || xxxx  file
            c = ""
        else
            //.xxxx.xxx || xxxx.xxx
            c = right ( _file, strrchr ( _file, '.' ) )
            if ( len ( c ) > 20 )  //not a extension, to long
                c = ""
            end
        end
        switch ( db.DBTYPE () )
            case POSTGRESQL_DB
                db.COPYIN ( "[#h]|[#search1]|[#_file]|[#c]|[date1]|[#_size]\n" )
                break
            case SQLITE_DB
                db.exec_prep ( h, search1, _file, c, date1, _size )

                if ( ++ Trans_c >= Trans_len )
                    sql.commit ()
                    db.prep_end ()
                    sql.begin ()
                    db.prepare ( "insert into disk_files values(?,?,?,?,?,?)" )
                    Trans_c = 0
                end
                break
            default
                sql.insert ( "disk_files values([h],[search1],[_file],[c],[date1],[_size])" )
        end
    end

    return ( j )
end

lfunc file ( long j, char search 300, int id, char _file 300, int flag, long _size, char date1 100 )
    onerror 
        terminate ()
    end

    long i

    if ( _file == "." || _file == ".." )
        return ( j )
    end

    search = left ( search, len ( search ) - 1 )

    //put ( 1,  " " + j + "    " + _size + "     " + search + _file + "\n" )
    //h = hex ( flag )

    //~ message ( "[#search] ![#_file]! [#h] [#_size] [#date1] "  )
    
    if ( (flag & DIR_DIR) && (id < 2) )
        if ( toupper ( _file ) != "$RECYCLE.BIN" )

            i = file_find ( j, search + _file + "/*", id + 1, file )
            //put ( 1, " " + i + "  " + "<DIR>    " + search + _file + "\n" ) 
            file_index.value ( T2, search + _file ) 
            j = i + 1
        end
    end

    return ( j )
end

func search ()
    onerror 
        file_index.value ( B1, "Start" )       //when stop
        file_index.clear ( T2 ) 
        switch ( db.DBTYPE () )
            case POSTGRESQL_DB
                db.abortcopy ()
                break
            case SQLITE_DB
                sql.abort ()
                db.prep_end ()
                sql.exec ( "PRAGMA synchronous=normal" )
                sql.exec ( "PRAGMA journal_mode=DELETE" )
                break
        end
    end
    i = 0
    Dir = 0
    file_index.value ( B1, "Stop" )

    while ( i < file_index.GETROWCOUNT ( L1 ) )
        if ( file_index.checked ( L1, i ) )
            Mode2 = 0
            h = file_index.GETITEM ( L1, i, 0 )
            file_index.value ( P1, 0, 0 )
            file_index.value ( P1, 0 )
            h = left ( h, 2)
            if ( h == "" )
                Mode2 = true
                h = left ( file_index.GETITEM ( L1, i, 1 ), 2 )
                if ( file_index.CLR )
                    sql.delete ( "disk_files where hd=[h] and folder='" + subst_all ( right ( file_index.GETITEM ( L1, i, 1 ), 2 ), "\\", "/" )  + "'" )
                end
                j = file_find ( subst_all ( file_index.GETITEM ( L1, i, 1 ), "\\", "/" ) + "/*", 0, file )
            else
                h = subst_all ( h, "\\", "/" ) 
                if ( file_index.CLR )
                    sql.delete ( "disk_files where hd=[h]" )
                end

                j = file_find ( h + "/*", 0, file )
            end
            file_index.value ( P1, 0, j )  //toint

            switch ( db.DBTYPE () )
                case POSTGRESQL_DB
                    if ( Ver < 9 )
                        sql.exec ( "copy disk_files from stdin delimiter '|'" )
                    else
                        sql.exec ( "copy disk_files from stdin delimiter '|'" /* ENCODING 'LATIN1'" */ )
                    end
                    break

                case SQLITE_DB
                    sql.exec ( "PRAGMA synchronous=off" )
                    sql.exec ( "PRAGMA journal_mode=MEMORY" )
                    sql.begin ()
                    db.prepare ( "insert into disk_files values(?,?,?,?,?,?)" )
                    break

                default
                    sql.begin ()
                    break
            end

            Trans_c = 0
            if ( Mode2 )
                j = file_find ( subst_all ( file_index.GETITEM ( L1, i, 1 ), "\\", "/" ) + "/*", 100, file1 )
            else
                j = file_find ( h + "/*", 100, file1 )
            end

            switch ( db.DBTYPE () )
                case POSTGRESQL_DB
                    db.fincopy ( )
                    break
                default
                    sql.commit ()
                    break
                case SQLITE_DB
                    sql.commit ()
                    db.prep_end ()
                    sql.exec ( "PRAGMA synchronous=normal" )
                    sql.exec ( "PRAGMA journal_mode=DELETE" )

                    break
            end

            file_index.check ( L1, i, 0 )
        end
        ++ i
    wend

    file_index.clear ( T2 ) 
    file_index.value ( B1, "Start" )       //when stop
    file_index.value ( P1, 0 )
end

form file_index ()
    layout "Create file index"  sysmenu

 t                                 t
 a                         b      b
                           b      b
                           c      c 

                           d      d
                         a 
 p                                 p
 x                                 x      
    end
    pre
        if ( ! db.connected () )
            if ( db.connect ( "dbname=postgres host=localhost port=5438 user=postgres" ) )
                message ( sql.error () )
                .close ( 0 )
            end
        end

        .EXSTYLE ( L1, LVS_EX_CHECKBOXES | LVS_EX_GRIDLINES )      //checkboxes
        .label ( L1, "Drive|" ) 
        .COLUMNWIDTH ( L1, "50|400" )
        .additemy ( L1, GETDRIVES () )
        .click ( CLR )
    end
    tooltip
        CLR, "Delete's all file-names in the database for the selected drive"
    
field
    on_close 
        if ( .B1 != "Start" )
            message ( "Program is running!" )
            return 0
        end
    end

t: LTEXT "Load database with file-names"
a: L1 LC sort  

b: B1 BT "Start"
    select
        if ( .B1 == "Start" )
            P = process ( search )
        else
            .value ( B1, "Wait" )
            terminate ( P )
            .value ( B1, "Start" )
            file_index.value ( P1, 0 )
            file_index.clear ( T2 ) 

            switch ( db.DBTYPE () )
                case POSTGRESQL_DB
                    db.abortcopy ()
                    break
                case SQLITE_DB
                    sql.abort ()
                    db.prep_end ()
                    sql.exec ( "PRAGMA synchronous=normal" )
                    sql.exec ( "PRAGMA journal_mode=DELETE" )
                    break
            end

        end
    end
b: B2 BT "Subfolder"
    select
        text str
        str = CHOOSE_FOLDER (  )

   		//~ str = load_dlg ( "*.", "", "" )
        if ( str == "" )
            return (0)
        end
        file_index.check ( L1, .additem ( L1, "|[str]" ), 1 )


    end
c: CLR TB "Delete first"
x: T2 LTEXT ""
p: P1 PROGRESS
end

