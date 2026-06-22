# Campaign Data SQL Transformation Pipeline
This project demonstrates how to transform anonymized campaign-level data into reporting-ready datasets using PostgreSQL.

The example is based on a generic marketing data transformation pattern: raw campaign data is aggregated, cleaned, enriched with derived metrics, and reshaped into a long format for downstream reporting or modeling.

## Features
- Create an anonymized sample campaign dataset
- Aggregate raw campaign data by ISO year, ISO week, brand, channel, campaign, product category, and target
- Clean and standardize product categories
- Apply conditional business rules with `CASE WHEN`
- Calculate spendings, gross spend, GRPs, and price-per-GRP
- Fill missing GRPs using spendings and price-per-GRP where possible
- Transform wide campaign metrics into a long reporting format using `UNION ALL`
- Create reusable PostgreSQL views

## Project Structure
```text
1_create_table.sql
2_insert_sample_data.sql
3_campaign_aggregated.sql
4_campaign_long.sql
README.md
```

## Sample Dataset
The sample dataset contains fictional campaign data for different brands, products, media channels, and campaign types.

### Input Columns
| Column | Description |
|--------|-------------|
| `isoyear` | ISO year |
| `isoweek` | ISO week |
| `brand` | Anonymized brand name |
| `media_channel` | Media channel |
| `sub_channel` | Media sub-channel |
| `campaign_name` | Anonymized campaign name |
| `campaign_objective` | Campaign objective/category |
| `product_category` | Product category |
| `target` | Target audience |
| `net_spend` | Net spend amount |
| `gross_spend` | Gross spend amount |
| `grps` | Gross Rating Points |
| `price_per_grp` | Price per GRP |

## How to Run
1. Execute `1_create_table.sql`
2. Execute `2_insert_sample_data.sql`
3. Execute `3_campaign_aggregated.sql`
4. Execute `4_campaign_long.sql`
5. Query the final view:

```sql
SELECT *
FROM campaign_long;
```

## Notess
- All data is fictional and generated for demonstration purposes.
- Brand names, campaign names, and product categories are anonymized.
- The SQL is reconstructed from screenshots and generalized into a portfolio-ready example.
- This project demonstrates SQL transformation techniques and does not represent real business data.
