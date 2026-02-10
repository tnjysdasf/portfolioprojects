use project

--check data
Select *
From project..nh

--extract date from SaleDate
ALTER TABLE nh
Add SaleDateConverted Date;

UPDATE nh
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From project.dbo.nh

--property address populate

--Check nulls for property address
Select *
From project.dbo.nh
--Where PropertyAddress is null
Order by ParcelID
--inspect data, observed that parcel ID is the same for the same property address
--populate using selfjoin, add UniqueID id not the same 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From project..nh a
JOIN project..nh b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Update table
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From project..nh a
JOIN project..nh b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Breaking Propery Address City/State
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From project.dbo.nh

ALTER TABLE nh
Add PropertySplitAddress Nvarchar(255);

UPDATE nh
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nh
Add PropertySplitCity Nvarchar(255);

UPDATE nh
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--or use parsename
Select *
From project.dbo.nh

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as State,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as Address
From project.dbo.nh

ALTER TABLE nh
Add OwnerSplitAddress NVARCHAR(255);

UPDATE nh
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE nh
Add OwnerSplitCity NVARCHAR(255);

UPDATE nh
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


ALTER TABLE nh
Add OwnerSplitState NVARCHAR(255);

UPDATE nh
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

--change y/n to no
--check if theres y,n,yes no count
Select 
	Distinct(SoldAsVacant), 
	Count(SoldAsVacant)
From project.dbo.nh
Group by SoldAsVacant
Order by 2

---case statement
Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From project.dbo.nh

--update
UPDATE nh
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From project.dbo.nh

--Remove duplicates using row number, partition, use cte
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From project.dbo.nh
)
DELETE
From RowNumCTE 
Where row_num > 1
--Order by PropertyAddress


--Delete unused column for portfolio purposes only
Select *
From project.dbo.nh

ALTER TABLE project.dbo.nh
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE project.dbo.nh
DROP COLUMN SaleDate


