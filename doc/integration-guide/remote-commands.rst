===============
Remote commands
===============

All operations from the execution screen can also be launched and
monitored remotely through an web service API.

Example usage with curl::

   Run a task on the default database:
   curl -u <user>:<password> http(s)://<server>:<port>/execute/api/<command>/ 
      --data "<argument1>=<value1>&<argument2>=<value2>"
   
   Run a task on a scenario database:
   curl -u <user>:<password> http(s)://<server>:<port>/<scenario>/execute/api/<command>/ 
     --data "<argument1>=<value1>&<argument2>=<value2>"

The following URLS are available.

* | **GET /execute/api/status/**
  | **GET /execute/api/status/?id=<taskid>**:
  | Returns the list of all running and pending tasks. The second format
    returns the details of a specific task.

  Example usage with curl to retrieve status for active task::
    
      curl -u admin:admin http://localhost:8000/execute/api/status/    
    
  Example usage with curl to retrieve status of task with id 26::

      curl -u admin:admin http://localhost:8000/execute/api/status/?id=26 

* | **POST /execute/api/frepple_run/?constraint=15&plantype=1&env=supply** 
  | Generates a plan.

  Example usage with curl::

     curl -u admin:admin --data "constraint=15&plantype=1&env=fcst,invplan,balancing,supply" http://localhost:8000/execute/api/frepple_run/

* | **POST /execute/api/frepple_flush/?models=input.demand,input.operationplan** 
  | Emptying database for models given in input.
    
  Example usage with curl::
   
     curl -u admin:admin --data "models=input.demand,input.operationplan" http://localhost:8000/execute/api/frepple_flush/

* | **POST /execute/api/frepple_importfromfolder/**
  | Load CSV-formatted data files from a configured data folder into the
    frePPLe database.
    
  Example usage with curl::

     curl -u admin:admin -X POST http://localhost:8000/execute/api/frepple_importfromfolder/   

* | **POST /execute/api/frepple_exporttofolder/**
  | Dump planning results in CSV-formatted data files into a configured
    data folder on the frePPLe server.
    
  Example usage with curl::
    
     curl -u admin:admin -X POST http://localhost:8000/execute/api/frepple_exporttofolder/

* | **POST /execute/api/loaddata/?fixture=demo**
  | Loads a predefined dataset.
  
  Example usage with curl::

      curl -u admin:admin --data "fixture=manufacturing_demo" http://localhost:8000/execute/api/loaddata/
  
* | **POST /execute/api/frepple_copy/?copy=1&source=db1&destination=db2&force=1**
  | Creates a copy of a database into a scenario.
  
  Example usage with curl::

      curl -u admin:admin --data "copy=1&source=production&destination=scenario1&force=1" http://localhost:8000/execute/api/frepple_copy/

* | **POST /execute/api/frepple_backup/**
  | Backs up the content of the database to a file (which stays on the
    frePPLe application server).
    
  Example usage with curl::  

      curl -u admin:admin -X POST http://localhost:8000/execute/api/frepple_backup/  

* | **POST /execute/api/openbravo_import/?delta=7**
  | Execute the Openbravo import connector, which downloads data from Openbravo.
  
* | **POST /execute/api/openbravo_export/?filter=1**
  | Execute the Openbravo export connector, which uploads data to Openbravo.
  
* | **POST /execute/api/odoo_import/**
  | Execute the Odoo import connector, which downloads data from Odoo.

* | **POST /execute/api/frepple_createbuckets/?start=2012-01-01&end=2020-01-01&weekstart=1**
  | Initializes the date bucketization table in the database.
  
All these APIs return a JSON object and they are synchronous, i.e. they 
don't wait for the actual command to finish. In case you need to wait
for a task to finish, you will need to use a loop which periodically
polls the /execute/api/status URL to monitor the status.

For security reasons we strongly recommend the use of a HTTPS
configuration of the frePPLe server when using this API.
