CREATE TABLE if not exists tmp_idl_user_eduagenet_email_list_tmp
(
mobile_no               STRING,
email_domain            STRING,
email_server            STRING,
job                     STRING,
overseas                STRING,
qq_length               INT, 
is_vip                  INT, 
is_number	            INT 
) 
comment "email domain and its properties"
PARTITIONED BY (ds STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE;

INSERT INTO tmp_idl_user_eduagenet_email_list_tmp PARTITION (ds)
SELECT mobile_no,
       email_domain,
       email_server,
       job,
       overseas,
       IF(email_server ="qq",length(email_name),NULL) AS qq_length,      
       IF(domain_part_1="vip",1,0) AS is_vip,
       IF(email_name rlike '^\\d+$',1,0) AS is_number,
       CAST(date_add("2017-01-01",CAST(substring(mobile_no,-2,2) AS INT)) AS STRING) AS ds
  FROM (SELECT 
               mobile_no,
               email_name,
               email_domain,
               email_server,
               CASE WHEN (domain_part_2="edu" or domain_part_3="edu") THEN "school"
                    WHEN (domain_part_2="gov" or domain_part_3="gov") THEN "goverment"
                    WHEN email_server LIKE "%air%" THEN "airline"
                    WHEN email_server LIKE "%bank%" THEN "bank"
                    WHEN email_server IN ("qq","163","126","sina","yahoo","hotmail","gmail","sohu","139","aliyun","foxmail","yeah",
                        "tom","21cn","189","live","msn","eyou","outlook","icloud","sogou","wo","me","chinaren","263","mail") THEN NULL
                    ELSE "other"
               END AS job,  
               IF(property IN ("hk","tw","sg","jp","ru","uk","my","om","pw","fr","me","nu","kr","sh","sd","nz","us",
                      "in","it","mo","se","tc","vn","so","gd","su","tv","pm","vc","ws","wf","re","tf","lc","ml","tj","li","tk",
                      "si","ua","sz","sn","id","la"),property,NULL) AS overseas,
               domain_part_1,
               domain_part_2,       
               domain_part_3,
               domain_part_4
          FROM (SELECT 
                       mobile_no,
                       email_name,
                       email_domain,
                       CASE WHEN domain_length=2 THEN domain_part_1          
                            WHEN (domain_length=3 and domain_part_3 IN ("com","net","edu","org","con")) THEN domain_part_2        
                            WHEN (domain_length=3 and domain_part_2 IN ("com","net","edu","gov","co","ac","org","con")) THEN domain_part_1                           
                            WHEN (domain_length=4 and domain_part_3="edu") THEN domain_part_2      
                            ELSE NULL 
                       END AS email_server,
                       CASE WHEN domain_length=2 THEN domain_part_2
                            WHEN (domain_length=3 and domain_part_3 IN ("com","net","edu","org","con")) THEN domain_part_1          
                            WHEN (domain_length=3 and domain_part_2 IN ("com","net","edu","gov","co","ac","org","con")) THEN domain_part_3           
                            WHEN domain_length=4 THEN domain_part_4
                            ELSE NULL 
                       END AS property,
                       domain_part_1,
                       domain_part_2,       
                       domain_part_3,
                       domain_part_4
                  FROM (SELECT 
                               t0.mobile_no,
                               t0.email_name,
                               t0.email_domain, 
                               size(split(t0.email_domain,"\\.")) AS domain_length,
                               split(t0.email_domain,"\\.")[0] AS domain_part_1,                
                               split(t0.email_domain,"\\.")[1] AS domain_part_2, 
                               split(t0.email_domain,"\\.")[2] AS domain_part_3,
                               split(t0.email_domain,"\\.")[3] AS domain_part_4
                               FROM (SELECT 
                                         mobile_no,
                                         split(lower(email),"@")[0] as email_name,
                                         split(lower(email),"@")[1] as email_domain
                                         FROM idl_limao_email_agg
                                         where ds='2017-04-20' and mobile_no is not null
                                     ) t0
                        ) t1 
                )t2 
        )t3;
        

