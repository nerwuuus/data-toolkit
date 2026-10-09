SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name = 'stations';
  