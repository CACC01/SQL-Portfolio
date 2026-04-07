-- ============================================================
-- Description: Data cleaning, joins, temp tables, CTEs and
--              aggregations on a fictional employee dataset.
-- ============================================================


-- ============================================================
-- 1. INITIAL EXPLORATION
-- ============================================================

SELECT *
FROM dbo.[Práctica - DatosPer];

SELECT *
FROM dbo.[Práctica - Salario];


-- ============================================================
-- 2. DATA CLEANING — Checking & fixing values
-- ============================================================

/* Check distinct Regions for typos */
SELECT Region, COUNT(Region) AS Total
FROM dbo.[Práctica - DatosPer]
GROUP BY Region;

/* Fix typo found in Region (ID = 8 had 'Note' instead of 'Norte') */
UPDATE dbo.[Práctica - DatosPer]
SET Region = 'Norte'
WHERE ID = 8;

/*Consistency*/
UPDATE dbo.[Práctica - DatosPer]
SET Region = 'North'
WHERE Region ='Norte'

UPDATE dbo.[Práctica - DatosPer]
SET Region = 'South'
WHERE Region ='Sur'

UPDATE dbo.[Práctica - DatosPer]
SET Region = 'West'
WHERE Region ='Oeste'

UPDATE dbo.[Práctica - DatosPer]
SET Region = 'East'
WHERE Region ='Este'
/* Verify fix */
SELECT Region, COUNT(Region) AS Total
FROM dbo.[Práctica - DatosPer]
GROUP BY Region;


-- ============================================================
-- 3. CASE STATEMENT
-- ============================================================

SELECT 
    Employee,
    Age,
    CASE 
        WHEN Age BETWEEN 20 AND 29 THEN 'Twenties'
        WHEN Age BETWEEN 30 AND 39 THEN 'Thirties'
        WHEN Age BETWEEN 40 AND 49 THEN 'Forties'
        WHEN Age BETWEEN 50 AND 59 THEN 'Fifties'
    END AS AgeGroup
FROM dbo.[Práctica - DatosPer];


-- ============================================================
-- 4. JOIN — Combining Employees and Salaries tables
-- ============================================================

SELECT 
    e.Employee,
    e.Age,
    e.Region,
    s.Salary,
    s.Department
FROM dbo.[Práctica - DatosPer] e
JOIN dbo.[Práctica - Salario] s
    ON e.ID = s.ID;


-- ============================================================
-- 5. TEMP TABLE — Join result stored for reuse
-- ============================================================

DROP TABLE IF EXISTS #EmployeeData;

CREATE TABLE #EmployeeData (
    Employee    VARCHAR(20),
    Age         INT,
    Region      VARCHAR(20),
    Salary      INT,
    Department  VARCHAR(50)
);

INSERT INTO #EmployeeData
SELECT 
    e.Employee,
    e.Age,
    e.Region,
    s.Salary,
    s.Department
FROM dbo.[Práctica - DatosPer] e
JOIN dbo.[Práctica - Salario] s
    ON e.ID = s.ID;

/* Preview */
SELECT * FROM #EmployeeData;


-- ============================================================
-- 6. SUBQUERY — Average salary by age group
-- ============================================================

SELECT 
    AgeGroup,
    AVG(Salary) AS AvgSalary
FROM (
    SELECT 
        Salary,
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN 'Twenties'
            WHEN Age BETWEEN 30 AND 39 THEN 'Thirties'
            WHEN Age BETWEEN 40 AND 49 THEN 'Forties'
            WHEN Age BETWEEN 50 AND 59 THEN 'Fifties'
        END AS AgeGroup
    FROM #EmployeeData
) AS GroupedData
GROUP BY AgeGroup;

/*
Note: The alias 'GroupedData' is required — SQL executes the 
subquery first, so AgeGroup already exists when the outer 
SELECT runs.
*/


-- ============================================================
-- 7. Obtain the same outcome with CTE.
-- ============================================================

WITH EmployeeGroups AS (
    SELECT 
        Employee,
        Salary,
        Age,
        CASE 
            WHEN Age BETWEEN 20 AND 29 THEN 'Twenties'
            WHEN Age BETWEEN 30 AND 39 THEN 'Thirties'
            WHEN Age BETWEEN 40 AND 49 THEN 'Forties'
            WHEN Age BETWEEN 50 AND 59 THEN 'Fifties'
        END AS AgeGroup
    FROM #EmployeeData
)
SELECT 
    AgeGroup,
    AVG(Salary) AS AvgSalary
FROM EmployeeGroups
GROUP BY AgeGroup;


-- ============================================================
-- 8. Permanent Table
-- ============================================================

DROP TABLE IF EXISTS EmployeeData;

SELECT 
    e.Employee,
    e.Age,
    e.Region,
    s.Salary,
    s.Department
INTO EmployeeData
FROM dbo.[Práctica - DatosPer] e
JOIN dbo.[Práctica - Salario] s
    ON e.ID = s.ID;


-- ============================================================
-- 9. Add a gender column for group by analysis.
-- ============================================================

/* Step 1: Add Gender column */
ALTER TABLE dbo.[Práctica - DatosPer]
ADD Gender VARCHAR(10);

/* Step 2: Add values */
UPDATE dbo.[Práctica - DatosPer] SET Gender = 'Male'   WHERE ID IN (1, 3, 4, 5, 7, 8, 9, 10, 12, 13, 15, 16, 19);
UPDATE dbo.[Práctica - DatosPer] SET Gender = 'Female' WHERE ID IN (2, 6, 11, 14, 17, 18 , 20);

/* Average salary by department */
SELECT 
    s.Department,
    AVG(s.Salary) AS AvgSalary,
    COUNT(*) AS EmployeeCount
FROM dbo.[Práctica - DatosPer] e
JOIN dbo.[Práctica - Salario] s
    ON e.ID = s.ID
GROUP BY s.Department
ORDER BY AvgSalary DESC;

/* Average salary by department AND gender */
SELECT 
    s.Department,
    e.Gender,
    AVG(s.Salary) AS AvgSalary,
    COUNT(*) AS EmployeeCount
FROM dbo.[Práctica - DatosPer] e
JOIN dbo.[Práctica - Salario] s
    ON e.ID = s.ID
GROUP BY s.Department, e.Gender
ORDER BY s.Department, e.Gender;