## Initial Bronze load performance

A full historical load of approximately 422 million weather rows from staging
into Bronze was executed using:

- `NOT EXISTS` on the natural key
- `UNIQUE (station, observation_date, metric)`
- `ON CONFLICT DO NOTHING`

Observed runtime:
- 160+ minutes and still running

Observed resource usage during the load:
- CPU usage remained relatively low
- Disk activity was continuous
- Memory usage was not close to the system limit

Conclusion:
The incremental loading logic is suitable for recurring small staging batches,
but is inefficient for the initial historical bootstrap.

Initial historical loads and recurring incremental loads should be treated as
separate use cases.
