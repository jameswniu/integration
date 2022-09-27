import os
import sys
import json
import re
import psycopg2.extras
import ast
from datetime import datetime as dt


os.chdir(r'L:\Auto_Opportunity_Analysis\Update_Accident_Date')


sql = """
select content->>'LX01_service_date', content->>'vx_date_of_loss', pm_sk, insurance_name from tpl_pre_billing_records
where status <> 'B' 
and (content->>'vx_date_of_loss')::date - (content->>'LX01_service_date')::date > 0 and (content->>'vx_date_of_loss')::date - (content->>'LX01_service_date')::date <= 7
and cust_id not in (9999, 484, 483, 710);
"""
params = {
    'host': 'revpgdb01.revintel.net',
    'database': 'tpliq_tracker_db',
    'user': 'james_niu_u',
    'password': 'Cw18745.'
}
con = psycopg2.connect(**params)
cur = con.cursor(cursor_factory=psycopg2.extras.DictCursor)
cur.execute(sql)


dy = {}

for row in cur:
    dy[str(row)] = 1 #put record as string to store in keys
# print(dy)

dt = datetime.datetime.now()
md = dt.strftime('%m') + dt.strftime('%d')

cnt = 0
with open('update_' + md + '_accident.sql', 'w') as fw:
    for k in dy:
        j = ast.literal_eval(k) #literally evaluate string into container type
        # print(j, type(j))

        str = """\
update
    tpl_pre_billing_records
set
    content = content || jsonb_build_object('vx_date_of_loss', content->>'LX01_service_date')
where
    pm_sk = {};
"""
        print(str.format(j[2]), file=fw, end='')

        cnt += 1

print(cnt)


sys.exit()