-- CLEANING DATA FROM HOUSING DATABASE

select *
from PortfolioProject..NashvilleHousing


-- Standardize date format

select SaleDate, CONVERT(date, SaleDate)
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted Date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate);


-- Populate property address data

select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out address into individual columns

select PropertyAddress
from PortfolioProject..NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add AddressSplitted Nvarchar(255);

update PortfolioProject..NashvilleHousing
set AddressSplitted = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

alter table PortfolioProject..NashvilleHousing
add CitySplitted Nvarchar(255);

update PortfolioProject..NashvilleHousing
set CitySplitted = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));


-- Breaking out owner address

select OwnerAddress
from PortfolioProject..NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress, ',','.'),1), PARSENAME(REPLACE(OwnerAddress, ',','.'),2), PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add OwnerAddressSplitted Nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerAddressSplitted = PARSENAME(REPLACE(OwnerAddress, ',','.'),3);

alter table PortfolioProject..NashvilleHousing
add OwnerCitySplitted Nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerCitySplitted = PARSENAME(REPLACE(OwnerAddress, ',','.'),2);

alter table PortfolioProject..NashvilleHousing
add OwnerStateSplitted Nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerStateSplitted = PARSENAME(REPLACE(OwnerAddress, ',','.'),1);


-- Change values Y/N in 'SoldAsVacant' to Yes/No

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant
 ,CASE	when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		END
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = CASE	when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		END


-- Remove duplicates

WITH RowNumCTE AS (
select *,
	ROW_NUMBER() OVER (
	partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by UniqueID) row_num
from PortfolioProject..NashvilleHousing
)
DELETE
from RowNumCTE
where row_num > 1


-- Delete unused columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

select *
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate