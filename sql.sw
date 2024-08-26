
query sql
int table_mode, i

extern form db_con() load ( "db_con" )

func main ()
	REG_SECTION ( "SOFTWARE\\swec\\apps" )

	db_con ()
	x_sql ()
end




form x_sql (),default_cr
    layout "Execute SQL" sysmenu resize
 a                                                                           
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                            a
 b                                                                  c       c
                                                                           
                                                                    c       c  
                                                                    c       c          
                                                                    c       c  
                                                                             
                                                                b            
end
    pre
		table_mode = 0
		switch ( db.dbtype () )
			case POSTGRESQL_DB
				sql.abort ()
				break
		end
    end
field
a: L1 LC, A_RIGHT A_BOTTOM  
b: E1 RE, A_YMOVE A_RIGHT
c: B1 BT  "Execute", A_YMOVE A_XMOVE
	select
		.WAITCURSOR ( 1 )
		table_mode = 0
        sql.exec ( x_sql.E1 )
		.label (L1, sql )
		.additem ( L1, sql )
	end
c: B2 BT "Show tables", A_YMOVE A_XMOVE
	select
		switch ( db.dbtype () )
			case POSTGRESQL_DB
				table_mode = true
				sql.exec ( "SELECT * from pg_catalog.pg_tables where schemaname='public'" )
				.label (L1, sql )
				.columnwidth ( L1, "50|130|100|1500" )
				.additem_clr ( L1, sql )	
				break
			case SQLITE_DB
				sql.exec ( "SELECT type,name,tbl_name,sql FROM sqlite_schema" )
				.label (L1, sql )
				.columnwidth ( L1, "50|130|100|1500" )
				.additem_clr ( L1, sql )	
				break;
			case ODBC_DB
				table_mode = true
				sql.TABLES ( "" )
				.label (L1, sql )
				.columnwidth ( "100|100|150|300" )
				.additem_clr ( L1, sql )
				break
		end
	end
c: B4 BT "Show columns", A_YMOVE A_XMOVE
	select
		text x

		if ( ! table_mode )
			return
		end
		if ( (i = .selected (L1 )) == -1 )
			return
		end

		table_mode = 0
		switch ( db.dbtype () )
			case POSTGRESQL_DB
				table_mode = false
				x = .getitem ( L1, i, 1 )
				sql.exec ( "SELECT column_name,is_nullable,data_type,character_maximum_length from information_schema.columns where table_name=[x]" )
				.label (L1, sql )
				.columnwidth ( L1, "100|80|190|190" )
				.additem_clr ( L1, sql )	

				break
			case ODBC_DB
				table_mode = false
				sql.COLOUMNS ( .getitem ( L1, i, 2 ) ) 
				.label (L1, sql )
				.columnwidth ( "100|100|150|300" )
				.additem_clr ( L1, sql )
				break

		end
	end

end

