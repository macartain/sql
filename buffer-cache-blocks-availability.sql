select count(*), State from (
    select decode (state, 
       0, 'Free',
       1, decode (lrba_seq,
          0, 'Available',
             'Being Used'),
       3, 'Being Used',
          state) State
     from x$bh )
    group by state