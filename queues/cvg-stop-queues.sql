begin
    DBMS_AQADM.STOP_QUEUE('COSTEDEVENTQUEUEHEAD');
    exception when others then null;    -- ignore errors if it's already done
end;
/
begin
    DBMS_AQADM.STOP_QUEUE('COSTEDEVENTQUEUETAIL');
    exception when others then null;    -- ignore errors if it's already done
end;
/
begin
    DBMS_AQADM.STOP_QUEUE('HYBRIDCUSTDATASYNCQUEUE');
    exception when others then null;    -- ignore errors if it's already done
end;
/
begin
    DBMS_AQADM.STOP_QUEUE('RATINGCACHEQUEUE');
    exception when others then null;    -- ignore errors if it's already done
end;
/
begin
    DBMS_AQADM.STOP_QUEUE('REJECTEVENTQUEUEHEAD');
    exception when others then null;    -- ignore errors if it's already done
end;
/
begin
    DBMS_AQADM.STOP_QUEUE('REJECTEVENTQUEUETAIL');
    exception when others then null;    -- ignore errors if it's already done
end;
/
