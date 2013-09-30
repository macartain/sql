drop materialized view calls_sum;
drop materialized view log on calls;
drop table calls;

drop materialized view log on usage;
drop table usage;

drop sequence callid;
create sequence callid nomaxvalue;

create table calls (call_id number constraint pk_calls_id primary key,
                    run_number number,
                    alloc_key varchar2(20),
                    dialled_no varchar2(20),
                    cost number,
                    start_time date,
                    duration number)
       partition by range (run_number) (partition calls_1  values less than (2),
                                        partition calls_2  values less than (3),
                                        partition calls_3  values less than (4),
                                        partition calls_4  values less than (5),
                                        partition calls_5  values less than (6),
                                        partition calls_6  values less than (7),
                                        partition calls_7  values less than (8),
                                        partition calls_8  values less than (9),
                                        partition calls_9  values less than (10),
                                        partition calls_10 values less than (11),
                                        partition calls_x  values less than (maxvalue));

create materialized view log on calls 
                    with primary key, rowid
                    (run_number, alloc_key, dialled_no, cost, start_time, duration)
                    including new values;

create table usage (usage_id number constraint pk_usage_id primary key,
                    alloc_key varchar2(20),
                    start_date date,
                    end_date date default to_date('31-12-3000 23:59:59','dd-mm-yyyy hh24:mi:ss'));

create unique index usage_alloc on usage (alloc_key, start_date);

create materialized view log on usage
                    with primary key, rowid
                    (alloc_key, start_date, end_date)
                    including new values;

create materialized view calls_sum
       build immediate
       refresh fast with primary key on demand
    as select c.alloc_key,
              u.usage_id,
              u.start_date,
              u.end_date,
              count(c.alloc_key) as total_number,
              sum(c.cost) as total_cost,
              sum(c.duration) as total_duration
         from calls c, usage u
        where c.alloc_key = u.alloc_key
          and c.start_time between u.start_date and u.end_date
        group by c.alloc_key,
                 u.usage_id,
                 u.start_date,
                 u.end_date;

select * from calls_sum;
