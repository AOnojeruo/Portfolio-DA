
/*Cleaning  in SQL */
Select *
From Project.dbo.[Nashville Housing Data for Data Cleaning]

-- Standardise Date Format 
/*coverting from sale date from date/time  to just the date for ease of readibility */


Select saleDate, CONVERT(Date,SaleDate)
From Project.dbo.[Nashville Housing Data for Data Cleaning]


Update dbo.[Nashville Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date,SaleDate)

-- Adjusting property address column.
/*each unique parcle id corresponds to a specific address. however, some addresses are missing but can be linked to an adress throughtheir unique parcel id.
we are filling in  missing addresses associated with their unique parel id */

Select *
From Project.dbo.[Nashville Housing Data for Data Cleaning]
--Where PropertyAddress is null
order by ParcelID


--SELF JOIN if parcel id is the same but unique id is different then populate the missing value with the existing address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Project.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN Project.dbo.[Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- updating table to add amendments 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From project.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN Project.dbo.[Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null



-- seperating  Address into seperate  Columns Address/City/State


Select PropertyAddress
From Project.dbo.[Nashville Housing Data for Data Cleaning]
--Where PropertyAddress is null
--order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Project.dbo.[Nashville Housing Data for Data Cleaning]


ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
Add PropertySplitAddress Nvarchar(255);

Update Project.dbo.[Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
Add PropertySplitCity Nvarchar(255);

Update Project.dbo.[Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



--now we have specific columns with the the seperated  address and city 
Select *
From Project.dbo.[Nashville Housing Data for Data Cleaning]





Select OwnerAddress
From Project.dbo.[Nashville Housing Data for Data Cleaning]

--using PARSENAME to separate owner address by delimeter

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Project.dbo.[Nashville Housing Data for Data Cleaning]



ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
Add OwnerSplitAddress Nvarchar(255);

Update Project.dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
Add OwnerSplitCity Nvarchar(255);

Update Project.dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
Add OwnerSplitState Nvarchar(255);

Update Project.dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



--Select *
--From Project.dbo.[Nashville Housing Data for Data Cleaning]






-- we want to Change 1 and 0  to Yes and No in "Sold as Vacant" field for ease of readability 


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant
order by 2


/*select UpdatedSoldAsVacant,SoldAsVacant
from [Nashville Housing Data for Data Cleaning]*/


Select Distinct(UpdatedSoldAsVacant), Count(UpdatedSoldAsVacant)
From [Nashville Housing Data for Data Cleaning]
Group by UpdatedSoldAsVacant
order by 2

-- adding a new column where 1 repesents yes and 0 repersent no 
alter table [Nashville Housing Data for Data Cleaning]
add UpdatedSoldAsVacant varchar(3)

update [Nashville Housing Data for Data Cleaning]
set  UpdatedSoldAsVacant = case 
when soldasvacant = 1 then 'Yes'
when soldasvacant = 0 then 'No'
else null
end 


