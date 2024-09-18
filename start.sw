

//CREATE DATABASE test ENCODING ’WIN1252’ template template0;


char Edit = "c:\\scilla\\scite.exe"

extern form comp_help () load ( "help" )
extern form login () load ( "lf_login" )
extern form login1 () load ( "lf_login" )
extern form file_index () load ( "file_index" )
extern form x_sql () load ( "sql" )
 
int Ver  

bitmap up size(11, 11) bcolor = white  
....b...
........
....z...  
........
a.......c.  
........
........
........
........
........
........
end
abca: line red
z: fill red
end

bitmap24 dn size(11, 11)  bcolor = white
........
........
........
........
........
........
a.......c.
........
....z...
........
....b....
end
abca: line red
z: fill red
end

bitmap24 white size(11, 11)  bcolor = white
........
........
........
........
........
........
........
........
end
end


IMAGELIST b1
white 
up
dn
end


query sql, sqlny
query sql1, sql2
int Col
int Up 
int Z
int i
Long Max
int Page
int Page_s
char Order 50
char Find_ext 40
char Userlang 10
text Ext
text Ext2
text Se, Folder

func main ()

    if ( init_maria ( "libmariadb.dll" ) )
        info ( "Can't load MariaDB/MySQL dll file" )
    end

    local_file ()
end

menu m1
    menu_item ( M1, "File", m_submenu )
    menu_item ( M_EXT, "Recreate ext table" )
    menu_item ( M_CRE, "Read filenames" )
    menu_item ( M_DEL, "Clear table", m_separator )
    menu_item ( M_DROP, "Drop tables" )
    menu_item ( M_LOGIN, "Login", m_separator )
    menu_item ( M_SQL, "SQL", m_separator )
    menu_item ( M_EXIT, "Exit", m_last | m_separator )

    menu_item ( M2, "Debug", m_submenu )
    menu_item ( M_DEBUG, "Show SQL", m_last )

    menu_item ( M2, "Help", m_submenu )
    menu_item ( M_COMPILER, "Compiler" )
    menu_item ( M_ABOUT, "About", m_last )

end


menu List_menu
    menu_item ( EDIT_FILE, "Edit" )
    menu_item ( OPEN_FOLDER, "Open folder" )
    menu_item ( DEL_FILE, "Delete line" )
    menu_item ( DEL_FOLDER, "Delete folder" )
end

form local_file ()
    layout   sysmenu minibox resize y2 + 14

 e                                                                                          e                                                                                           
 a                                                           













               
                                                                                            a 
 t  tp         pt  tq       qt   te                          eb      bb    bb     bx xt     t
    end 
    pre
        .menu ( m1 )
        Userlang = subst_all ( locallang (), "-", "_" )  //MariaDb uses _ insted of -
        if ( ! db.connected () )
            i = login ()

            if ( i )
                .close ( 0 )
                return ( 0 )
            end
            sql.exec_noerr ( "select * from disk_files limit 1" )
            if ( sql.rows () == 0)
                i = 3
            end
            //~ db.ERRORVERBOSITY ( 2 )
        end
        .title ( "Local files (" + db.DBTYPES () + ")" )

        switch ( db.dbtype () )
            case MARIA_DB
            case ODBC_DB
            case SQLITE_DB
                sql.exec ( "select hd,folder,file,type,date,size from disk_files  limit 1" )
                break
            default
                sql.exec ( "select hd,folder,file,type,date,to_char(size, '999 999 999 999 999') from disk_files  limit 1" )
        end

        change_sort ( 2, 0 )
        if ( i == 3 )
            file_index ()       //read disk files 
            cre_ext ();
        end
        .timer ( 1, 40 )   //show mainframe first
    end
    tooltip
        SE, "Search File/Folder/Folder+File\n\n" +
            "File:  *filename* \nFolder:  /*folder*\nFolder+File:  /*folder*|*file*"
    
field
    //Stop debug window for overlapping
    ON_ACTIVE
        .topwin ()
    end
    ON_DEACTIVE
        .bottomwin ()
    end

on_timer ( int i )
    onerror 
        sql.abort ()
    end

    .timer ( 1, 0 )
    .WAITCURSOR ( 1 )
    .imagelist ( L1, b1 )   

    sql.select ( "* from disk_files limit 1" )
    .columnlabel ( L1, sql )
    .right ( L1, 5 )
    .COLUMNWIDTH ( L1, "40|240|250|50|130|130" )
    .additem_clr ( C1, "1000|2000|5000|10000|20000|100000|ALL" )
    .value ( C1, "2000" )
    Page_s = 2000
    Page = 1
    Up = 0
    Col = 2
    .image ( L1, Col, 1 )
    disp ( 2 )
end 
M_ABOUT
    select
        info ( "Local Search Ver 1.0" )
    end
M_COMPILER
    select
        comp_help ()
    end
M_DEBUG
    select
        if ( .checked ( M_DEBUG ) )
            .check ( M_DEBUG, 0 )
            _debug_win ( 0 )
        else 
            .check ( M_DEBUG, 1 )
        end
        trace_db ( .checked ( M_DEBUG ) )
    end
M_EXT
    select
        if ( ask ( "Recreate ext table ?" ) )
            cre_ext ();
        end    
    end
EDIT_FILE
    select
//i is set in RIGHT_CLICK
        text slask

        if ( i == -1 )
            return
        end
        if ( .getitem ( L1, i, 3 ) == "<DIR>" )
            info ( "Can't edit a folder" )
        else

            SHELLEXECUTE ( Edit, .getitem ( L1, i, 2 ), SUBST_ALL ( .getitem ( L1, i, 0 ) + .getitem ( L1, i, 1 ), "/", "\\" ) ) 
        end
    end
OPEN_FOLDER
    select
        text slask
        
        slask = .getitem ( L1, i, 0 ) + .getitem ( L1, i, 1 )
        if ( .getitem ( L1, i, 3 ) == "<DIR>" )
            slask = slask + .getitem ( L1, i, 2 )
        end
        slask = SUBST_ALL ( slask, "/", "\\" )
        explore ( slask )
    end
DEL_FILE
    select
        if ( ask ( "Delete " + .getitem ( L1, i, 0 ) + .getitem ( L1, i, 1 ) + .getitem ( L1, i, 2 ) + " (Only in the database) ?") )
            Se = "disk_files where Hd ='" + .getitem ( L1, i, 0 ) + "' and Folder='" + .getitem ( L1, i, 1 ) + "' and File='"  + .getitem ( L1, i, 2 ) + "'"
            sql.abort ()
            sql1.delete ( Se )
            .DELITEM ( L1, i )
        end
    end
DEL_FOLDER
    select
        if ( .getitem ( L1, i, 3 ) == "<DIR>" )
            if ( ask ( "Delete the folder " + .getitem ( L1, i, 0 ) + .getitem ( L1, i, 1 ) + .getitem ( L1, i, 2 ) + " (Only in the database) ?") )
                Se = "disk_files where Hd ='" + .getitem ( L1, i, 0 ) + "' and Folder='" + .getitem ( L1, i, 1 ) + .getitem ( L1, i, 2 ) + "/'"  
                sql.abort ()
                sql1.delete ( Se )
                sql1.delete ( "disk_files where Hd ='" + .getitem ( L1, i, 0 ) + "' and Folder='" + .getitem ( L1, i, 1 ) + "' and File='" + .getitem ( L1, i, 2 ) + "'"  )
                disp ( 2 )
            end
        else 
            if ( ask ( "Delete the folder " + .getitem ( L1, i, 0 ) + .getitem ( L1, i, 1 ) + " (Only in the database) ?") )
                Se = "disk_files where Hd ='" + .getitem ( L1, i, 0 ) + "' and Folder='" + .getitem ( L1, i, 1 ) + "'"  

                sql.abort ()
                sql1.delete ( Se )
                disp ( 2 )
            end
        end
    end

M_LOGIN
    select
        login1 ()
        .pre ()
    end
M_DEL
    select
        if ( ask ( "Clear file table ?" ) )
            .WAITCURSOR ( 1 )
            if ( db.dbtype () == POSTGRESQL_DB )
                sql.exec_noerr ( "abort" )
            end
            sql.delete ( "disk_files" )
            disp ( 2 )
        end
    end
M_DROP
    select
        if ( ask ( "Remove file tables ?" ) )
            .WAITCURSOR ( 1 )
            if ( db.dbtype () == POSTGRESQL_DB )
                sql.exec_noerr ( "abort" )
            end
            sql.exec ( "drop table if exists disk_files, ext, disk_settings" )
            db.disconnect () 
            .pre ()
        end
    end
M_SQL
    select
        x_sql()
        switch ( db.dbtype () )
            case POSTGRESQL_DB
                disp ( 2 )   // x_sql is closing the cursor, reopen
                break
        end        
    end
M_EXIT
    select
        .timer ( 2, 0 )
        .close ( 0 )
    end
M_CRE
    select
        .waitcursor (1)
        if ( db.dbtype () == POSTGRESQL_DB )
            sql.commit ()
        end
        file_index ()
        if ( ask ( "Update extensions table ?" ) == IDYES )
            cre_ext ()
        end

        .timer ( 1, 1 )
    end
e: E1 RICHEDIT multi y2 + 10 y1 - 10, a_right
a: L1 LC singel , a_right a_bottom
    select_item ( int i )
        if ( i != -1 )
            .value ( E1, subst_all ( .getitem ( L1, i, 0 ) + .getitem ( L1, i, 1 )  + .getitem ( L1, i, 2 ), "/", "\\" ) )
        else
            .clear ( E1 )
        end
    end
    dbl_click ( int i )
        text slask 

        if ( i != -1 )
            if ( .getitem ( L1, i, 3 ) == "<DIR>" )
                Folder = " folder like '" + .getitem ( L1, i, 1 ) + .getitem ( L1, i, 2 ) + "/%" + "'" 
                Ext = ""
                change_sort ( 1, 1 )
                disp ( 2 )
            else 
                slask = .getitem ( L1, i, 0 ) + .getitem ( L1, i, 1 ) + .getitem ( L1, i, 2 )
                slask = SUBST_ALL ( slask, "/", "\\" )

                SHELLEXECUTE ( slask, SUBST_ALL ( .getitem ( L1, i, 0 ) + .getitem ( L1, i, 1 ), "/", "\\" ) ) 
            end
        end
    end
    column_click ( int i )
        change_sort ( i, 0 )
        disp ( 1 )
    end
    KEY_DEL
        i = .SELECTED ( L1 )
        if ( i != -1 )
            if ( ask ( "Delete " + .getitem ( L1, i, 0 ) + .getitem ( L1, i, 1 ) + .getitem ( L1, i, 2 ) + " (Only in the database) ?") )
                Se = "disk_files where Hd ='" + .getitem ( L1, i, 0 ) + "' and Folder='" + .getitem ( L1, i, 1 ) + "' and File='"  + .getitem ( L1, i, 2 ) + "'"
                sql1.delete ( Se )
            end
        end
    end
    RIGHT_CLICK
        i = .SELECTED ( L1 )
        if ( i != -1 )
            .POPUP_MENU ( List_menu )
        end
    end


t: T1 lTEXT "Show", a_ymove
p: C1 CB, a_ymove 
    value_change
        if ( .value ( C1 ) == "ALL" )
            Page_s = 0
        else
            Page_s = atoi ( .value ( C1 ) )
        end
        set_page ()
        disp ( 0 )
    end
t: T2 ltext "Page", a_ymove
q: C2 CB, a_ymove 
    value_change 
        Page = atoi ( .value ( C2 ) )
        .value ( U1, Page )
        set_page ()
        disp ( 0 )
    end
?: U1 updown right autolink, a_ymove
    SPIN_CHANGE ( int i )
        Page = atoi ( .value ( U1 ) ) + i
        disp ( 0 )
    end
t: T3 ltext "Search", a_ymove
e: SE EDIT, a_ymove a_right
    KEY_RETURN
        .click ( B_SEARCH )
    end
b: B_SEARCH BT "Search", a_move
    select
        Page = 1
        .value ( C2, "1" )
        .value ( U1, Page - 1 )
        Folder = ""
        disp ( 1 )
    end
b: BT "Type", a_move
    select
        sel_ext ()
        disp ( 1 )
    end
b: BT "Page 1", a_move
    select
        Page = 1
        .value ( C2, "1" )
        .value ( U1, Page - 1 )
        Ext = ""
        Folder = ""
        disp ( 1 )
    end
x: T4 lTEXT "Files", a_move
t: TOT EDIT disabled right, a_move
end

func disp ( int new ) 
    switch ( db.dbtype () )
        case POSTGRESQL_DB 
            if ( Ver >= 9 )
                disp2 ( new )
            else
                disp_old ( new )
            end
            break
        
        case MARIA_DB
        case ODBC_DB
            disp_maria ( new )
            break
        default
            disp_lite ( new )
    end
end

func change_sort ( int i, int find_mode )
    char d 10

    if ( i == Col  && ! find_mode )
        Up = ! Up
        local_file.image ( L1, Col, 1 + Up )
    end

   local_file.image ( L1, Col, -1 )
   local_file.image ( L1, i, 1 + Up )
    Col = i
    if ( Up )
        d = "DESC" 
    else 
        d = " "
    end

    switch ( i )
        case 0
            Order = "hd [#d],folder [#d],file [#d]"
            break
        case 1
            Order = "folder [#d],file [#d]"
            break
        case 2
            Order = "file [#d]"
            break
        case 3
            Order = "type [#d],file [#d]"
            break
        case 4
            Order = "date [#d],file [#d],folder [#d]"
            break
        case 5
            Order = "size [#d],file [#d],folder [#d]"
            break            
    end
end

func disp_ny ( int new ) 
    int o
    int z
    text w

    onerror 
        //~ sqlny.noblock ( 0 )
        //~ sql.noblock ( 0 )
        sql.abort ()
    end

    local_file.WAITCURSOR ( 1 )
    if ( new > 0 )
        sql.commit ()
        sql.begin ()
        //~ sqlny.commit ()
        //~ sqlny.begin ()

        //~ sqlny.noblock ( 1 )
        //~ sql.noblock ( 1 )

        if ( Ext == "" && trim ( local_file.SE ) == ""  && Folder == "")    
            if ( new == 2 )
                sql1.select ( "count(0) from disk_files" )
            end
            if ( Folder != "" )
                change_sort ( 1, 1 )
                w = " where [+Folder] "
            end
            switch ( db.dbtype () )
                case SQLITE_DB
                    sql.exec ( "declare dc cursor for select hd,folder,file,type,date,size from disk_files [+w] order by [!Order]" )
                    break
                default
                    sql.exec ( "declare dc cursor for select hd,folder,file,type,date,to_char(size, '999 999 999 999 999') from disk_files [+w] order by [!Order]" )
            end

        else
            Se = subst_all ( local_file.SE, "*", "%" )
            if ( left ( local_file.SE, 1 ) == "/" )
                Folder = " folder like \'" + Se + "\'" 
                change_sort ( 1, 1 )
            else
                if ( trim ( local_file.SE ) != "" )
                    Folder = " file like [Se] "
                    change_sort ( 2, 1 )
                end
            end

            if ( Ext != "" || Folder != "" )
                w = " where " + ( Ext != "" ? "type = ANY ('{[+Ext]}')" ) + ( Ext != "" &&  Folder != "" ? " and " ) + Folder 
            end

            if ( new == 2 )
                sql1.select ( "count(0) from disk_files [+w] " )
            end
            switch ( db.dbtype () )
                case SQLITE_DB
                    sql.exec ( "declare dc cursor for select hd,folder,file,type,date,size from disk_files [+w] order by [!Order]" )
                    break
                default
                    sql.exec ( "declare dc cursor for select hd,folder,file,type,date,to_char(size, '999 999 999 999 999') from disk_files [+w] order by [!Order]" )
            end
        end

        Max = atoi ( sql1.result ( 0, 0 ) )
        local_file.value ( TOT, dtoa ( Max, 0 ) )
        set_page ()
    end
    local_file.value ( C2, Page - 1 )
    z = (Page - 1) * Page_s
    if ( Page_s == 0 )
        sql.exec ( "fetch all dc" )
    else

        int j, k

        j = Page_s / 2 
        k = j + z 

/*  a test of the non blocking interface

mess ( sql.isbusy () + sqlny.isbusy () )

        while ( sql.isbusy () || sqlny.isbusy () )
            sleep ( 200 )
        wend
        sql.CONSUME ()
        //~ sqlny.CONSUME ()
mess ( sql.isbusy () + sqlny.isbusy () )

        //~ sqlny.noblock ( 0 )
        sql.noblock ( 0 )
        //~ sqlny.noblock ( 1 )
        sql.noblock ( 1 )
*/

        sql.exec ( "move absolute [#z] dc" )
        sql.exec ( "fetch forward [#j] dc" )
    end
end


func disp2 ( int new ) 
    int o
    int z
    text w

    onerror 
        sql.abort ()
    end

    local_file.WAITCURSOR ( 1 )
    if ( new > 0 )
        sql.commit ()
        sql.begin ()
        if ( Ext == "" && trim ( local_file.SE ) == ""  )    
            if ( new == 2 )
                sql1.select ( "count(0) from disk_files" )
            end
            if ( Folder != "" )
                change_sort ( 1, 1 )
                w = " where [+Folder] "
            end
            sql.exec ( "declare dc cursor for select hd,folder,file,type,date,to_char(size, '999 999 999 999 999') from disk_files [+w] order by [!Order]" )
        else
            Se = subst_all ( local_file.SE, "*", "%" )
            if ( left ( local_file.SE, 1 ) == "/" )
                Folder = " folder like \'" + substr ( Se, 0, "|" ) + "\'" 
                change_sort ( 1, 1 )
                Se = substr ( Se, 1, "|" )
                if ( Se != "" )
                    Folder += " and file like [Se] "
                end
            else
                if ( trim ( local_file.SE ) != "" )
                    Folder = " file like [Se] "
                    change_sort ( 2, 1 )
                end
            end

            if ( Ext != "" || Folder != "" )
                w = " where " + ( Ext != "" ? "type = ANY ('{[+Ext]}')" ) + ( Ext != "" &&  Folder != "" ? " and " ) + Folder 
            end

            if ( new == 2 )
                sql1.select ( "count(0) from disk_files [+w] " )
            end
            sql.exec ( "declare dc cursor for select hd,folder,file,type,date,to_char(size, '999 999 999 999 999') from disk_files [+w] order by [!Order]" )
        end

        Max = atoi ( sql1.result ( 0, 0 ) )
        local_file.value ( TOT, dtoa ( Max, 0 ) )
        set_page ()
    end
    local_file.value ( C2, Page - 1 )
    z = (Page - 1) * Page_s
    if ( Page_s == 0 )
        sql.exec ( "fetch all dc" )
    else
        sql.exec ( "move absolute [#z] dc" )
        sql.exec ( "fetch forward [#Page_s] dc" )
    end
    local_file.additem_clr ( L1, sql )
    local_file.right ( L1, 5 )
end

func disp_old ( int new ) 
    int o
    int z
    text w=""

    onerror 
        sql.abort ()
    end

    local_file.value ( C2, Page - 1 )
    z = (Page - 1) * Page_s
    //++ z

    local_file.WAITCURSOR ( 1 )
    if ( Ext == "" && trim ( local_file.SE ) == "" )    
        if ( new == 2 )
            sql1.select ( "count(0) from disk_files" )
        end
        if ( Folder != "" )
            change_sort ( 1, 1 )
            w = " where [+Folder] "
        end
        switch ( db.dbtype () )
            case SQLITE_DB
                sql.exec ( "select hd,folder,file,type,date,size from disk_files [+w] order by [!Order] offset [#z] limit [#Page_s]" )
                break
            default
                sql.exec ( "select hd,folder,file,type,date,to_char(size, '999 999 999 999 999') from disk_files [+w] order by [!Order] offset [#z] limit [#Page_s]" )
        end
    else
        Se = subst_all ( local_file.SE, "*", "%" )
        if ( left ( local_file.SE, 1 ) == "/" )
            Folder = " folder like \'" + Se + "\'" 
            change_sort ( 1, 1 )
        else
            if ( trim ( local_file.SE ) != "" )
                Folder = " file like [Se] "
                change_sort ( 2, 1 )
            end
        end

        if ( Ext != "" || Folder != "" )
            w = " where " + ( Ext != "" ? "type = ANY ('{[!Ext]}')" ) + ( Ext != "" &&  Folder != "" ? " and " ) + Folder 
        end

        if ( new == 2 )
            sql1.select ( "count(0) from disk_files [+w] ')" )
        end
        if ( Page_s == 0 )
            switch ( db.dbtype () )
                case SQLITE_DB
                    sql.exec ( "select hd,folder,file,type,date,to_char(size, '999 999 999 999 999') from disk_files [+w] order by [!Order]" )
                    break
                default
                    sql.exec ( "select hd,folder,file,type,date,to_char(size, '999 999 999 999 999') from disk_files [+w] order by [!Order]" )
            end
        else
            switch ( db.dbtype () )
                case SQLITE_DB
                    sql.exec ( "select hd,folder,file,type,date,size from disk_files [+w] order by [!Order] offset [#z] limit [#Page_s]" )
                    break
                default
                    sql.exec ( "select hd,folder,file,type,date,to_char(size, '999 999 999 999 999') from disk_files [+w] order by [!Order] offset [#z] limit [#Page_s]" )
            end
        end
    end

    Max = atol ( sql1.result ( 0, 0 ) )
    local_file.value ( TOT, dtoa_eng ( Max, 0 ) )
    set_page ()

    local_file.additem_clr ( L1, sql )
    local_file.right ( L1, 5 )

end

func disp_lite ( int new ) 
    int o
    int z, l
    text w

    onerror 
    end

    local_file.WAITCURSOR ( 1 )

    local_file.value ( C2, Page - 1 )
    z = (Page - 1) * Page_s
    //++ z

    if ( Page_s == 0 )
        z = 0
        l = 0x7fffffff
    else
        l = Page_s
    end

    if ( Ext == "" && trim ( local_file.SE ) == ""  && Folder == "" )    
        if ( new == 2 )
            sql1.select ( "count(0) from disk_files" )
        end
        sql.select ( "hd,folder,file,type,date,format('%?i',size) from disk_files order by [!Order] limit [#l] offset [#z]" )
    else
        Se = subst_all ( local_file.SE, "*", "%" )
        if ( left ( local_file.SE, 1 ) == "/" )
            Folder = " folder like \'" + substr ( Se, 0, "|" ) + "\'" 
            change_sort ( 1, 1 )
            Se = substr ( Se, 1, "|" )
            if ( Se != "" )
                Folder += " and file like [Se] "
            end
        else
            if ( trim ( local_file.SE ) != "" )
                Folder = " file like [Se] "
                change_sort ( 2, 1 )
            end
        end

        if ( Ext != "" || Folder != "" )
            w = " where " + ( Ext != "" ? "type in ([+Ext])" ) + ( Ext != "" &&  Folder != "" ? " and " ) + Folder 
        end

        if ( new == 2 )
            sql1.select ( "count(0) from disk_files [+w] " )
        end
        sql.exec ( "select hd,folder,file,type,date,format('%?i',size) from disk_files [+w] order by [!Order] limit [#l] offset [#z]" )
    end

    Max = atol ( sql1.result ( 0, 0 ) )
    local_file.value ( TOT, dtoa_eng ( Max, 0 ) )
    set_page ()

    local_file.additem_clr ( L1, sql )
    local_file.right ( L1, 5 )
end

func disp_maria ( int new ) 
    int o
    int z, l
    text w

    onerror 
    end

    local_file.WAITCURSOR ( 1 )

    set_page ()

    local_file.value ( C2, Page - 1 )
    z = (Page - 1) * Page_s
    //++ z

    if ( Page_s == 0 )
        z = 0
        l = 0x7fffffff
    else
        l = Page_s
    end

    if ( Ext == "" && trim ( local_file.SE ) == "" )    
        if ( new == 2 )
            sql1.select ( "count(0) from disk_files" )
        end
       if ( Folder != "" )
            change_sort ( 1, 1 )
            w = " where [+Folder] "
        end

        sql.select ( "hd,folder,file,type,date,format(size,0,[Userlang]) from disk_files [+w] order by [!Order] limit [#l] offset [#z]" )
    else
        Se = subst_all ( local_file.SE, "*", "%" )
        if ( left ( local_file.SE, 1 ) == "/" )
            Folder = " folder like \'" + substr ( Se, 0, "|" ) + "\'" 
            change_sort ( 1, 1 )
            Se = substr ( Se, 1, "|" )
            if ( Se != "" )
                Folder += " and file like [Se] "
            end
        else
            if ( trim ( local_file.SE ) != "" )
                Folder = " file like [Se] "
                change_sort ( 2, 1 )
            end
        end

        if ( Ext != "" || Folder != "" )
            w = " where " + ( Ext != "" ? " type IN ([+Ext])" ) + ( Ext != "" &&  Folder != "" ? " and " ) + Folder 
        end

        if ( new == 2 )
            sql1.select ( "count(0) from disk_files [+w] " )
        end

        sql.select ( "hd,folder,file,type,date,format(size,0,[Userlang]) from disk_files [+w] order by [!Order] limit [#l] offset [#z]" )
    end

    Max = atol ( sql1.result ( 0, 0 ) )
    local_file.value ( TOT, dtoa_eng ( Max, 0 ) )

    local_file.additem_clr ( L1, sql )
    local_file.right ( L1, 5 )
end



form sel_ext ()
    char u 100

    layout "Select file extension" sysmenu ystep + 3
 
 a                               b      b
                                 b      b   
                                 b      b               
                                 b      b   
                                 b      b   
                                 b      b

                                 b      b   
                                 b      b               
                                 b      b   
                                 b      b   
                                 b      b
                                 b      b                           




                                a
    end

    pre
        onerror 
            .close ( 1 )
        end
        .EXSTYLE ( L1, LVS_EX_CHECKBOXES | LVS_EX_GRIDLINES )      //checkboxes

        u = getusername ()


        sql.select ( "* from ext" )  //"distinct type from disk_files where type != '' order by type  " )
        sql2.select ( "* from disk_settings where usr =[u]" )
/*
        foreach ( sql2 )
            .value ( B_SAVE1 + atoi(sql2.bt), sql2.label ) 
        end
*/
        .additem_clr ( L1, sql )

        Z = 0
        Ext2 = substr ( Ext, 0, "," )
        while ( Ext2 != NULL && Ext2 != "" )
            .check_q ( L1, Ext2, 1 )
            ++ Z
            Ext2 = substr ( Ext, Z, "," )
        wend
    end
field
    on_timer ( int i )
        .timer ( 1, 0 )
        .check ( L1, 0, 0 )
        .check ( L1, 1, 0 )
        .check ( L1, 2, 0 )
    end
    
a: L1 LCB
b: BT "OK"
    select
        i = 0
        Ext = ""
        Z = .GETFIRSTCHECK ( L1 )
        while ( Z != -1 )
            if ( i )
                Ext += ","
            end
            switch ( db.DBTYPE () )
                case POSTGRESQL_DB
                    Ext += .getitem ( L1, Z, 0 ) 
                    break
                default
                    Ext += "'" + .getitem ( L1, Z, 0 ) + "\'"  
            end
            Z = .GETNEXTCHECK ( L1 )
            i = true
        wend
        .close ( 0 ) 
    end
b: BT "All"
    select
        i = 0 
        Z = .GETROWCOUNT ( L1 )
        .check ( L1, i, 0 )
        while ( i <= Z )
            .check ( L1, i, 1 )
            ++ i
        wend
    end
b: BT "None"
    select
        i = .GETFIRSTCHECK ( L1 )
        while ( i != -1 )
            .check ( L1, i, 0 )
            i = .GETNEXTCHECK ( L1 )
        wend
    end
b: BT "C/CPP/H" 
    select

        .check_qc ( L1, ".C", 1 )
        .check_qc ( L1, ".c", 1 )
        .check_qc ( L1, ".cc", 1 )
        .check_qc ( L1, ".CC", 1 )
        .check_qc ( L1, ".H", 1 )
        .check_qc ( L1, ".h", 1 )
        .check_qc ( L1, ".CPP", 1 )
        .check_qc ( L1, ".cpp", 1 )
        .check_qc ( L1, ".CX", 1 )
        .check_qc ( L1, ".cx", 1 )
        .check_qc ( L1, ".CXX", 1 )
        .check_qc ( L1, ".cxx", 1 )
    end
b: BT "Search"
    select
        if ( find () == 1 )
            if ( .finditem ( L1, Find_ext ) == -1 )
                message ( "Can't find the string!" )
            end
        end
    end
b: BT "Marked"
    select
        if ( i == -1 )
            i = .GETFIRSTCHECK ( L1 )
        else
            i = .GETNEXTCHECK ( L1 )
        end
        if ( i >= 0 )
            .SENDMESSAGE ( L1, 0x1000 + 19, i, 0 )   //LVM_ENSUREVISIBLE 
            .SELECT_ITEM ( L1, i )
        end
    end
//--------------
#if 0
b: B_SAVE1 BT "Select 1"
    select
        foreach ( sql2 )
            if ( sql2.bt == "0" )
                mess ( "oj" )
                break
            end
        end
    end
b: B_SAVE2 BT "Select 2"
    select
    end
b: B_SAVE3 BT "Select 3"
    select
        foreach ( sql2 )
            if ( sql2.bt == "2" )
                mess ( "oj" )
                break
            end
        end
    end
b: B_SAVE4 BT "Select 4"
    select
    end
b: B_SAVE5 BT "Select 5"
    select
    end
b: BT "Save"
    select
        save_bt ()
    end
#endif
end

form save_bt ()
    layout "Save selection" sysmenu

 a     aa       a  c      c      
 b     bb       b

end
pre
#if 0
    for ( i = 0; i < 5; ++ i )
        .additem_nodel ( SEL_BT, sel_ext.value ( B_SAVE1 + i ) )
    end
#endif
end
field
a: "Button"
a: SEL_BT CB
    value_change ( int i )
        .value ( E1, .value ( SEL_BT ) )
    end
b: "Label"
b: E1 EDIT 
c: BT "Save"
    select
        text slask
        Z = .GETFIRSTCHECK ( L1 )
        i = 0
        while ( Z != -1 )
            if ( i )
                slask += "|"
            end
            slask += sel_ext.getitem ( L1, Z, 0 ) 
            Z = .GETNEXTCHECK ( L1 )
            i = true
        wend

        i = .GETFIRSTSEL(SEL_BT)

        sql2.abort ()
        sql2.begin ()
        sql.delete ( "file_settings where usr=[sel_ext.u] and bt=[i]" )
        sql2.insert ( "file_settings values ( [i],[.E1],[slask],[sel_ext.u] )" )
        sql2.commit ()
        sql2.select ( "* from disk_settings where usr =[sel_ext.u]" )
    end
end


form find () 
    layout "Find ext" sysmenu
 a                     a b      b
    end
field
a: E1 EDIT
    leave
        Find_ext = .E1
    end
b: BT "Ok"
    select
        .close ( 1 )
    end
end

func set_page ()
    int i
    int j

    if ( Page_s == 0 )
        local_file.disable ( C2 )
        local_file.disable ( U1 )
        return 0
    end
    local_file.enable ( C2 )
    local_file.enable ( U1 )
    i = Max / Page_s + 1 
    local_file.additem_clr ( C2, "1" )
    for ( j = 2; j <= i; ++ j )
        local_file.additem ( C2, itoa (j) )
    end
    if ( Page > i || Page < 1 )
        Page = 1
    end
    local_file.value ( U1, 1, i )
    local_file.value ( U1, Page - 1 )

    local_file.value ( C2, itoa ( Page ) )     
end

func cre_df ()
    onerror sql.abort ()    

    sql.begin ()
    sql.exec ( "CREATE TABLE disk_files (" \
        "hd character(2) NOT NULL," \
        "folder text NOT NULL," \
        "file text NOT NULL," \
        "type text NOT NULL," \
        "date timestamp without time zone," \
        "size bigint)" )

    sql.exec ( "CREATE INDEX date_hd" \
        " ON disk_files " \
        "(date, hd, folder," \
        "file, type)" )


    sql.exec ( "CREATE INDEX folder ON disk_files " \
        "(hd, folder, " \
        "file, type)" )

    sql.exec ( "CREATE INDEX size_file ON disk_files" \
        "(size, file, type)" )

    sql.exec ( "CREATE INDEX file_type ON disk_files (file, type)" )

    sql.commit ()
end

func cre_ext ()
    local_file.WAITCURSOR ( 1 )

    sql.delete ( "ext" )
    switch ( db.dbtype () )
        case SQLITE_DB
            sql.insert ( "ext (ext)  select distinct type from disk_files where type != '' order by type" )
            break
        default
            sql.insert ( "ext (ext) (select distinct type from disk_files where type != '' order by type )" )
    end
end

/*

!lang! @ - change the text from a "lang" section               
!SEMI!  ; - unpack a | sep sträng
!STR! # - str as number,  empty str = 0
!NUM! ! - str as number, empty str don't change 
!DATE! $ - empty str as null like date
!NULL!  £ - empty str as null other as number
!NOESC! + - as ! but doesn't use PQescapeString
 = - field='as value'  ???
 =# -  dito as numbers 
*/
