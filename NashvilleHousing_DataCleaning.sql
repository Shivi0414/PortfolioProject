/*Cleaning NashVille Housing Data Using SQL */

select * from NashvilleHousing;
select count(*) from NashvilleHousing;

--Check Date Standards.

Select convert(date,saledate) as SaleDateConverted from dbo.NashvilleHousing;
update dbo.NashvilleHousing
set saledate=convert(date,saledate);

--or if trouble with update

Alter table NashvilleHousing
Add SaleDateConverted Date;

update dbo.NashvilleHousing
set SaleDateConverted=convert(date,saledate)

---Populate cleaned property address data

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select T1.UniqueID,T1.ParcelID,T1.PropertyAddress,T2.ParcelID,T2.PropertyAddress,
ISNULL(T1.PropertyAddress,T2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing T1, PortfolioProject.dbo.NashvilleHousing T2
Where T1.ParcelID = T2.ParcelID and T1.UniqueID <> T2.UniqueID
and T1.PropertyAddress is null

Update T1
set PropertyAddress = ISNULL(T1.PropertyAddress,T2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing T1, PortfolioProject.dbo.NashvilleHousing T2
Where T1.ParcelID = T2.ParcelID and T1.UniqueID <> T2.UniqueID
and T1.PropertyAddress is null

-- Splitting address into individual columns (Address , city , state)

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID;

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);
update dbo.NashvilleHousing
set PropertySplitAddress=
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1)


alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);
update dbo.NashvilleHousing
set PropertySplitCity=
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))


-- Splitting owner's address into individual columns (Address , city , state) without substr,charindex

Select * From PortfolioProject.dbo.NashvilleHousing;
Select OwnerAddress From PortfolioProject.dbo.NashvilleHousing;

select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from NashvilleHousing;

alter table PortfolioProject.dbo.NashvilleHousing
add ownersplitaddress nvarchar(255);
update dbo.NashvilleHousing
set ownersplitaddress= PARSENAME(replace(owneraddress,',','.'),3);


alter table PortfolioProject.dbo.NashvilleHousing
add ownersplitcity nvarchar(255);
update dbo.NashvilleHousing
set ownersplitcity= PARSENAME(replace(owneraddress,',','.'),2);

alter table PortfolioProject.dbo.NashvilleHousing
add ownersplitstate nvarchar(255);
update dbo.NashvilleHousing
set ownersplitstate=PARSENAME(replace(owneraddress,',','.'),1);

-- change Y to Yes and N to No in 'SoldasVacant' field

select Distinct SoldAsVacant,Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant order by 2;

select SoldAsVacant,
CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END
from NashvilleHousing order by 2;

update NashvilleHousing set SoldAsVacant=
CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END;


--Removing Duplicates
with cte as(
select *,
ROW_NUMBER() over(
   Partition by ParcelId,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By UniqueID ) as rownum
from NashvilleHousing )
select * from cte where rownum>1;  -- check dups
--delete from cte where rownum>1;  -- remove dups

-----Remove unused columns

Select * From PortfolioProject.dbo.NashvilleHousing;

alter table NashvilleHousing
drop column TaxDistrict,SaleDate;