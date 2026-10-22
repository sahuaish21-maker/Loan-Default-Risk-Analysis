-- =====================================================
-- PROJECT: LOAN DEFAULT RISK ANALYSIS
-- DATA VALIDATION, CLEANING & EXPLORATORY ANALYSIS
-- =====================================================

USE loan_default_analysis;


-- =====================================================
-- 1. DATA VALIDATION
-- =====================================================

-- Check total number of loan records
SELECT COUNT(*) AS total_rows
FROM loan_default_analysis.loan_data;

-- Check records with missing loan IDs.
SELECT
    COUNT(*) AS total_rows,
    COUNT(id) AS records_with_id,
    COUNT(*) - COUNT(id) AS records_without_id
FROM loan_default_analysis.loan_data;

-- Identify invalid loan IDs.
SELECT COUNT(*) AS invalid_ids
FROM loan_default_analysis.loan_data
WHERE id = 0;

-- Inspect records containing invalid IDs.
SELECT
    id,
    loan_amnt,
    loan_status,
    annual_inc,
    dti,
    issue_d
FROM loan_default_analysis.loan_data
WHERE id = 0
LIMIT 10;

SELECT * 
FROM loan_default_analysis.loan_data 
WHERE id = 0 LIMIT 10;

-- Check whether invalid records contain meaningful data.
SELECT *
FROM loan_default_analysis.loan_data
WHERE id = 0
AND (loan_amnt > 0 OR loan_status <> '');

#DELETE FROM loan_default_analysis.loan_data
#WHERE id = 0;

-- Remove 33 invalid records after validation.
-- DELETE FROM loan_data
-- WHERE id = 0;

-- =====================================================
-- 3. DATA QUALITY ASSESSMENT
-- =====================================================

-- Identify missing and zero DTI values

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(dti) AS missing_dti,
    SUM(dti = 0) AS zero_dti
FROM loan_data;

-- =====================================================
-- 4. EXPLORATORY DATA ANALYSIS
-- =====================================================

-- Analyze the distribution of loan statuses

SELECT loan_status, COUNT(*)
FROM loan_data
GROUP BY loan_status;

-- =====================================================
-- 5. LOAN DEFAULT RISK ANALYSIS
-- =====================================================

-- Calculate charge-off rate among resolved loans.
SELECT
    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate
FROM loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off');

-- Check missing values in important columns.
SELECT
    COUNT(*) - COUNT(annual_inc) AS missing_income,
    COUNT(*) - COUNT(dti) AS missing_dti,
    COUNT(*) - COUNT(grade) AS missing_grade
FROM loan_data;

-- Identify zero values in numeric columns.
SELECT
    SUM(annual_inc = 0) AS zero_income,
    SUM(dti = 0) AS zero_dti,
    SUM(loan_amnt = 0) AS zero_loan
FROM loan_data;


-- Check blank loan grades.
SELECT COUNT(*) AS blank_grades
FROM loan_data
WHERE grade = '';



-- =====================================================
-- 6. KEY FINDINGS & DATA QUALITY INSIGHTS
-- =====================================================

-- 1. The original dataset contained 2,260,701 records.

-- 2. Identified 33 invalid footer records with loan ID = 0.

-- 3. Removed 33 invalid records after confirming
--    they contained no meaningful loan information.

-- 4. Final dataset contains 2,260,668 loan records.

-- 5. No missing or duplicate loan IDs remain.

-- 6. No missing loan grades were found.

-- 7. Identified 1,671 records with zero annual income.

-- 8. Identified 3,443 records with zero DTI.

-- 9. Loan statuses include Fully Paid, Charged Off,
--    Current and other repayment statuses.

-- 10. The charge-off rate among resolved loans is 19.96%.

-- =====================================================
-- DATA QUALITY CONCLUSION
-- =====================================================

-- The dataset passed key ID and loan amount checks.
-- Zero income and DTI values require careful treatment
-- because some may represent missing imported values.

-- Invalid records were removed without changing
-- valid loan records.


