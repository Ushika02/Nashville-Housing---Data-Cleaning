-- Data Cleaning

Select *
From NashvilleHousing..[Nashville Housing]

-- Standardized Data format

Select SaleDate, CONVERT(Date, SaleDate)
From NashvilleHousing..[Nashville Housing]

ALTER TABLE NashvilleHousing..[Nashville Housing]
Add SaleDateConverted Date;

Update NashvilleHousing..[Nashville Housing]
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From NashvilleHousing..[Nashville Housing]

-----------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

Select *
From NashvilleHousing..[Nashville Housing]
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing..[Nashville Housing] a
JOIN NashvilleHousing..[Nashville Housing] b  -- self join (joining table to itself)
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing..[Nashville Housing] a
JOIN NashvilleHousing..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------------------
-- Breaking  out Address into individual colummns (Address, City, States)
-- Property Address

Select PropertyAddress
From NashvilleHousing..[Nashville Housing]
--Where PropertyAddress is null
Order by ParcelID

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From NashvilleHousing..[Nashville Housing]


ALTER TABLE NashvilleHousing..[Nashville Housing]
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing..[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing..[Nashville Housing]
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing..[Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


-- Owner Address

Select OwnerAddress
From NashvilleHousing..[Nashville Housing]

Select PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From NashvilleHousing..[Nashville Housing]


ALTER TABLE NashvilleHousing..[Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing..[Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing..[Nashville Housing]
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing..[Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing..[Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing..[Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


---------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in 'Sold as Vacant' field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing..[Nashville Housing]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y'THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From NashvilleHousing..[Nashville Housing]

Update NashvilleHousing..[Nashville Housing]
SET SoldAsVacant =
	CASE When SoldAsVacant = 'Y'THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From NashvilleHousing..[Nashville Housing]


--------------------------------------------------------------------------------------------------------------------------------------------
-- Remove duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID 
	) row_num
From NashvilleHousing..[Nashville Housing]
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1


----------------------------------------------------------------------------------------------------------------------------------------------
-- Remove unused columns
Select *
From NashvilleHousing..[Nashville Housing]

Alter table NashvilleHousing..[Nashville Housing]
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate






