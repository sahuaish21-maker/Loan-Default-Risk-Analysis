-- =====================================================
-- PROJECT: LOAN DEFAULT RISK ANALYSIS
-- FILE: 02_Loan_Risk_Analysis.sql
-- PURPOSE: Identify factors associated with charge-offs
-- =====================================================

USE loan_default_analysis;

-- Charge-off rate = Charged Off / Resolved Loans * 100
-- Resolved Loans = Fully Paid + Charged Off



-- Analyze charge-off rate by loan grade.
SELECT
    grade,
    COUNT(*) AS total_loans,
    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),   
        2
    ) AS default_rate
FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
GROUP BY grade
ORDER BY grade;


-- Analyze charge-off rate by annual income group.
SELECT
    CASE
        WHEN annual_inc < 30000 THEN 'Below 30K'
        WHEN annual_inc < 60000 THEN '30K-60K'
        WHEN annual_inc < 100000 THEN '60K-100K'
        ELSE '100K+'
    END AS income_group,

    COUNT(*) AS total_loans,

    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate

FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
  AND annual_inc > 0

GROUP BY income_group
ORDER BY MIN(annual_inc);

-- Analyze charge-off rate by DTI group.( %age of monthly income used to pay monthly debt)
SELECT
    CASE
        WHEN dti < 10 THEN 'Below 10%'
        WHEN dti < 20 THEN '10-20%'
        WHEN dti < 30 THEN '20-30%'
        ELSE '30%+'
    END AS dti_group,

    COUNT(*) AS total_loans,

    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate

FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
  AND dti > 0

GROUP BY dti_group
ORDER BY MIN(dti);


-- Analyze charge-off rate by FICO score group.
SELECT
    CASE
        WHEN fico_range_low < 670 THEN 'Below 670'
        WHEN fico_range_low < 740 THEN '670-739'
        WHEN fico_range_low < 800 THEN '740-799'
        ELSE '800+'
    END AS fico_group,

    COUNT(*) AS total_loans,

    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate

FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
  AND fico_range_low > 0

GROUP BY fico_group
ORDER BY MIN(fico_range_low);
-- Finding: Lower FICO scores are associated with higher charge-off rates.


-- Analyze charge-off rate by interest rate group.
SELECT
    CASE
        WHEN int_rate < 10 THEN 'Below 10%'
        WHEN int_rate < 15 THEN '10-15%'
        WHEN int_rate < 20 THEN '15-20%'
        ELSE '20%+'
    END AS interest_group,

    COUNT(*) AS total_loans,

    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate

FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
  AND int_rate > 0

GROUP BY interest_group
ORDER BY MIN(int_rate);


-- Analyze charge-off rate by loan term.
SELECT
    term,
    COUNT(*) AS total_loans,
    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate
FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
GROUP BY term
ORDER BY term;
-- Finding: 60-month loans have higher charge-off rates than 36-month loans.




-- Analyze charge-off rate by loan purpose.
SELECT
    purpose,
    COUNT(*) AS total_loans,
    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate
FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
GROUP BY purpose
ORDER BY default_rate DESC;


-- Analyze charge-off rate by loan year.
SELECT
    RIGHT(issue_d, 4) AS loan_year,
    COUNT(*) AS total_loans,
    ROUND(100 * SUM(loan_status = 'Charged Off') / COUNT(*), 2) AS default_rate
FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
GROUP BY loan_year
ORDER BY loan_year;

-- Analyze charge-off rate by loan amount.
SELECT
    CASE
        WHEN loan_amnt < 10000 THEN 'Below 10K'
        WHEN loan_amnt < 20000 THEN '10K-20K'
        WHEN loan_amnt < 30000 THEN '20K-30K'
        ELSE '30K+'
    END AS loan_group,

    COUNT(*) AS total_loans,

    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate

FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
GROUP BY loan_group
ORDER BY MIN(loan_amnt);

-- Analyze charge-off rate by home ownership.
SELECT
    home_ownership,
    COUNT(*) AS total_loans,
    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate
FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
GROUP BY home_ownership
ORDER by min(home_ownership);

-- Analyze charge-off rate by employment length.
SELECT
    emp_length,
    COUNT(*) AS total_loans,
    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate
FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
  AND emp_length <> ''
GROUP BY emp_length
ORDER BY default_rate DESC;


-- Analyze charge-off rate by borrower state.
SELECT
    addr_state,
    COUNT(*) AS total_loans,
    ROUND(
        100 * SUM(loan_status = 'Charged Off') / COUNT(*),
        2
    ) AS default_rate
FROM loan_default_analysis.loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
GROUP BY addr_state
ORDER BY default_rate DESC;


-- =====================================================
-- KEY BUSINESS FINDINGS
-- =====================================================

-- 1. Loan grade: Charge-off rates increase from Grade A to G.
-- 2. Income: Higher-income borrowers show lower charge-off rates.
-- 3. DTI: Higher DTI is associated with higher charge-off rates.
-- 4. FICO: Higher credit scores are associated with lower risk.
-- 5. Interest rate: Higher-rate loans show more charge-offs.
-- 6. Loan term: 60-month loans have higher charge-off rates.
-- 7. Loan purpose: Small-business loans have the highest observed rate.
-- 8. Loan year: Rates vary across origination years.
-- 9. Loan amount: Larger loans show higher charge-off rates.
-- 10. Home ownership: Renters show higher rates than mortgage borrowers.
-- 11. Employment: Longer employment shows a weak association with lower risk.
-- 12. Geography: Mississippi has the highest observed state rate.

-- NOTE: These are associations, not proof of causation.
-- Recent loan years may be biased by unresolved loans.