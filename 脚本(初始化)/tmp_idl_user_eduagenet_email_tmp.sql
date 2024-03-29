ALTER TABLE tmp_idl_user_eduagenet_email_tmp DROP PARTITION(ds="{p0}" );
INSERT INTO tmp_idl_user_eduagenet_email_tmp PARTITION (ds="{p0}")
SELECT
        mobile_no,                     
        collect_set(email_server)   AS email_server_list,
        collect_set(job)            AS job_list,
        collect_set(overseas)       AS overseas_list,
        coalesce(min(qq_length),0)  AS qq_length, 
        coalesce(max(is_vip),0)     AS is_vip, 
        coalesce(max(is_number),0)  AS is_number 
from tmp_idl_user_eduagenet_email_list_tmp
where ds="{p0}"
group by  mobile_no;
