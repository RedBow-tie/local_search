Local_Search. Load filenames to a local database for an easy search. This program is made with my Swedish Compiler. That is focusing on a simple Gui and support many different databases (PostgreSQL, SqLite, Odbc). It’s working under Linux (Wine).


![](https://github.com/RedBow-tie/local_search/blob/main/layout.png)

## sqlite

For higher performens I disable this database file safety. So if the load of filenames will
crash/hang the database will be corrupt, delete the database and start over.

## Known problem

SqlExperss is not supported as the lack of the LIMIT keyword. 
With MariaDb (for now only Odbc connection) there is a problem with the IN keyword. I haven’t tested MySql. 
No support for Wide character.

## About the Compiler

Sorry there is no Compiler manual, but there is a simple help program. I have many test program that's will be published in another project. 

Are You curious about the syntax ?
Perhaps this little program can make Yours interest:

```
form start ()
    layout "Database test" sysmenu 
              b    b  b    b

    e     ee       e
    f     ff               f
    g     gg               g

    end
    pre
        db.sqlite ("demo.db" )
        sql.select ( "* from customer" )
        .display ()        
    end
field
e:  "Name"
e: E1 EDIT, display ( sql.cust_no )
f: "Name"
f: E2 EDIT, display ( sql.name )
g: "City"

g: E3 EDIT, display ( sql.city )
b: BACK BT "Back"
    select    
        if ( -- sql < 0 )
            .disable ( BACK )
        end
        .enable ( FORW )
        .display ()    
    end
b: FORW BT "Forw"
    select
        if ( ++ sql >= sql.rows() )
            -- sql
            .disable ( FORW )
        end
        .enable ( BACK )
        .display ()        
    end
end
```
### The output

![](https://github.com/RedBow-tie/local_search/blob/main/demo.png)

