--just checking the data

select * 
from [Projects].[dbo].[NashvilleHousing]

--taking off the useless time at the end 
--from SaleDate

select SaleDate
from [Projects].[dbo].[NashvilleHousing]

select SaleDate, CONVERT(date, SaleDate)
from [Projects].[dbo].[NashvilleHousing]

--Didn't work -_-
Update  [Projects].[dbo].[NashvilleHousing]
set SaleDate = CONVERT(date, SaleDate)

--Altering by adding an extra column with date
--as the data type
--then put the converted SaleDate in it

alter table [dbo].[NashvilleHousing]
add SaleDateConverted date;

update [Projects].[dbo].[NashvilleHousing]
set SaleDateConverted=CONVERT(date, SaleDate)

select SaleDateConverted
from [Projects].[dbo].[NashvilleHousing]

--it worked

-------------------------------

--populate property address
select *
from [Projects].[dbo].[NashvilleHousing]
--where [PropertyAddress] is null 
order by [ParcelID]

--  we want to populate the null address in property address 
-- we noticed if the [ParcelID] the [[PropertyAddress]] address is the same 
-- so we populate the null with the filled [PropertyAddress] 
-- we check for the 'isNull' to see the resulted column 

select a.[ParcelID],a.[PropertyAddress],b.[ParcelID],b.[PropertyAddress], ISNULL(a.[PropertyAddress],b.[PropertyAddress])
from [Projects].[dbo].[NashvilleHousing] a
join [Projects].[dbo].[NashvilleHousing] b
on a.[ParcelID]=b.[ParcelID]
and a.[UniqueID ]  <> b.[UniqueID ]
where a.[PropertyAddress] is null 


-- now we update the table to result in the extra column we made 
--note to self: when ur updating WITH A JOIN use the alias

update a
set [PropertyAddress] =ISNULL(a.[PropertyAddress],b.[PropertyAddress])
from [Projects].[dbo].[NashvilleHousing] a
join [Projects].[dbo].[NashvilleHousing] b
on a.[ParcelID]=b.[ParcelID] and a.[UniqueID ]  <> b.[UniqueID ]
where a.[PropertyAddress] is null 
 

------------------------
-- Breaking out the address into individual cols (address, city , state )


select SUBSTRING([PropertyAddress], 1, CHARINDEX(',',[PropertyAddress])-1) as address,
SUBSTRING([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1, LEN([PropertyAddress])) as address
from [Projects].[dbo].[NashvilleHousing]

alter table [Projects].[dbo].[NashvilleHousing]
add proprtySplitAddress nvarchar(255);

update [Projects].[dbo].[NashvilleHousing]
set proprtySplitAddress=SUBSTRING([PropertyAddress], 1, CHARINDEX(',',[PropertyAddress])-1)

alter table [Projects].[dbo].[NashvilleHousing]
add proprtySplitCity nvarchar(255)

update [Projects].[dbo].[NashvilleHousing]
set proprtySplitCity = SUBSTRING([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1, LEN([PropertyAddress]))

select proprtySplitCity 
from [Projects].[dbo].[NashvilleHousing ]

select [OwnerAddress]
from [Projects].[dbo].[NashvilleHousing ]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Projects].[dbo].[NashvilleHousing]

ALTER TABLE [Projects].[dbo].[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update [Projects].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Projects].[dbo].[NashvilleHousing]
ADD OwnerSplitState Nvarchar(255);

update [Projects].[dbo].[NashvilleHousing] 
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Projects].[dbo].[NashvilleHousing]
ADD OwnerSplitCity Nvarchar(255);

update [Projects].[dbo].[NashvilleHousing] 
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select OwnerSplitCity,OwnerSplitState, OwnerSplitAddress
from [Projects].[dbo].[NashvilleHousing]

select distinct(SoldAsVacant), COUNT(SoldAsVacant) as count1
from [Projects].[dbo].[NashvilleHousing]
group by SoldAsVacant
order by 2

select SoldAsVacant, 
	CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
		END
from [Projects].[dbo].[NashvilleHousing]

------------------------------------

-- lets remove dublicates 
-- we used a CTE to check for the dublicate rows 
-- how?
-- we used the window function row_number to split/partition  the 
-- rows according to a set of other similar rows 
-- eventully we delete the extra rows (rows above 1) since they would be dublicates  

WITH RowNumCTE AS(
	select *, 
	row_number() over (
		partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate, 
					LegalReference
					order by 
					UniqueID ) row_no
	from [Projects].[dbo].[NashvilleHousing]

	)
Delete 
from RowNumCTE
where row_num > 1
--order by PropertyAddress

------------

-- remove unused cols 
-- since we changed some columns & added them to the DB
-- we can remove the main ones 
select * 
from [Projects].[dbo].[NashvilleHousing]

ALTER TABLE [Projects].[dbo].[NashvilleHousing]
drop column PropertyAddress, TaxDistrict , OwnerAddress, SaleDate

