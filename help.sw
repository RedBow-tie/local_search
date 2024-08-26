
char Cur_sect 30

menu menu1
    menu_item ( M1, "Arkiv", m_submenu )
    //~ menu_item ( M_SQL, "SQL" )
    menu_item ( M_EXIT, "Exit", M_LAST )
end


mtext Init_rich
{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1053{\fonttbl{\f0\froman\fprq2\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue0;}
{\*\generator Riched20 10.0.19041}\viewkind4\uc1 
\pard\cf1\kerning1\f0\fs20\lang1033\par
}
end

mtext rich_fmt
{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1053{\fonttbl{\f0\fnil\fcharset0 Calibri;}}
{\colortbl ;\red0\green0\blue255;\red255\green0\blue0;}
{\*\generator Riched20 10.0.19041}\viewkind4\uc1 
\pard\sl240\slmult1\cf1\f0\fs28\lang29 #a\par
\cf2 \par #b\par
}
end

form comp_help ()
    layout "Compiler help" sysmenu 
e            a                    
 





                   
            e                                              a
a










                                                           a
    end
pre
    int i 

    .menu ( menu1 )
    .COLUMNLABEL ( V_CMD, "Commando||" )
    .columnwidth ( V_CMD, "300|50|50" )
    .COLUMNLABEL ( V_GRP, "Sections" )
    .columnwidth ( V_GRP, "120" )
    .additemy ( V_GRP, "Functions|Form|Triggers|Instructions|Sql|Widgets|Widgets_const|"  \
        "#defines|Keys|Bitmapspar|Color|Manual|Info|Variables|Swec|_Item_var" )
    
    .sendmessage ( V_TXT, EM_SHOWSCROLLBAR, 1, 1 )
    .sendmessage ( V_TXT, EM_SETEVENTMASK, 0, 0x04000000 )  //ENM_LINK 

    .richtext ( V_TXT, Init_rich )
end
field
M_EXIT  
    select
        .close ( 0 ) 
    end


e: V_GRP LC allways
    SELECT_ITEM ( int i )

        if ( i != -1 )
            switch ( Cur_sect = .GETITEM ( V_GRP, i, 0 ) )
                case "Functions"
                    .additemy_clr ( V_CMD, _instructions.func )
                    break
                case "Form"
                    .additemy_clr ( V_CMD, _instructions.form )
                    break
                case "Triggers"
                    .additemy_clr ( V_CMD, _instructions.triggers )
                    break
                case "Instructions"
                    .additemy_clr ( V_CMD, _instructions.instr )
                    break
                case "Sql"
                    .additemy_clr ( V_CMD, _instructions.sql )
                    break
                case "Widgets"
                    .additemy_clr ( V_CMD, _instructions.widgets )
                    break
                case "Widgets_const"
                    .additemy_clr ( V_CMD, _instructions.widget_const )
                    break
                case "#defines"
                    .additemy_clr ( V_CMD, _instructions.const )
                    break
                case "Keys"
                    .additemy_clr ( V_CMD, _instructions.keys )
                    break
                case "Bitmapspar"
                    .additemy_clr ( V_CMD, _instructions.color1 )
                    break
                case "Color"
                    .additemy_clr ( V_CMD, _instructions.color2 )
                    break
                case "Variables"
                    .additemy_clr ( V_CMD, _instructions.Variables )
                    break
                case "Swec"
                    .additemy_clr ( V_CMD, _instructions.Swec )
                    break
                case "_Item_var"
                    .additemy_clr ( V_CMD, _instructions._item_var )
                    break

                default
                    .DELALLITEM ( V_CMD )
            end
        else
            Cur_sect = ""
            .delallitem ( V_CMD )
        end
    end

a: V_CMD LC allways
    SELECT_ITEM ( int i )
        text slask
        text fmt

        switch ( Cur_sect )
            case "Functions"
                slask = _instructions.func [ .getitem ( V_CMD, i, 0 )] 
                break
            case "Form"
                slask = _instructions.form [ .getitem ( V_CMD, i, 0 )] 
                break
            case "Triggers"
                slask = _instructions.triggers [ .getitem ( V_CMD, i, 0 )] 
                break
            case "Instructions"
                slask = _instructions.instr [ .getitem ( V_CMD, i, 0 )] 
                break
            case "Sql"
                slask = _instructions.sql [ .getitem ( V_CMD, i, 0 )] 
                break
            case "Widgets"
                slask = _instructions.widgets [ .getitem ( V_CMD, i, 0 )] 
                break
            case "Widgets_const"
                slask = _instructions.widget_const [ .getitem ( V_CMD, i, 0 )] 
                break
            case "#defines"
                slask = _instructions.const [ .getitem ( V_CMD, i, 0 )] 
                break
            case "Keys"
                slask = _instructions.keys [ .getitem ( V_CMD, i, 0 )] 
                break
            case "Bitmapspar"
                slask = _instructions.color1 [ .getitem ( V_CMD, i, 0 )] 
                break
            case "Color"
                slask = _instructions.color2 [ .getitem ( V_CMD, i, 0 )] 
                break
            default
                slask = ""
                break

        end

        slask = subst_all ( slask, "|", "\\par " )
        fmt = subst ( rich_fmt, "#a", slask )
        fmt = subst ( fmt, "#b", "" )
        .richtext ( V_TXT, fmt )
        return        
    end
    
a: V_TXT richedit readonly  //Shorthand RE
end

