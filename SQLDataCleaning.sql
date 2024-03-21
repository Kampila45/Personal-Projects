--CLEANING DATA IN SQL QUERIES
Select*
From PortfolioProject.dbo.[dbo.NashvilleHousing]

--STANDARDIZE FORMAT OF DATE 
Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.[dbo.NashvilleHousing]

Update [dbo.NashvilleHousing]
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [dbo.NashvilleHousing]
Add SaleDateConverted Date;

Update [dbo.NashvilleHousing]
SET SaleDateConverted = CONVERT(Date, SaleDate)

--POPULATE PROPERTY ADDRESS DATA
Select*
From PortfolioProject.dbo.[dbo.NashvilleHousing]
--Where PropertyAddress is null 
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[dbo.NashvilleHousing] a
JOIN PortfolioProject.dbo.[dbo.NashvilleHousing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[dbo.NashvilleHousing] a
JOIN PortfolioProject.dbo.[dbo.NashvilleHousing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 where a.PropertyAddress is null

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (CITY, ADDRESS, STATE)
Select PropertyAddress
From PortfolioProject.dbo.[dbo.NashvilleHousing]
--Where PropertyAddress is null 
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.[dbo.NashvilleHousing]

ALTER TABLE [dbo.NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);

Update [dbo.NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 

ALTER TABLE [dbo.NashvilleHousing]
Add PropertySplitCity Nvarchar(255);

Update [dbo.NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select*
From PortfolioProject.dbo.[dbo.NashvilleHousing]




Select OwnerAddress
From PortfolioProject.dbo.[dbo.NashvilleHousing]

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject.dbo.[dbo.NashvilleHousing]

ALTER TABLE [dbo.NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update [dbo.NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE [dbo.NashvilleHousing]
Add OwnerSplitCity Nvarchar(255);

Update [dbo.NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE [dbo.NashvilleHousing]
Add OwnerSplitState Nvarchar(255);

Update [dbo.NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select*
From PortfolioProject.dbo.[dbo.NashvilleHousing]

--CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.[dbo.NashvilleHousing]
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END 
From PortfolioProject.dbo.[dbo.NashvilleHousing]

Update dbo.[dbo.NashvilleHousing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END 


--REMOVE DUPLICATES
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

From PortfolioProject.dbo.[dbo.NashvilleHousing]
--order by ParcelID
)
Select*
From RowNumCTE
Where row_num > 1 


--DELETE UNUSED COLUMNS
Select*
From PortfolioProject.dbo.[dbo.NashvilleHousing]

ALTER TABLE PortfolioProject.dbo.[dbo.NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.[dbo.NashvilleHousing]
DROP COLUMN SaleDate