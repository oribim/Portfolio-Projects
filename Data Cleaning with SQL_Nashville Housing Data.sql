/* Dataset Credit: Alex the Analyst
https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx

Actions performed: date format conversion, populating missing values, splitting column entries, find and replace values, remove duplicates and delete unused columns.

*/

SELECT *
FROM Portfolio_Projects..Nashville_Housing

-- Setting the date format (CONVERT can also be used, but wanted to try something different)
SELECT SaleDate, CAST(SaleDate AS date) AS SalesDateConv
FROM Portfolio_Projects..Nashville_Housing

UPDATE Portfolio_Projects..Nashville_Housing
SET SaleDate=CAST(SaleDate AS date)

-- Second attempt to change data format
ALTER TABLE Portfolio_Projects..Nashville_Housing
ADD SalesDateConv Date

UPDATE Portfolio_Projects..Nashville_Housing
SET SalesDateConv=CAST(SaleDate AS date)

-- Also try the syntax below.. and it works better than the first two
ALTER TABLE Portfolio_Projects..Nashville_Housing
ALTER COLUMN [SaleDate] date

-- Populate missing values in property address
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Projects..Nashville_Housing a
JOIN Portfolio_Projects..Nashville_Housing b
ON a.ParcelID=b.ParcelID
WHERE a.PropertyAddress is null
AND a.[UniqueID ]<>b.[UniqueID ]

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Projects..Nashville_Housing a
JOIN Portfolio_Projects..Nashville_Housing b
ON a.ParcelID=b.ParcelID
WHERE a.PropertyAddress is null
AND a.[UniqueID ]<>b.[UniqueID ]

-- Breaking Propertyaddress to different columns
SELECT PropertyAddress
FROM Portfolio_Projects..Nashville_Housing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))AS City
FROM Portfolio_Projects..Nashville_Housing
-- CHARINDEX is used to search for a particular value and return its index number. This completes the length portion of the SUBSTRING query.
-- We then create columns to input our results
ALTER TABLE Portfolio_Projects..Nashville_Housing
ADD PropertyAddress2 nvarchar (255)

UPDATE Portfolio_Projects..Nashville_Housing
SET PropertyAddress2=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Portfolio_Projects..Nashville_Housing
ADD PropertyCity nvarchar (255)

UPDATE Portfolio_Projects..Nashville_Housing
SET PropertyCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- Breaking Owneraddress to different columns.
-- The parsename works with period as a delimiter. Hence we need to replace all commas with periods.
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Portfolio_Projects..Nashville_Housing

ALTER TABLE Portfolio_Projects..Nashville_Housing
ADD OwnerAddress2 nvarchar (255),
OwnerCity nvarchar (255),
OwnerState nvarchar (255)

UPDATE Portfolio_Projects..Nashville_Housing
SET OwnerAddress2=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
OwnerCity=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
OwnerState=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Change Y and N in "SoldAsVacant" column to Yes and No
SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Portfolio_Projects..Nashville_Housing

UPDATE Portfolio_Projects..Nashville_Housing
SET SoldAsVacant=CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					  WHEN SoldAsVacant = 'N' THEN 'No'
					  ELSE SoldAsVacant
					  END

-- Just to verify that the update worked
SELECT DISTINCT (SoldAsVacant)
FROM Portfolio_Projects..Nashville_Housing

--Removing Duplicates
--Recommend using a CTE to avoid deleting original data. 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID ) row_num
FROM Portfolio_Projects..Nashville_Housing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num>1

-- DELETE UNUSED COLUMNS
SELECT *
FROM Portfolio_Projects..Nashville_Housing

ALTER TABLE Portfolio_Projects..Nashville_Housing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate