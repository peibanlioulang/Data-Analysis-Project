-- Cleaning Data in SQL Queries
USE datacleaningproject;

SELECT 
    *
FROM
    datacleaningproject.nashville_housing;
    
    
-- Standardize Data Format (SaleDate Column)
-- Turn SaleDate Column from String to Date and Store it into new_sale_date

SELECT 
    SaleDate, STR_TO_DATE(SaleDate, '%M %d,%Y')
FROM
    datacleaningproject.nashville_housing;
    
ALTER TABLE nashville_housing
ADD new_sale_date Date;


UPDATE nashville_housing 
SET 
    new_sale_date = STR_TO_DATE(SaleDate, '%M %d,%Y');
    
-- Populate Property Address Data
-- Some PropertyAddress don't have any data. Fill those cells with Addresses of the same ParcelID.

SELECT 
    *
FROM
    datacleaningproject.nashville_housing
WHERE
	-- PropertyAddress = '';
    PropertyAddress IS NULL;
    
update nashville_housing
set PropertyAddress = null
WHERE PropertyAddress = '';
    
    
-- Self Join
SELECT 
    a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM
    datacleaningproject.nashville_housing a JOIN
    datacleaningproject.nashville_housing b 
ON	a.ParcelID = b.ParcelID AND
    a.UniqueID !=b.UniqueID
WHERE 
	a.PropertyAddress IS NULL;

--  Replace null value with an address

UPDATE datacleaningproject.nashville_housing a
        JOIN
    datacleaningproject.nashville_housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;
    



-- Breaking out address into address, city and state
-- PropertyAddress to property_address and property_city using substring

SELECT 
    PropertyAddress
FROM
    datacleaningproject.nashville_housing;
    
SELECT 
    PropertyAddress, SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) as property_address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, length(PropertyAddress) ) as property_city
FROM
    datacleaningproject.nashville_housing;
    
-- Add two columns property_address and property_city and insert the data

ALTER TABLE nashville_housing
ADD property_address varchar(255);

update nashville_housing
set property_address = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);


ALTER TABLE nashville_housing
ADD property_city varchar(255);

update nashville_housing
set property_city = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, length(PropertyAddress) );

SELECT 
    PropertyAddress,property_address,property_city
FROM
    datacleaningproject.nashville_housing;
    
-- OwnerAddress to owner_address, owner_city and owner_state using SUBSTRING_INDEX()
    
SELECT 
    OwnerAddress
FROM
    datacleaningproject.nashville_housing;
    
SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS owner_address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1) AS owner_city,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS owner_state
FROM
    datacleaningproject.nashville_housing;
    
-- Add three columns owner_address, owner_city and owner_state and insert the data
    
ALTER TABLE nashville_housing
ADD owner_address varchar(255);

update nashville_housing
set owner_address = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashville_housing
ADD owner_city varchar(255);

update nashville_housing
set owner_city = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1);

ALTER TABLE nashville_housing
ADD owner_state varchar(255);

update nashville_housing
set owner_state = SUBSTRING_INDEX(OwnerAddress, ',', -1);

    
SELECT 
    OwnerAddress,
    owner_address,
    owner_city,
    owner_state
FROM
    datacleaningproject.nashville_housing;
    
    
    
-- There are inconsistent valuse in SoldAsVacant column.
-- Change Y to yes and N to no

SELECT 
    distinct SoldAsVacant, count(SoldAsVacant)
FROM
    datacleaningproject.nashville_housing
GROUP BY
	SoldAsVacant;
    
SELECT 
    SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y'
		 THEN 'Yes'
         WHEN SoldAsVacant = 'N'
		 THEN 'No'
         ELSE SoldAsVacant
         END
FROM
    datacleaningproject.nashville_housing;
    
UPDATE nashville_housing
SET SoldAsVacant= CASE 
		WHEN SoldAsVacant = 'Y'
		THEN 'Yes'
		WHEN SoldAsVacant = 'N'
		THEN 'No'
		ELSE SoldAsVacant
		END;
        
        
        
-- Remove Duplicates
WITH RowNum AS(
SELECT 
    *,
    ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference ORDER BY UniqueID) row_num
FROM
    datacleaningproject.nashville_housing)
SELECT * 
FROM RowNum
WHERE row_num > 1
ORDER BY PropertyAddress;

SELECT
	*
FROM
    datacleaningproject.nashville_housing
WHERE
    PropertyAddress ='1003  BRILEY PKWY, NASHVILLE';
    
DELETE 
FROM nashville_housing
WHERE UniqueID IN (

WITH RowNum AS(
SELECT 
    UniqueID,
    ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference ORDER BY UniqueID) row_num
FROM
    datacleaningproject.nashville_housing)
SELECT UniqueID
FROM RowNum
WHERE row_num > 1 );




-- Delete Unused Columns
SELECT
	*
FROM
    datacleaningproject.nashville_housing;
    
ALTER TABLE nashville_housing
DROP COLUMN TaxDistrict, 
DROP COLUMN OwnerAddress, 
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;