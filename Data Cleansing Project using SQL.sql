/*
Cleaning the data using SQL
*/

Select * from project.dbo.Nashville;

---------------------------------------------------------------------------------------------------------------

-- Standardizing Date Format


Select
SaleDate, convert(date, SaleDate) saledate1
from project.dbo.Nashville

alter table Nashville
add SaleDateConverted date;

update Nashville
set SaleDateConverted = convert(date, SaleDate);

Select
SaleDate, SaleDateConverted
from project..Nashville
---------------------------------------------------------------------------------------------------------------

-- Populating Property Address


Select * from project..Nashville
-- where PropertyAddress is NULL
order by ParcelID;

select
n1.parcelID, n1.PropertyAddress, n2.parcelID, n2.PropertyAddress ,
isnull(n1.PropertyAddress, n2.PropertyAddress)
from project..Nashville n1
join project..Nashville n2 on n1.parcelID = n2.parcelID
 and n1.UniqueID != n2.UniqueID
Where n1.PropertyAddress is null;

Update n1
Set PropertyAddress = isnull(n1.PropertyAddress, n2.PropertyAddress)
from project..Nashville n1
join project..Nashville n2 on n1.parcelID = n2.parcelID
 and n1.UniqueID != n2.UniqueID

 -- Breaking out address into individual columns (address, city, states)

-- Breaking PropertyAddress
 Select PropertyAddress 
 from project..Nashville
-- where PropertyAddress is NULL
order by ParcelID;

-- using substring to breakdown
select 
PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
from project..Nashville
-- used CHARINDEX to find the index value of ',' in PropertyAddress Column

--adding columns (address and city)

alter table Nashville
add PropertSplitAddress Nvarchar(255);

update Nashville
set PropertSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

alter table Nashville
add PropertSplitCity Nvarchar(255);

update Nashville
set PropertSplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress));

-- showing updated changes
select * from project..Nashville

-- Breaking OwnerAddress (using Parsename function)
select OwnerAddress from project..Nashville;

select 
	OwnerAddress,
	PARSENAME(replace(OwnerAddress,',','.'),3),
	PARSENAME(replace(OwnerAddress,',','.'),2),
	PARSENAME(replace(OwnerAddress,',','.'),1) 
from project..Nashville

-- Creating new columns
alter table Nashville
add OwnerSplitAddress Nvarchar(255);

update Nashville
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3);

alter table Nashville
add OwnerSplitCity Nvarchar(255);

update Nashville
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2);

alter table Nashville
add OwnerSplitState Nvarchar(255);

update Nashville
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

Select * from project..Nashville

---------------------------------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No in 'Sold as vacant' field


Select distinct SoldAsVacant, count(SoldAsVacant) 
from project..Nashville 
group by SoldAsVacant
order by 2;

Select distinct 
	SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
		 WHEN SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
	END as SoldAsVacant_updated
from project..Nashville

update Nashville
set SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
						 WHEN SoldAsVacant = 'N' Then 'No'
						 ELSE SoldAsVacant END;

Select Distinct SoldAsVacant from project..Nashville

---------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


with RowNumCTE as(
Select
	 ROW_NUMBER() over (partition by ParcelID, 
									 PropertyAddress, 
									 SalePrice, 
									 SaleDate, 
									 LegalReference 
									 order by UniqueID) Row_num,
	 *
from Project..Nashville
)
--select * from RowNumCTE where Row_num > 1

-- Deleing duplicates
Delete from RowNumCTE 
where Row_num > 1;

---------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns 


Select * from project..Nashville;

Alter Table project..Nashville
drop column PropertyAddress, OwnerAddress, TaxDistrict;

Alter Table project..Nashville
drop column SaleDate;

select * from project..Nashville