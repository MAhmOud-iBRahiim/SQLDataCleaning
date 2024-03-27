--DataCleaning SQL Project

Select *
From NashvilleHousing.dbo.NashvilleHousing

--------------------------------------------------

-- Changing  Date Format of SaleDate Col

Select Saledate
From NashvilleHousing.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER column SaleDate Date;



 ----------------------------------------------------------------------

/*
Populate the Null Values in Property Address col.
there is a repetition in PropertyAddress for same ParcelID.
*/

Select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress,t2.PropertyAddress)
From NashvilleHousing.dbo.NashvilleHousing t1
JOIN NashvilleHousing.dbo.NashvilleHousing t2
	on t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
Where t1.PropertyAddress is null


Update t1
SET PropertyAddress = ISNULL(t1.PropertyAddress,t2.PropertyAddress)
From NashvilleHousing.dbo.NashvilleHousing t1
JOIN NashvilleHousing.dbo.NashvilleHousing t2
	on t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
Where t1.PropertyAddress is null




---------------------------------------------------------------------

-- Breaking out PropertyAddress into (Address, City)

Select PropertyAddress
From NashvilleHousing.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NashvilleHousing.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255),
	PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) , 
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- Breaking out OwnerAddress into (Address, City, State)

Select OwnerAddress
From NashvilleHousing.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);


-----------------------------------------------------------------


-- standardize SoldAsVacant col

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
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

From NashvilleHousing.dbo.NashvilleHousing
)

delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



--------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousing.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress