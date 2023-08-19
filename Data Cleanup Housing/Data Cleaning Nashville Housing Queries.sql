

Select *
From PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------
-- Standardize Date Format
----------------------------------------------------------------------------------

Select SaleDate, CONVERT(Date, SaleDate) as StandardDate
From PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate) -- Does not work

ALTER Table NashvilleHousing
Add SaleDateConverted Date;  -- Adding a new Column as SaleDateConverted

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate) -- Updating the Column with new values

----------------------------------------------------------------------------------
-- Populate Property Address Data for null Addresses
----------------------------------------------------------------------------------
Select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on  a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on  a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------
-- Individual column for Address i.e City, State etc
----------------------------------------------------------------------------------

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);  -- Adding a new Column as SaleDateConverted

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);  -- Adding a new Column as SaleDateConverted

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);  -- Adding a new Column as SaleDateConverted
ALTER Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);  -- Adding a new Column as SaleDateConverted
ALTER Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);  -- Adding a new Column as SaleDateConverted

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


----------------------------------------------------------------------------------
--- Change Y and N to Yes and No in "Sold as Vacant" Field
----------------------------------------------------------------------------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant 
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
  End
From PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = Case	When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						ELSE SoldAsVacant
						END


----------------------------------------------------------------------------------
--- Remove Duplicates
----------------------------------------------------------------------------------

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
From PortfolioProject.dbo.NashvilleHousing
-- Order BY ParcelID
)

DELETE
From RowNumCTE
Where row_num > 1
-- Order By PropertyAddress


----------------------------------------------------------------------------------
--- Delete Unused Columns
----------------------------------------------------------------------------------

ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP Column SaleDate




