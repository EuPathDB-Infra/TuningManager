# TuningManager
Engine to generate denormalized tables in the application database for a genomic website.

## Usage
```
Create/update "tuning tables", denormalized copies of data for better web site performance.
Usage: tuningManager -configFile <configXmlPath> -propFile <filename>
                      -instance <dbInstance> [ -schema <database schema> ]
                     [ -tables <list> ] [ -doUpdate ] [ -forceUpdate ]
                     [ -notifyEmail <emailAddressList> ] [ -debug ]
                     [ -cleanupWarnOnly ] [ -cleanupAge <days> ] [ -purgeOrphanTables ]
                     [ -maxWait <hours> ] [ -prefix <prefix> ] [ -filterValue <value> ]
                     [ -alwaysUpdate ]
                     [ -forDatasetPresenter <1> ]
options:
  configFile          an xml file describing the tables to be created
  propFile            file contains XML tuningProps entity containing password, schema, dblink, dbaEmail, or maxRebuildMinutes entities
  instance            the database instance to login and create objects in
  schema              the schema (database user) to login and create objects in
  tables              check/update only listed tables (and their antecedants)
  doUpdate            update any tables found to be out of date
  forceUpdate         perform update even if current_updater flag is set (implies -doUpdate)
  notifyEmail         comma-separated list of email addresses to send log to. ("none" to suppress email)
  cleanupWarnOnly     name but don't drop obsolete tuning tables
  cleanupAge          specify how long (in days) tuning table must be obsolete before dropping (default 0)
  purgeOrphanTables   delete ALL orphan tuning tables, even if their suffix is greater than that of the live table
  maxWait             limit, in hours, to wait if another tuning manager is updating the database
  debug               print debugging info
  prefix              create tuning tables and synonyms with supplied prefix, by substituting this value
                      for any occurrances of the "&prefix" macro
  filterValue         substitute this value for any occurences in the XML of the "&filterValue" macro
  alwaysUpdate        update every tuning table evaluated
  forDatasetPresenter set if only DatasetPresenter tables are being updated; will return different subject line if run results in errors.
note:
  The -instance, -configFile, and -propFile parameters are required.
example:
tuningManager -instance <db instance> -propFile <propFile> -configFile <XML file>
```
