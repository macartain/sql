create or replace package corr_aq_92 as
  
procedure drop_corrupted_q92(q_schema            IN VARCHAR2,
  qt_name            IN VARCHAR2,
  q_name             IN VARCHAR2,
  multi_consumer     IN BOOLEAN DEFAULT TRUE);

procedure drop_corrupted_qt92(qt_schema    IN  VARCHAR2,
  qt_name      IN  VARCHAR2,
  multi_consumer IN BOOLEAN DEFAULT TRUE,
  compatible   IN VARCHAR2 DEFAULT '8.1');

PROCEDURE drop_queue_subsrulesandsets (qt_schema   IN VARCHAR2,
  qt_name     IN VARCHAR2,
  q_name      IN VARCHAR2);

end corr_aq_92;
/