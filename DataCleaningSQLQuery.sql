/*
CLEANING OF DATASET IN SQL QUERIES
*/

SELECT *
  FROM [PortfolioProject].[dbo].[NationalHousing]


  --STANDARDIZE DATE FORMAT

  SELECT SaleDate, CONVERT(Date, SaleDate)
  FROM [PortfolioProject].[dbo].[NationalHousing]

  UPDATE [PortfolioProject].[dbo].[NationalHousing]
  Set SaleDate=CONVERT(Date, SaleDate)

 --Creating a new Column for saledate

 ALTER TABLE [PortfolioProject].[dbo].[NationalHousing]
  Add SaleDate_2 Date;

  UPDATE [PortfolioProject].[dbo].[NationalHousing]
  Set SaleDate_2 = CONVERT(Date, SaleDate)

  --POPULATE PROPERTY ADDRESS

  select *
  from PortfolioProject.dbo.NationalHousing
  --where PropertyAddress is null
  order by ParcelID

  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  from PortfolioProject.dbo.NationalHousing a
  Join PortfolioProject.dbo.NationalHousing b
  on a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  where a.PropertyAddress is null

  UPDATE a
  SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  from PortfolioProject.dbo.NationalHousing a
  Join PortfolioProject.dbo.NationalHousing b
  on a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  where a.PropertyAddress is null


  --BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS - ADDRESS, CITY AND STATE 
  -- I will be applying two methods - 1. Using Substrings and 2. Using Parser

  Select *
  From PortfolioProject.dbo.NationalHousing

  --METHOD 1 - SUBSTRINGS: THIS IS APPLIED TO THE PROPERTADDRESS

  Select
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
  ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
  From PortfolioProject.dbo.NationalHousing

  --CREATING NEW COLUMNS TO SPLIT THE PROPERTYADDRESS TO
  
  ALTER TABLE PortfolioProject.dbo.NationalHousing
  Add PropertySplitAddress Nvarchar(255);

  UPDATE PortfolioProject.dbo.NationalHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

  ALTER TABLE PortfolioProject.dbo.NationalHousing
  ADD PropertySplitCity Nvarchar(255);

  UPDATE PortfolioProject.dbo.NationalHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

  --METHOD 2 - PARSENAME: THIS IS APLLIED TO THE OWNERSADDRESS COLUMN

  Select
  PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as OwnersAddress
  , PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as OwnersCity
  , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnersState
  From PortfolioProject.dbo.NationalHousing

  ALTER TABLE PortfolioProject.dbo.NationalHousing
  Add OwnerSplitAddress Varchar(255);

  UPDATE PortfolioProject.dbo.NationalHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

  ALTER TABLE PortfolioProject.dbo.NationalHousing
  Add OwnerSplitCity Varchar(255);

  UPDATE PortfolioProject.dbo.NationalHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

  ALTER TABLE PortfolioProject.dbo.NationalHousing
  Add OwnerSplitState Varchar(255);

  UPDATE PortfolioProject.dbo.NationalHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


  select *
  from PortfolioProject.dbo.NationalHousing

  --CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD 

  SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
  FROM PortfolioProject.dbo.NationalHousing
  GROUP BY SoldAsVacant
  ORDER BY 2

 SELECT SoldAsVacant
 , CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		End

 FROM PortfolioProject.dbo.NationalHousing

 UPDATE PortfolioProject.dbo.NationalHousing
 SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		End


  --REMOVE DUPLICATES- CREATED CTE TO ACHIEVE THIS

WITH RowNumCTE AS(
select *,
 ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID) row_num
			
FROM PortfolioProject.dbo.NationalHousing
--ORDER BY ParcelID
)

Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress



  --DELETE UNUSED COLUMNS

  Select *
  FROM PortfolioProject.dbo.NationalHousing

  ALTER TABLE PortfolioProject.dbo.NationalHousing
  DROP COLUMN PropertyAddress

  ALTER TABLE PortfolioProject.dbo.NationalHousing
  DROP COLUMN SaleDate, OwnerAddress, TaxDistrict