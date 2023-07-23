select *
from portfolioProject.dbo.NashvilleHousing


--Standarize the SaleDate column
select CONVERT(DATE, SaleDate)
from portfolioProject.dbo.NashvilleHousing
--works fine, SO...
ALTER TABLE portfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate DATE


-- populate property address data
select *
from portfolioProject.dbo.NashvilleHousing
where PropertyAddress is  NULL
order by ParcelID
--  PropertyAddress is NULL where same ParcelID

-- so, ISNULL(expression, value) Return the specified value IF the expression is NULL, otherwise return the expression:
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,  ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioProject.dbo.NashvilleHousing a
join portfolioProject.dbo.NashvilleHousing b      --self join
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ] <>  b.[UniqueID ]    --  <>  not equal to
where a.PropertyAddress is NULL


							-- same as but we wnat to set a value, so we need a function --

--select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
--from portfolioProject.dbo.NashvilleHousing a
--join portfolioProject.dbo.NashvilleHousing b      --self join
--	on a.ParcelID= b.ParcelID
--	where a.PropertyAddress is NULL and b.PropertyAddress is not NULL

update a
set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioProject.dbo.NashvilleHousing a
join portfolioProject.dbo.NashvilleHousing b      
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ] <>  b.[UniqueID ]   
where a.PropertyAddress is NULL


					-- breaking PropertyAddress into Adress, City, State
--  PropertyAddress is separated by comma, so delimeter=','

-- SUBSTRING(string, start, length) function extracts some characters from a string.
-- CHARINDEX(substring, string, start) function searches for a substring in a string, and returns the position.
select
PropertyAddress,
SUBSTRING( PropertyAddress,1, CHARINDEX(',', PropertyAddress,1) -1 ) AS Address,
SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress,1)+2,LEN(PropertyAddress)) AS City,
SUBSTRING( PropertyAddress, 1,CHARINDEX(' ', PropertyAddress,1)) AS AddressCode
from portfolioProject.dbo.NashvilleHousing

							-- ADD TO THE TABLE
-- ADDRESS
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING( PropertyAddress,1, CHARINDEX(',', PropertyAddress,1) -1 )
-- CITY
ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress,1)+2,LEN(PropertyAddress))


--PARSENAME() works with periods'.' . not comma. hence, replace ','  with '.'  first
select OwnerAddress,
PARSENAME(REPLACE( OwnerAddress, ',' , '.' ) ,1) as State,
PARSENAME(REPLACE( OwnerAddress, ',' , '.' ) ,2) as City,
PARSENAME(REPLACE( OwnerAddress, ',' , '.' ) ,3) 
from portfolioProject.dbo.NashvilleHousing

								-- ADD TO THE TABLE
-- ADDRESS
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
--CITY
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);
--State
ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);


UPDATE NashvilleHousing
--SET OwnerSplitAddress = PARSENAME(REPLACE( OwnerAddress, ',' , '.' ) ,3) ;
--SET OwnerSplitCity = PARSENAME(REPLACE( OwnerAddress, ',' , '.' ) ,2) ;
SET OwnerSplitState= PARSENAME(REPLACE( OwnerAddress, ',' , '.' ) ,1);


				-- change Y & N to Yes & No in SoldAsVacant 

select DISTINCT(SoldAsVacant), count(SoldAsVacant)
from portfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant 
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from portfolioProject.dbo.NashvilleHousing
UPDATE NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end


	   -- remove duplicates
-- standard  practice, don't remove data

-- also lets say if paracelid, property address, saledate, saleprice, legalreferance are same, then that row of information is a duplicate
with RowNumCTE AS(
select *,
	ROW_NUMBER() over(
	partition by ParcelID, 
					SaleDate, 
					SalePrice, 
					LegalReference, 
					PropertyAddress
					order by 
						UniqueID 
						) row_num
	--ROW_NUMBER() explanantion --https://www.sqlservertutorial.net/sql-server-window-functions/sql-server-row_number-function/'
from portfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
delete
--select *
FROM RowNumCTE
WHERE row_num > 1   -- gives duplicate



		--remove unused columns
select *
from portfolioProject.dbo.NashvilleHousing

alter table portfolioProject.dbo.NashvilleHousing
drop column SaleDate, OwnerAddress, TaxDistrict, PropertyAddress, 