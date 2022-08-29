-- Standardize Date Format as SaleDateConverted

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--Convert Property Addresses into Individual Columns (Address, City, State)

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) as City

FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
FROM PortfolioProject.dbo.NashvilleHousing

-- Add Owner Address to City, State, Address columns


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as State
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

-- Normalize Y and N to Yes and No in "SoldAsVacant" field (currently they are 4 distinct responses)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY  SoldAsVacant
ORDER BY 2 DESC


SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END
FROM PortfolioProject.dbo.NashvilleHousing


-- Removing Duplicates ( This is not a temp table and data IS deleted)

WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
    PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
	  UniqueID
	  ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


--Delete unused columns (Dont do this to original data)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress