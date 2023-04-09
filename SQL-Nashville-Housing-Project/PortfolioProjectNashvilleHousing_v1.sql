/*

Nashiville Housing - Cleaning Data in SQL

*/

Select *
From PortfolioProjectHouse.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize date format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProjectHouse.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Select *
--From PortfolioProjectHouse.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate property address data

Select *
From PortfolioProjectHouse.dbo.NashvilleHousing
Where PropertyAddress is null

Select *
From PortfolioProjectHouse.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

-- When the ParcelId is equal, the property address is the same

Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
From PortfolioProjectHouse.dbo.NashvilleHousing a
Join PortfolioProjectHouse.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectHouse.dbo.NashvilleHousing a
Join PortfolioProjectHouse.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--Select *
--From PortfolioProjectHouse.dbo.NashvilleHousing
--Where PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (address, city and state)

Select PropertyAddress
From PortfolioProjectHouse.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProjectHouse.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Select *
--From PortfolioProjectHouse.dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProjectHouse.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProjectHouse.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Select *
--From PortfolioProjectHouse.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in sold as vacant field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjectHouse.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2 desc

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From PortfolioProjectHouse.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProjectHouse.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1

-- This query was implemented for study purposes only, it is not recommended practice to delete data from the database

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete unused columns

ALTER TABLE PortfolioProjectHouse.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProjectHouse.dbo.NashvilleHousing