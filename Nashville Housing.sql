use nashville_housing_data;

## Cleaning data in SQL Queries
SELECT 
    *
FROM
    nashville_housing
    order by ParcelID;
------------------------------------------------------------------------------------

## Standardize date format. Just in case
SELECT 
    SaleDate, convert(SaleDate,date)
FROM
    nashville_housing;
    
UPDATE nashville_housing 
SET 
    SaleDate = CONVERT( SaleDate , DATE);
-------------------------------------------------------------------------------

##Populate Property Addres data
SELECT 
    *
FROM
    nashville_housing
where PropertyAddress is not null
ORDER BY ParcelID;

SELECT 
    a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,length(a.PropertyAddress)
FROM
    nashville_housing a
 join    nashville_housing b
 on a.ParcelID=b.ParcelID
 and a.UniqueID<>b.UniqueID
 ##where length(a.PropertyAddress)=0
 order by a.ParcelID;

/* This work well. Now there is not null rows*/
UPDATE nashville_housing a
        JOIN
    nashville_housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID 
SET 
    a.PropertyAddress = b.PropertyAddress
WHERE
    LENGTH(a.PropertyAddress) = 0;
----------------------------------------------------------------------------------------
##Breaking ou address into Individual Colums

SELECT 
    PropertyAddress
FROM
    nashville_housing;
    
SELECT 
    SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress)) AS City
FROM
    nashville_housing;
    
alter table nashville_housing
add PropertySplitAddress varchar(255);

UPDATE nashville_housing 
SET 
    PropertySplitAddress = SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1);

alter table nashville_housing
add PropertySplitCity varchar(255);

UPDATE nashville_housing 
SET 
    PropertySplitCity = SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress));

SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS adress,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1) AS city,
   SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM
    nashville_housing;
    
alter table nashville_housing
add OwnerSplitAddress varchar(255);

UPDATE nashville_housing 
SET 
   OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

alter table nashville_housing
add OwnerSplitCity varchar(255);

UPDATE nashville_housing 
SET 
  OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1);
            
alter table nashville_housing
add OwnerSplitState varchar(255);

UPDATE nashville_housing 
SET 
   OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT 
    OwnerSplitAddress,  OwnerSplitCity, OwnerSplitState
FROM
    nashville_housing;
---------------------------------------------------------------------------------------------------------------------
##Change Y and N to Yes and No in "Sold as Vacant" field

SELECT 
   distinct(SoldAsVacant), count(SoldAsVacant)
FROM
    nashville_housing
group by SoldAsVacant
order by 2;

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM
    nashville_housing;
    
 Update nashville_housing
 set SoldAsVacant= CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;
---------------------------------------------------------------------------------------------------------
#Remove Duplicates

with RowNumCCT as(
SELECT 
    *,
    row_number() over(
    partition by ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
    order by
    UniqueID) as row_num
FROM
    nashville_housing)
   select*
    from RowNumCCT
    where row_num>1;
    
 /*delted duplicate with my sql sintax*/

delete
from nashville_housing
where  ParcelID in(
select ParcelID
from (SELECT 
    ParcelID,
    row_number() over(
    partition by ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
    order by
    UniqueID) as row_num 
    from nashville_housing) t
where row_num>1);

-----------------------------------------------------------------------------------------------------------------------------------
#Delete Unused Columns

select*
from nashville_housing;

alter table nashville_housing
drop column OwnerAddress,drop column TaxDistrict, drop column PropertyAddress;

alter table nashville_housing
drop column SaleDate;