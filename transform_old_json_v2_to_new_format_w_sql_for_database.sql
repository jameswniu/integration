------
-- place all data to convert into temp table
------
drop table if exists business_analysis.test_responses;
create table if not exists test_responses as (select * from tpl_raw_bills 
where account_or_visit_number ~* '3841281-20628100|6633345-36240692');


------
-- add new json column for converted data
------
alter table
	test_responses
add column if not exists
	bill_content jsonb;


------
-- build new json converting from old json format
------
update
	test_responses a
set
	bill_content = jsonb_build_object(
		'cust_id', b.new_content->>'customer_id'
		, 'pat_acct', coalesce(nullif(substring(b.new_content->>'account_or_visit_number', '^[^-]*'), ''), nullif(b.new_content->>'medlytix_patient_id', ''))
		, 'output_id', b.new_content->>'output_id'
		, 'total_charges', b.new_content->>'gross_charges'
		, 'payment', b.new_content->>'amount_paid'
		, 'balance', b.new_content->>'balance'
		, 'financial_class', case when b.new_content->>'financial_class' = 'AUTO' then 'MVA' else b.new_content->>'financial_class' end
		, 'patient_firstname', b.new_content->>'patient_first_name'
		, 'patient_middlename', b.new_content->>'patient_middle_name'
		, 'patient_lastname', b.new_content->>'patient_last_name'
		, 'patient_phone', b.new_content->>'patient_phone'
		, 'patient_ssn', b.new_content->>'patient_ssn'
		, 'patient_dob', to_char((b.new_content->>'patient_dob')::date, 'YYYYMMDD')
		, 'patient_mrn', b.new_content->>'mrn'
		, 'patient_gender', b.new_content->>'patient_gender'
		, 'patient_martial_status', ''
		, 'patient_account', coalesce(nullif(substring(b.new_content->>'account_or_visit_number', '^[^-]*'), ''), nullif(b.new_content->>'medlytix_patient_id', ''))
		, 'patient_addr1', b.new_content->>'patient_address_1'
		, 'patient_addr2', b.new_content->>'patient_address_2'
		, 'patient_city', b.new_content->>'patient_city'
		, 'patient_state', b.new_content->>'patient_state'
		, 'patient_zip', coalesce(nullif(left(b.new_content->>'patient_zip4', 5), ''), nullif(left(b.new_content->>'patient_zip5', 5), ''))
		, 'accident_date', b.new_content->>'accident_date'
		, 'accident_state', b.new_content->>'accident_location'
		, 'auto_accident_flag', case when b.new_content->>'accident_auto_indicator' = 'Y' then 'AA' else '' end
		, 'other_accident_flag', b.new_content->>'accident_other_indicator'
		, 'due_to_accident', 'Y'
		, 'billing_provider', b.new_content->>'billing_provider_name'
		, 'billing_provider_npi', b.new_content->>'billing_provider_npi'
		, 'billing_provider_addr1', b.new_content->>'billing_provider_address'
		, 'billing_provider_addr2', ''
		, 'billing_provider_city', b.new_content->>'billing_provider_city'
		, 'billing_provider_state', b.new_content->>'billing_provider_state'
		, 'billing_provider_zip', b.new_content->>'billing_provider_zip'
		, 'billing_provider_taxid', replace(b.new_content->>'billing_provider_tax_id', '-' , '')
		, 'render_id', b.new_content->>'servicing_provider_customer_code'
		, 'render_npi', b.new_content->>'servicing_provider_npi'
		, 'render_taxonomy', b.new_content->>'servicing_provider_taxonomy'
		, 'render_firstname', b.new_content->>'servicing_provider_first_name'
		, 'render_middlename', left(b.new_content->>'servicing_provider_middle_name', 1)
		, 'render_lastname', b.new_content->>'servicing_provider_last_name'
		, 'facility', b.new_content->>'servicing_provider_location_name'
		, 'facility_npi', b.new_content->>'servicing_provider_location_npi'
		, 'facility_code', b.new_content->>'place_of_service_location_code'
		, 'facility_addr1', b.new_content->>'servicing_provider_location_address'
		, 'facility_addr2', ''
		, 'facility_city', b.new_content->>'servicing_provider_location_city'
		, 'facility_state', coalesce(nullif(b.new_content->>'servicing_provider_location_state', ''), nullif(b.new_content->>'hospital_provider_state', ''))
		, 'facility_zip', b.new_content->>'servicing_provider_location_zip'
		)
from 
	test_responses b
where
	a.cust_id = b.cust_id and a.pat_acct = b.pat_acct;
/*run this second*/
with cte0 as (
	select cust_id, pat_acct, string_agg(v, ',') diagnoses, string_agg(t, ',') "LX01_dx_code_pointer" from (
		select cust_id, pat_acct, v, (row_number() over (partition by cust_id, pat_acct))::text t from (	
			select cust_id, pat_acct, jsonb_object_keys(new_content) n, new_content ->> jsonb_object_keys(new_content)::text v from test_responses
		) foo0 where n ~* 'diagnostic_code' and v != '') foo1
	group by cust_id, pat_acct
)
, cte1 as (
select a.cust_id, a.pat_acct, jsonb_build_object(
	'diagnoses', a.diagnoses
	, 'LX01_dx_code_pointer', a."LX01_dx_code_pointer"
	, 'LX01_line_ctrlnum', ''
	, 'LX01_service_date', to_char((b.new_content->>'admit_date_or_service_date')::date, 'YYYYMMDD')
	, 'LX01_charge', b.new_content->>'gross_charges'
	, 'LX01_unit_quantity', b.new_content->>'total_units'
	, 'LX01_procedure_code', b.new_content->>'primary_cpt_code'
	, 'LX01_charge', b.new_content->>'gross_charges'
	, 'LX01_payment', b.new_content->>'amount_paid'
	, 'service_date', to_char((b.new_content->>'admit_date_or_service_date')::date, 'YYYYMMDD')
	, 'admission_date', to_char((b.new_content->>'admit_date_or_service_date')::date, 'YYYYMMDD')
	, 'discharge_date', to_char((b.new_content->>'discharge_date_or_end_service_date')::date, 'YYYYMMDD')
	, 'receiver', 'MEDLYTIX'
	, 'work_comp_flag', 'N'
	, 'claim_type', '837P'
	, 'claim_frequency', '1'
	, 'claim_filing_indicator', case when b.new_content->>'accident_auto_indicator' = 'Y' then 'AM' else '' end
	, 'pay_to_name', b.new_content->>'billing_provider_name'
	, 'pay_to_addr1', 'PO BOX 740937'
	, 'pay_to_addr2', ''
	, 'pay_to_city', 'ATLANTA'
	, 'pay_to_state', 'GA'
	, 'pay_to_zip', '303740937'
	) bill_content
from cte0 a
left join test_responses b on a.cust_id = b.cust_id and a.pat_acct = b.pat_acct
)
-->
update
	test_responses a
set
	bill_content = a.bill_content || b.bill_content
from
	cte1 b
where
	a.cust_id = b.cust_id and a.pat_acct = b.pat_acct;


------
-- checking key data payer info after conversion
------
select
	bill_content->>'claim_type' inst_prof
    , cust_id
	, pat_acct
	, bill_content->>'vx_pm_sk' vx_pm_sk
	, bill_content->>'vx_src_sk' vx_src_sk
	, bill_content->>'vx_carrier_claim_number' vx_carrier_claim_number
	, bill_content->>'vx_carrier_policy_number' vx_carrier_policy_number
	, bill_content->>'vx_carrier_name' vx_carrier_name
	, bill_content->>'vx_date_of_loss' vx_date_of_loss
	, bill_content->>'vx_accident_state' vx_accident_state
	, bill_content->>'vx_carrier_city' vx_carrier_city
	, bill_content->>'vx_carrier_state' vx_carrier_state
	, bill_content->>'vx_carrier_zip' vx_carrier_zip
	, bill_content->>'vx_carrier_lob' vx_carrier_lob
	, bill_content->>'vx_claim_type' vx_claim_type
	, bill_content->>'vx_carrier_insured_first_name' vx_carrier_insured_first_name
	, bill_content->>'vx_carrier_insured_last_name' vx_carrier_insured_last_name
	, bill_content->>'send_fax_number' send_fax_number
from test_responses
order by pat_acct;


------
-- checking key data payment to details after conversion
------
select
    cust_id
	, pat_acct
	, bill_content->>'pay_to_name' pay_to_name
	, bill_content->>'pay_to_addr1' pay_to_addr1
    , bill_content->>'pay_to_addr2' pay_to_addr2
    , bill_content->>'pay_to_city' pay_to_city
	, bill_content->>'pay_to_state' pay_to_state
	, bill_content->>'pay_to_zip' pay_to_zip
from test_responses;

