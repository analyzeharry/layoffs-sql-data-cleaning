# Layoffs Dataset — SQL Data Cleaning Project

## Overview
This project cleans and standardizes a raw dataset of company layoffs using SQL Server (T-SQL). The raw data contained duplicate records, inconsistent text formatting, and mixed data types — this script transforms it into an analysis-ready table.

## What I Did
- **Removed duplicates** using `ROW_NUMBER()` window functions inside a CTE, partitioning across all columns to identify exact-match duplicate rows
- **Standardized text fields** — trimmed whitespace from company names, merged inconsistent industry labels (e.g., "Crypto Currency" → "Crypto"), and removed trailing punctuation from country names
- **Fixed data types** — converted date fields stored as text into proper `DATE` types, handling hidden issues like the literal string `"NULL"` bypassing normal NULL checks
- **Handled missing values** — converted empty strings to true NULLs, then backfilled missing `industry` values using a self-join that matched records by company name

## Key Techniques Used
`ROW_NUMBER()` window function · CTEs · Self-joins · `TRIM()` · `TRY_CONVERT` · Data type conversion · NULL handling

## Tools
SQL Server (T-SQL, SSMS)

## File
[`layoffs_data_cleaning.sql`](./layoffs_data_cleaning.sql) — full cleaning script, organized into 6 clearly commented steps (load → dedupe → standardize → fix types → handle nulls → final check)
