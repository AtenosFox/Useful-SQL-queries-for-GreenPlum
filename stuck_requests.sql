SELECT
  a.pid AS holder_pid,
  aa.sess_id AS holder_sess_id,
  aa.usename AS holder_usename,
  a.mode AS holder_mode,
  SUBSTRING(aa.query
    FROM 1 FOR 100) AS holder_query,
  b.pid AS waiter_pid,
  bb.sess_id AS waiter_sess_id,
  bb.usename AS waiter_usename,
  b.mode AS waiter_mode,
  SUBSTRING (bb.query
    FROM 1 FOR 100) AS waiter_query,
  date_trunc('sec', now() - bb.query_start) AS duration,
  date_trunc('sec', now()) AS metric_snapshot_local_time,
  date_trunc('sec', now()) at time zone 'UTC' AS metric_snapshot_utc_time
FROM
  pg_locks a
  JOIN pg_locks b ON a.pid != b.pid
  AND a.granted = TRUE
  AND b.granted = FALSE
  AND a.relation = b.relation
  JOIN pg_stat_activity aa ON a.pid = aa.pid
  JOIN pg_stat_activity bb ON b.pid = bb.pid
ORDER BY
  bb.query_start;
