SELECT *
FROM DataCleaningProject..NashvilleHousing


--Standardize Sale Date Format


SELECT SaleDate2, CONVERT(DATE,SaleDate)
FROM dbo.NashvilleHousing

UPDATE DataCleaningProject..NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDate2 DATE;

UPDATE DataCleaningProject..NashvilleHousing
SET SaleDate2 = CONVERT(DATE,SaleDate)

--


--populate property Address


SELECT *
FROM dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--(29 NULL property addresses)

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM dbo.NashvilleHousing A
JOIN dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM dbo.NashvilleHousing A
JOIN dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--


--Breaking Address into individual Columns (Address, City, States)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS address

FROM DataCleaningProject..NashvilleHousing


ALTER TABLE DataCleaningProject..NashvilleHousing
ADD Address nVARCHAR(255);

UPDATE DataCleaningProject..NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE DataCleaningProject..NashvilleHousing
ADD City nVARCHAR(255);

UPDATE DataCleaningProject..NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))




SELECT
OwnerAddress
FROM DataCleaningProject..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaningProject..NashvilleHousing


ALTER TABLE DataCleaningProject..NashvilleHousing
ADD OwnerSPLITAddress nVARCHAR(255);

UPDATE DataCleaningProject..NashvilleHousing
SET OwnerSPLITAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE DataCleaningProject..NashvilleHousing
ADD OwnerSPLITCity nVARCHAR(255);

UPDATE DataCleaningProject..NashvilleHousing
SET OwnerSPLITCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE DataCleaningProject..NashvilleHousing
ADD OwnerSPLITState nVARCHAR(255);

UPDATE DataCleaningProject..NashvilleHousing
SET OwnerSPLITState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




-- Change Y and N to Yes and NO in "Sold as Vacant" field


SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant) DESC


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM DataCleaningProject..NashvilleHousing

UPDATE DataCleaningProject..NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END



--Removing Duplicates

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
					)row_num
FROM DataCleaningProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- Delete Unused Columns (Not From The Raw Data of course)


SELECT *
FROM DataCleaningProject..NashvilleHousing

ALTER TABLE DataCleaningProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
