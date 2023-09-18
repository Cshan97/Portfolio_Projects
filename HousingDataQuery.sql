/* Cleansing data using SQL Queries */

SELECT *
FROM [Portfolio Housing Data].dbo.[HousingData]
-- Standardizing date format

ALTER TABLE HousingData
add SaleDateConverted Date;

UPDATE [HousingData]
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
from [Portfolio Housing Data].dbo.HousingData


-- Populate Property Address Data
          
		  --this segment shows the ParcelID which is attatched to an address
		  --If the parcel ID matches an address that is blank, we can us the Parcel ID to fill it
select *
from [Portfolio Housing Data]..HousingData
--WHERE PropertyAddress is null
ORDER BY ParcelID

		-- This segment shows Two parcel IDs that are the same but one that has an address and one that does not,
select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from [Portfolio Housing Data]..HousingData a
JOIN [Portfolio Housing Data]..HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

	-- Code Gets rid of those NULL Addresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Housing Data]..HousingData a
JOIN [Portfolio Housing Data]..HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



-- Breaking the address into individual columns (Address, City, State

SELECT PropertyAddress
FROM [Portfolio Housing Data]..HousingData

-- This segment breaks the address up and removes the comma delimiter
SELECT
substring(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [Portfolio Housing Data]..HousingData


ALTER TABLE HousingData
add PropertySplitAddress Nvarchar(255);

UPDATE [HousingData]
SET PropertySplitAddress = substring(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE HousingData
add PropertySplitCity Nvarchar(255);

UPDATE [HousingData]
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))





--This segment will seperate the owner address in a simpler way than the substring method 
-- Makes serperate columns for the owner address, city, and state making more usable.

SELECT OwnerAddress
FROM [Portfolio Housing Data]..HousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM [Portfolio Housing Data]..HousingData



ALTER TABLE HousingData
add OwnerSplitAddress Nvarchar(255);

UPDATE [HousingData]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)



ALTER TABLE HousingData
add OwnerSplitCity Nvarchar(255);

UPDATE [HousingData]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE HousingData
add OwnerSplitState Nvarchar(255);

UPDATE [HousingData]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


-- Changes the Y and N to yes and no in the 'Sold as vacant' field

Select Distinct(SoldAsVacant) , Count(SoldAsVacant)
FROM [Portfolio Housing Data]..HousingData
group by SoldAsVacant
order by 2




SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM [Portfolio Housing Data]..HousingData


Update HousingData
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END



-- Removes duplicates -- this isnt standard procedure, do not do this all the time

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER by 
				UniqueID
				) row_num
FROM [Portfolio Housing Data]..HousingData
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



-- Deletes unused columns, Do not do this with your raw data you import, ask first.
	--This segment will remove the original columns that we sepereated earlier, and some not so useful columns

SELECT *
From [Portfolio Housing Data]..HousingData

ALTER TABLE [Portfolio Housing Data]..HousingData
DROP COLUMN SaleDate

