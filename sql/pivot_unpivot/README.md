# SQL Data Transformation Pipeline
This project demonstrates how to transform raw transactional data into reporting-ready datasets using PostgreSQL.
The example showcases a complete SQL transformation workflow, including data aggregation, reshaping, and reporting.

## Features
- Aggregate raw transactional data by ISO year, ISO week, and product
- Map product IDs to readable product groups using `CASE`
- Calculate:
  - Gross Orders
  - Gross Order Value
  - Non-Promo Price
  - Average Order Value (AOV)
- Transform data into a **long** format
- Pivot data back into a **wide** format using conditional aggregation
- Use Common Table Expressions (CTEs) to build a clear transformation pipeline

## Project Structure
```text
1_create_table.sql
2_insert_sample_data.sql
gross_orders_long.sql
gross_orders_wide.sql
README.md
```

## Sample Dataset
The sample dataset contains fictional transactional data for three products between **2022** and **2025**.

### Input Columns
| Column | Description |
|--------|-------------|
| `date` | Transaction date |
| `product_id` | Product identifier |
| `price` | Unit price |
| `gross_orders` | Number of gross orders |

## How to Run
1. Execute `1_create_table.sql`
2. Execute `2_insert_sample_data.sql`
3. Run `gross_orders_long.sql`
4. Run `gross_orders_wide.sql`

## Technologies
- PostgreSQL
- SQL
- Common Table Expressions (CTEs)
- Conditional Aggregation
- Pivot/Unpivot
- Data Transformation

## Notes
- All data is fictional and generated for demonstration purposes.
- Product identifiers (`P001`, `P002`, `P003`) are anonymized.
- This project demonstrates SQL transformation techniques and does not represent real business data.
