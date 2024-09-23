-- DATA CLEANING

CREATE TABLE layoffs_staging LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-- now when we are cleaning data we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways


-- Removing duplicates

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER()  OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as row_num FROM layoffs_staging 
)
SELECT * FROM duplicate_cte WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT layoffs_staging2
SELECT *,
ROW_NUMBER()  OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as row_num FROM layoffs_staging ;

DELETE FROM layoffs_staging2 WHERE row_num > 1;

SELECT * FROM layoffs_staging2 ;

-- Standardizing data

SELECT company, TRIM(company) 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry FROM layoffs_staging2;

SELECT * from layoffs_staging2 
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country from layoffs_staging2 
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT `date` 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`,'%m/%d/%Y');
 
SELECT * FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date;

-- Deal with null and blank values

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT * FROM layoffs_staging2
WHERE industry IS NULL ;

SELECT * FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
ON t1.company = t2.company
WHERE t1.industry IS NULL AND
	  t2.industry IS NOT NULL;
      
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND
	  t2.industry IS NOT NULL;
      
-- Remove unnecessary column or rows

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
      
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * FROM layoffs_staging2;


      
      
      
      
      
      







