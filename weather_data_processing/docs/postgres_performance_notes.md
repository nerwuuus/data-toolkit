## Initial Bronze load performance

A full historical load of approximately 422 million weather rows from staging
into Bronze was executed using:

- `NOT EXISTS` on the natural key
- `UNIQUE (station, observation_date, metric)`
- `ON CONFLICT DO NOTHING`

Observed runtime:
- 180+ minutes and still running

Observed resource usage during the load:
- CPU usage remained relatively low
- Disk activity was continuous
- Memory usage was not close to the system limit

Conclusion:
The incremental loading logic is suitable for recurring small staging batches,
but is inefficient for the initial historical bootstrap.

Initial historical loads and recurring incremental loads should be treated as
separate use cases.

## Lessons learned

The observations below were collected during a full staging-to-Bronze load of
approximately 422 million weather records.

- Initial historical loads and recurring incremental loads require different loading strategies.
- Incremental logic such as `NOT EXISTS` and `ON CONFLICT` can become very expensive when applied to hundreds of millions of rows.
- Low CPU utilization does not necessarily mean that PostgreSQL is idle or stuck. The workload may be limited by disk I/O, WAL writes, index maintenance, or random access patterns.
- Operating-system disk throughput is not the same as effective data-loading throughput. A 15 GB source dataset can generate substantially more than 15 GB of total I/O because of table writes, index updates, constraint checks, and WAL generation.
- `UNIQUE` constraints provide an important data-integrity safeguard, but maintaining the underlying unique index during a very large load adds additional overhead.
- Performance conclusions should be based on the actual workload. A strategy that performs poorly during a 422M-row historical bootstrap may still perform well for small recurring incremental batches.
- Historical bootstrap performance should therefore be tested separately from normal incremental pipeline performance.
