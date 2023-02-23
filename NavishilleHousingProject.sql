
--Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProjects..NashvilleHousing


--Standardize Data Format

 SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address data


SELECT *
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress is Null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null




-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress is Null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

FROM PortfolioProjects..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT *
FROM PortfolioProjects..NashvilleHousing


SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProjects..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


SELECT *
FROM PortfolioProjects..NashvilleHousing



--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldasVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
Group By SoldAsVacant
Order By 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProjects..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




--Remove Duplicates


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


FROM PortfolioProjects..NashvilleHousing
--order by ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
Order BY PropertyAddress


--Delete Unused Columns


ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN SaleDate