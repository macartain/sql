set lines 200 trimspool on
col h0 for 999
col h1 for 999
col h2 for 999
col h3 for 999
col h4 for 999
col h5 for 999
col h6 for 999
col h7 for 999
col h8 for 999
col h9 for 999
col h10 for 999
col h11 for 999
col h12 for 999
col h13 for 999
col h14 for 999
col h15 for 999
col h16 for 999
col h17 for 999
col h18 for 999
col h19 for 999
col h20 for 999
col h21 for 999
col h22 for 999
col h23 for 999
col h24 for 999
SELECT  trunc(first_time) "Date",
        to_char(first_time, 'Dy') "Day",
        count(1) "Total",
        SUM(decode(to_char(first_time, 'hh24'),'00',1,0)) "h0",
        SUM(decode(to_char(first_time, 'hh24'),'01',1,0)) "h1",
        SUM(decode(to_char(first_time, 'hh24'),'02',1,0)) "h2",
        SUM(decode(to_char(first_time, 'hh24'),'03',1,0)) "h3",
        SUM(decode(to_char(first_time, 'hh24'),'04',1,0)) "h4",
        SUM(decode(to_char(first_time, 'hh24'),'05',1,0)) "h5",
        SUM(decode(to_char(first_time, 'hh24'),'06',1,0)) "h6",
        SUM(decode(to_char(first_time, 'hh24'),'07',1,0)) "h7",
        SUM(decode(to_char(first_time, 'hh24'),'08',1,0)) "h8",
        SUM(decode(to_char(first_time, 'hh24'),'09',1,0)) "h9",
        SUM(decode(to_char(first_time, 'hh24'),'10',1,0)) "h10",
        SUM(decode(to_char(first_time, 'hh24'),'11',1,0)) "h11",
        SUM(decode(to_char(first_time, 'hh24'),'12',1,0)) "h12",
        SUM(decode(to_char(first_time, 'hh24'),'13',1,0)) "h13",
        SUM(decode(to_char(first_time, 'hh24'),'14',1,0)) "h14",
        SUM(decode(to_char(first_time, 'hh24'),'15',1,0)) "h15",
        SUM(decode(to_char(first_time, 'hh24'),'16',1,0)) "h16",
        SUM(decode(to_char(first_time, 'hh24'),'17',1,0)) "h17",
        SUM(decode(to_char(first_time, 'hh24'),'18',1,0)) "h18",
        SUM(decode(to_char(first_time, 'hh24'),'19',1,0)) "h19",
        SUM(decode(to_char(first_time, 'hh24'),'20',1,0)) "h20",
        SUM(decode(to_char(first_time, 'hh24'),'21',1,0)) "h21",
        SUM(decode(to_char(first_time, 'hh24'),'22',1,0)) "h22",
        SUM(decode(to_char(first_time, 'hh24'),'23',1,0)) "h23",
        -- for today, use # of hrs so far today to get avg
        -- for past days, use 24 hrs to get avg
        decode(trunc(first_time),
               trunc(sysdate), round(count(1) / (24 * to_number(to_char(sysdate, 'sssss')+1) / 86400),2),
               round(count(1) / 24, 2)) "Avg"
FROM    V$log_history
group by trunc(first_time), to_char(first_time, 'Dy')
order by 1;

