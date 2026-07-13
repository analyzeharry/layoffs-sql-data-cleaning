/* ============================================================
   LAYOFFS DATASET — DATA CLEANING PROJECT
   Author : Piyush Kumar
   Tools  : SQL Server (T-SQL)

   This script cleans a raw layoffs dataset in five stages:
     1. Load raw data into a staging table
     2. Remove duplicate records
     3. Standardize text / categorical fields
     4. Fix data types (dates, numeric fields)
     5. Handle NULL and blank values
   ============================================================ */

USE LAYOFFS;
GO

-- ------------------------------------------------------------
-- STEP 1: Load raw data
-- ------------------------------------------------------------

CREATE TABLE layoffs (
    company                 VARCHAR(50),
    location                VARCHAR(50),
    industry                VARCHAR(50),
    total_laid_off          INT NULL,
    percentage_laid_off     VARCHAR(50),
    dates                   VARCHAR(50),
    stage                   VARCHAR(100),
    country                 VARCHAR(80),
    funds_raised_millions   VARCHAR(50)
);

BULK INSERT dbo.layoffs
FROM 'C:\SQL2022\layoffs.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n'
);

-- Work on a staging copy so the original raw data is preserved
SELECT *
INTO layoffs_staging2
FROM layoffs;


-- ------------------------------------------------------------
-- STEP 2: Remove duplicate records
-- ------------------------------------------------------------
-- Identify duplicates using ROW_NUMBER() across every column;
-- rows with row_num > 1 are exact duplicates and get removed.

WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off,
                            percentage_laid_off, dates, stage, country,
                            funds_raised_millions
               ORDER BY company
           ) AS row_num
    FROM layoffs_staging2
)
DELETE FROM duplicate_cte
WHERE row_num > 1;


-- ------------------------------------------------------------
-- STEP 3: Standardize text / categorical fields
-- ------------------------------------------------------------

-- Trim stray whitespace from company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Merge inconsistent industry labels, e.g. "Crypto Currency" -> "Crypto"
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Remove trailing periods from country names, e.g. "United States." -> "United States"
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- ------------------------------------------------------------
-- STEP 4: Fix data types
-- ------------------------------------------------------------

-- Convert blank / literal "NULL" strings to true NULL before type conversion
UPDATE layoffs_staging2
SET dates = NULL
WHERE LTRIM(RTRIM(dates)) = '' OR dates = 'NULL';

ALTER TABLE layoffs_staging2
ALTER COLUMN dates DATE;

ALTER TABLE layoffs_staging2
ALTER COLUMN total_laid_off INT;


-- ------------------------------------------------------------
-- STEP 5: Handle missing values
-- ------------------------------------------------------------

-- Convert empty-string industries to true NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Backfill missing industry values using other rows for the same company
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- ------------------------------------------------------------
-- STEP 6: Final check
-- ------------------------------------------------------------

SELECT * FROM layoffs_staging2;
