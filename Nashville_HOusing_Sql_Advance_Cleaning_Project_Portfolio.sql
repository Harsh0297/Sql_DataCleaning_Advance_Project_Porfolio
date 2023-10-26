USE sql_project_advance_portfolio;

SELECT * FROM housing_data;

-- BY default SalesDate is in date time format to convert into date only 
-- Standardize the Date Format
SELECT SaleDate, CONVERT(SaleDate,DATE) AS Updated_Column
FROM housing_data;

ALTER TABLE housing_data
MODIFY COLUMN SaleDate DATE;

SELECT SaleDate
FROM housing_data;

-- Populate Property address Data
-- IFNULL FUNCTION IS USED TO POPULATE OR COPY,IF THERE IS NULL VALUES IN THE LEFT COLUMN,  
-- IT WILL COPY FROM RIGHT COLUMN TO LEFT COLUMN
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM housing_data a
JOIN housing_data b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- UPDATE THE SAME THING IN THE TABLE 
UPDATE housing_data a
JOIN housing_data b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Breaking Out Address into Individual Columns Like (Address , City, State)
-- Substring() is a function to use to  that seprate or filter values from the column. Comes with three arguments (column name,starting address, ending address) 
-- Locate () function is use to locate the delimter or value within the column .Comes with two arguments(filtered value,Column name) 
SELECT PropertyAddress
FROM housing_data;

SELECT 
SUBSTRING(PropertyAddress,1,LOCATE(",",PropertyAddress)-1) AS Address
FROM housing_data;

SELECT 
SUBSTRING(PropertyAddress,LOCATE(",",PropertyAddress)+1,LENGTH(PropertyAddress)) AS City
FROM housing_data;

ALTER TABLE housing_data
ADD PropoertSplitAddress VARCHAR(255);

ALTER TABLE housing_data
ADD PropoertSplitCity VARCHAR(255);

UPDATE housing_data
SET PropoertSplitAddress = SUBSTRING(PropertyAddress,1,LOCATE(",",PropertyAddress)-1),
PropoertSplitCity = SUBSTRING(PropertyAddress,LOCATE(",",PropertyAddress)+1,LENGTH(PropertyAddress));
 
SELECT OwnerAddress
FROM housing_data;

ALTER TABLE housing_data
ADD OwnerSplitAddress VARCHAR(255);
 
SELECT 
SUBSTRING(OwnerAddress,1,LOCATE(",",OwnerAddress)-1) AS ADDRESS 
FROM housing_data;

UPDATE housing_data
SET OwnerSplitAddress = SUBSTRING(OwnerAddress,1,LOCATE(",",OwnerAddress)-1);

ALTER TABLE housing_data
ADD OwnerSplitCity VARCHAR(255);


SELECT
  SUBSTRING(
    OwnerAddress,
    LOCATE(',', OwnerAddress) + 1, -- Starting position after the comma
    LOCATE(',', OwnerAddress, LOCATE(',', OwnerAddress) + 1) - LOCATE(',', OwnerAddress) - 1
  ) AS CITY
FROM housing_data;

UPDATE housing_data
SET OwnerSplitCity = SUBSTRING(
    OwnerAddress,
    LOCATE(',', OwnerAddress) + 1, -- Starting position after the comma
    LOCATE(',', OwnerAddress, LOCATE(',', OwnerAddress) + 1) - LOCATE(',', OwnerAddress) - 1
  );


ALTER TABLE housing_data
ADD OwnerSplitState VARCHAR(255);


SELECT
  SUBSTRING(
    OwnerAddress,
    LOCATE(',', OwnerAddress, LOCATE(',', OwnerAddress) + 1) + 1, -- Starting position after the second comma
    LENGTH(OwnerAddress) - LOCATE(',', OwnerAddress, LOCATE(',', OwnerAddress) + 1) 
  ) AS STATE
FROM housing_data;

UPDATE housing_data
SET OwnerSplitState=SUBSTRING(
    OwnerAddress,
    LOCATE(',', OwnerAddress, LOCATE(',', OwnerAddress) + 1) + 1, -- Starting position after the second comma
    LENGTH(OwnerAddress) - LOCATE(',', OwnerAddress, LOCATE(',', OwnerAddress) + 1) 
  );
  
  SELECT OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
  FROM housing_data;
  
  
  
-- CHNAGE TO Y AND N IN VACANT FEILD FROM YES OR NO 
SELECT SoldAsVacant 
FROM housing_data;

SELECT DISTINCT(SoldAsVacant)
FROM housing_data;

SELECT SoldAsVacant,
CASE
	WHEN  SoldAsVacant = "No" then "No"
    WHEN SoldAsVacant = "N" then "No"
    WHEN  SoldAsVacant = "Yes" then "Yes"
    WHEN  SoldAsVacant = "Y" then "Yes"
 END AS Updated_STatus
FROM housing_data;

UPDATE housing_data
SET SoldAsVacant = 
CASE
	WHEN  SoldAsVacant = "No" then "No"
    WHEN SoldAsVacant = "N" then "No"
    WHEN  SoldAsVacant = "Yes" then "Yes"
    WHEN  SoldAsVacant = "Y" then "Yes"
 END;
 
 
 -- REMOVING DUPLICATES USING SUBQUERY
 -- NOTE WE CANNOT DELETE IN THE CTE'S THAT THE LIMITATION OF SQL 
 -- ROW NUMBER FUNCTION IS USED TO ASSIGN A UNIQUE VALUE TO REMOVE DUPLICATES/ PARTITIONING ETC. 
 SELECT *,
 ROW_NUMBER()  OVER 
		(
        PARTITION BY 
        ParcelID,
        PropertyAddress,
        SaleDate,
        LegalReference,
        SalePrice
        ORDER BY UniqueID
        ) AS Row_num
FROM housing_data;

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference, SalePrice
               ORDER BY UniqueID
           ) AS Row_num
    FROM housing_data
) AS subquery
WHERE Row_num > 1;


-- using of the CTE'S to remove duplicate values 
WITH Row_Number_CTE AS 
(
 SELECT *,
 ROW_NUMBER()  OVER 
		(
        PARTITION BY 
        ParcelID,
        PropertyAddress,
        SaleDate,
        LegalReference,
        SalePrice
        ORDER BY UniqueID
        ) AS Row_num
FROM housing_data
)
DELETE
-- SELECT * 
FROM Row_Number_CTE
WHERE Row_num>1;
-- there is a limitation in MYSQL THAT WE CAN DELETE THE DATA FROM THE DERIVED TABLE OR CTE'S 

ALTER TABLE housing_data
ADD row_numb int;

UPDATE housing_data AS t1
JOIN (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference, SalePrice
               ORDER BY UniqueID
           ) AS Row_num
    FROM housing_data
) AS subquery
ON t1.UniqueID = subquery.UniqueID
SET t1.row_numb = subquery.Row_num
WHERE subquery.Row_num > 1;

DELETE 
FROM housing_data
WHERE Row_numb>1; 

SELECT * 
FROM housing_data
WHERE Row_numb>1; 


-- DELETING THE UNUNSED COLUMNS FROM THE DATABASE
ALTER TABLE housing_data
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict;

SELECT * 
FROM housing_data;