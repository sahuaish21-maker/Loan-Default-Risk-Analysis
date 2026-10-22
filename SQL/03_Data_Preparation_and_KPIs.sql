-- =====================================================
-- PROJECT: LOAN DEFAULT RISK ANALYSIS
-- FILE: 03_Data_Preparation_and_KPIs.sql
-- PURPOSE: Prepare validated loan data for Power BI
-- =====================================================

USE loan_default_analysis;




-- Check total records and duplicate loan IDs.
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT id) AS unique_ids,
    COUNT(*) - COUNT(DISTINCT id) AS duplicate_ids,
    SUM(id IS NULL) AS missing_ids
FROM loan_default_analysis.loan_data;


-- Create a view for Power BI analysis.
CREATE OR REPLACE VIEW loan_default_analysis.vw_loan_dashboard AS
SELECT
    id,
    loan_amnt,
    term,
    int_rate,
    grade,
    annual_inc,
    dti,
    loan_status,
    purpose,
    issue_d,
    fico_range_low,
    fico_range_high,
    home_ownership,
    emp_length,
    addr_state
FROM loan_default_analysis.loan_data;


# 3 calculated column from existing data
-- extract loan year - issue_year

SELECT
    issue_d,
    RIGHT(issue_d, 4) AS issue_year
FROM loan_default_analysis.loan_data
LIMIT 10;


-- Calculate the midpoint of the FICO score range.
SELECT
    fico_range_low,
    fico_range_high,
    (fico_range_low + fico_range_high) / 2 AS fico_avg
FROM loan_default_analysis.loan_data
LIMIT 10;

-- Classify loans based on repayment status.
SELECT
    loan_status,
    CASE
        WHEN loan_status = 'Charged Off' THEN 'Charged Off'
        WHEN loan_status = 'Fully Paid' THEN 'Fully Paid'
        ELSE 'Other Status'
    END AS loan_outcome
FROM loan_default_analysis.loan_data
LIMIT 20;

-- Update reporting view with 3 calculated columns.
CREATE OR REPLACE VIEW loan_default_analysis.vw_loan_dashboard AS

SELECT
    *,
    RIGHT(issue_d, 4) AS issue_year,
    (fico_range_low + fico_range_high) / 2 AS fico_avg,

    CASE
        WHEN loan_status = 'Charged Off' THEN 'Charged Off'
        WHEN loan_status = 'Fully Paid' THEN 'Fully Paid'
        ELSE 'Other Status'
    END AS loan_outcome

FROM loan_default_analysis.loan_data;


-- Check the updated reporting view.
SELECT *
FROM loan_default_analysis.vw_loan_dashboard
LIMIT 10;


-- Check data quality in the final reporting view.
SELECT
    COUNT(*) AS total_loans,
    SUM(loan_amnt <= 0 OR loan_amnt IS NULL) AS invalid_loan_amount,
    SUM(annual_inc <= 0 OR annual_inc IS NULL) AS invalid_income,
    SUM(dti <= 0 OR dti IS NULL) AS zero_or_missing_dti,
    SUM(grade IS NULL OR grade = '') AS missing_grade,
    SUM(issue_year IS NULL OR issue_year NOT REGEXP '^[0-9]{4}$')
        AS invalid_issue_year
FROM loan_default_analysis.vw_loan_dashboard;


-- Check zero, negative and missing income and DTI values.
SELECT
    SUM(annual_inc = 0) AS zero_income,
    SUM(annual_inc < 0) AS negative_income,
    COUNT(*) - COUNT(annual_inc) AS missing_income,

    SUM(dti = 0) AS zero_dti,
    SUM(dti < 0) AS negative_dti,
    COUNT(*) - COUNT(dti) AS missing_dti

FROM loan_default_analysis.vw_loan_dashboard;


-- Check cleaned annual income values.
SELECT
    annual_inc,
    CASE
        WHEN annual_inc <= 0 THEN NULL
        ELSE annual_inc
    END AS annual_inc_clean
FROM loan_default_analysis.vw_loan_dashboard
WHERE annual_inc <= 0
LIMIT 10;


-- Create final cleaned reporting view for Power BI.
CREATE OR REPLACE VIEW loan_default_analysis.vw_loan_dashboard AS
SELECT
    *,
    RIGHT(issue_d, 4) AS issue_year,
    (fico_range_low + fico_range_high) / 2 AS fico_avg,

    CASE
        WHEN loan_status = 'Charged Off' THEN 'Charged Off'
        WHEN loan_status = 'Fully Paid' THEN 'Fully Paid'
        ELSE 'Other Status'
    END AS loan_outcome,

    CASE
        WHEN annual_inc <= 0 THEN NULL
        ELSE annual_inc
    END AS annual_inc_clean,

    CASE
        WHEN dti < 0 THEN NULL
        ELSE dti
    END AS dti_clean

FROM loan_default_analysis.loan_data;


-- Check final reporting view.
SELECT *
FROM loan_default_analysis.vw_loan_dashboard
LIMIT 10;

-- Calculate the main KPIs for the Power BI dashboard.
SELECT
    COUNT(*) AS total_loans,

    SUM(loan_status IN ('Fully Paid', 'Charged Off'))
        AS resolved_loans,

    SUM(loan_status = 'Charged Off')
        AS charged_off_loans,

    ROUND(
        100 * SUM(loan_status = 'Charged Off') /
        NULLIF(SUM(loan_status IN ('Fully Paid', 'Charged Off')), 0),
        2
    ) AS charge_off_rate

FROM loan_default_analysis.vw_loan_dashboard;




-- =====================================================
-- 6. KEY FINDINGS & BUSINESS INSIGHTS
-- =====================================================

-- DATA QUALITY FINDINGS

-- 1. The dataset contains 2,260,668 loan records.
-- 2. No duplicate or missing loan IDs were found.
-- 3. No invalid loan amounts or missing loan grades were found.
-- 4. 1,671 records have zero annual income.
-- 5. 3,443 records have zero DTI and 2 have negative DTI.
-- 6. All extracted loan issue years passed validation.

-- DATA PREPARATION FINDINGS

-- 7. Created a SQL reporting view with 20 columns.
-- 8. Extracted issue year and calculated FICO midpoint.
-- 9. Classified loans using CASE WHEN.
-- 10. Cleaned nonpositive income and negative DTI values
--     in the reporting view without modifying original data.

-- DASHBOARD KPI FINDINGS

-- 11. Total Loans: 2,260,668
-- 12. Resolved Loans: 1,345,310
-- 13. Charged-off Loans: 268,559
-- 14. Charge-off Rate: 19.96%

-- BUSINESS CONCLUSION

-- Approximately 19.96% of resolved loans were charged off.
-- This rate excludes loans without a resolved outcome.
-- The reporting view is prepared for Power BI analysis.

-- DATA LIMITATION

-- Some zero income and DTI values may represent missing
-- information converted to zero during CSV import.
