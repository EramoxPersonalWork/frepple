#
# Copyright (C) 2016 by frePPLe bvba
#
# All information contained herein is, and remains the property of frePPLe.
# You are allowed to use and modify the source code, as long as the software is used
# within your company.
# You are not allowed to distribute the software, either in the form of source code
# or in the form of compiled binaries.
#

from django.db import migrations, models

class Migration(migrations.Migration):

  dependencies = [
    ('common', '0011_username'),
  ]

  operations = [
    
    migrations.RunSQL(
      "insert into common_parameter (name, value, description, lastmodified) values ('plan.administrativeLeadtime','0','Specifies the number of days (value can be decimal) sales orders should be planned ahead of their due date to take into account for an administrative lead time. Default: 0',to_date('05/08/2017','DD/MM/YYYY')) ON CONFLICT (name) DO NOTHING",
      ),
  ]
