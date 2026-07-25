# Enable AWS Cost and Usage Reports (CUR) 2.0 for Athena

This is a one-time, 10-minute setup in your AWS Billing Console. It unlocks in-place querying of your cost data via Amazon Athena — no data ever leaves your account, and there is no ongoing maintenance on your side.

> [!NOTE]
> **Why this matters:** A plain S3 export of your billing data is not enough on its own. One additional setting during export creation registers your data in the AWS Glue Data Catalog, which is what allows Athena — and by extension our audit engine — to query it. This guide walks through that setting so it's configured correctly the first time.

If you already have CUR 2.0 with Athena integration enabled, skip ahead to the [main README](./README.md).

---

## Step 1: Create the data export

Navigate to **Billing and Cost Management → Data Exports → Create export**.

| Setting | Value |
|---|---|
| Export type | **Standard data export** |
| Data table | **CUR 2.0** |
| Billing view | **Primary** |
| Report data integration | **Amazon Athena** — this is the setting that provisions the Glue Data Catalog. Easy to miss; without it, Athena has nothing to query. |
| Compression / format | **Parquet** |
| File versioning | **Overwrite existing data export file** — keeps storage cost negligible and avoids duplicate rows on refresh |
| Include resource IDs | **On** — needed for resource-level findings |
| Time granularity | **Daily** (recommended default) — choose **Hourly** only if you specifically need sub-day granularity; it meaningfully increases export size |
| S3 destination | A bucket/prefix of your choosing, in the same account and region you'll use for Athena |

Everything else can be left at its default.

---

## Step 2: Confirm it's queryable

The first delivery can take up to 24 hours.

1. In **AWS Glue → Databases**, confirm a new database has appeared (Athena integration typically names it `athenacurcfn_<export-name>`).
2. Open its **Tables** entry and note the table name — it may not exactly match the export name you chose.
3. In **Amazon Athena**, confirm you can query it:

   ```sql
   SELECT * FROM <your_database>.<your_table> LIMIT 10;
   ```

   If it returns no rows, refresh partitions:

   ```sql
   MSCK REPAIR TABLE <your_database>.<your_table>;
   ```

4. Verify that you correctly selected **Overwrite existing data export file** in Step 1 by running this canary query:

   ```sql
   SELECT bill_billing_period_start_date as billing_period, COUNT(DISTINCT "$path") as file_versions 
   FROM <your_database>.<your_table> 
   GROUP BY 1;
   ```

   > [!WARNING]
   > If the `file_versions` column returns a number greater than 1 for any billing period, your export is configured to "Create new file" on delivery. **You must delete the export and recreate it using "Overwrite existing data export file".** If you do not, your costs will be exponentially double-counted every time AWS delivers an update.

---

## Step 3: Continue onboarding

Once the query above returns rows, head back to the [main README](./README.md) to deploy the Terraform module. You'll need the database and table names from Step 2.

> [!TIP]
> For the full security model behind this integration, see [`architecture_overview.md`](./architecture_overview.md).
