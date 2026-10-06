-- Run: docker cp hive_queries.sql hive-server:/tmp/hive_queries.sql
--      docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -f /tmp/hive_queries.sql
CREATE DATABASE IF NOT EXISTS healthcare_analytics;
USE healthcare_analytics;

CREATE EXTERNAL TABLE IF NOT EXISTS patients (
    age INT,
    sex STRING,
    chest_pain_type STRING,
    resting_bp INT,
    cholesterol INT,
    fasting_bs INT,
    resting_ecg STRING,
    max_hr INT,
    exercise_angina STRING,
    oldpeak DOUBLE,
    st_slope STRING,
    heart_disease INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/healthcare/raw'
TBLPROPERTIES ('skip.header.line.count'='1');

SHOW TABLES;
SELECT * FROM patients LIMIT 10;

-- Q1 Overall disease prevalence
SELECT COUNT(*) AS total_patients,
       SUM(heart_disease) AS disease_cases,
       ROUND(100.0 * SUM(heart_disease) / COUNT(*), 2) AS disease_percentage
FROM patients;

-- Q2 Disease rate by sex
SELECT sex, COUNT(*) AS patients,
       ROUND(100.0 * AVG(heart_disease), 2) AS disease_percentage
FROM patients GROUP BY sex ORDER BY disease_percentage DESC;

-- Q3 Disease rate by age group
SELECT CASE WHEN age < 40 THEN '1. Under 40'
            WHEN age < 50 THEN '2. 40-49'
            WHEN age < 60 THEN '3. 50-59'
            ELSE '4. 60+' END AS age_group,
       COUNT(*) AS patients,
       ROUND(100.0 * AVG(heart_disease), 2) AS disease_percentage
FROM patients GROUP BY CASE WHEN age < 40 THEN '1. Under 40'
            WHEN age < 50 THEN '2. 40-49'
            WHEN age < 60 THEN '3. 50-59'
            ELSE '4. 60+' END
ORDER BY age_group;

-- Q4 Chest pain type
SELECT chest_pain_type, COUNT(*) AS patients,
       ROUND(100.0 * AVG(heart_disease), 2) AS disease_percentage
FROM patients GROUP BY chest_pain_type ORDER BY disease_percentage DESC;

-- Q5 Exercise-induced angina and ST slope
SELECT exercise_angina, st_slope, COUNT(*) AS patients,
       ROUND(100.0 * AVG(heart_disease), 2) AS disease_percentage
FROM patients GROUP BY exercise_angina, st_slope ORDER BY disease_percentage DESC;

-- Q6 Average clinical measures: disease vs no disease
SELECT heart_disease, COUNT(*) AS patients,
       ROUND(AVG(age),1) AS avg_age, ROUND(AVG(resting_bp),1) AS avg_bp,
       ROUND(AVG(max_hr),1) AS avg_max_hr, ROUND(AVG(oldpeak),2) AS avg_oldpeak
FROM patients GROUP BY heart_disease;

-- Q7 Data quality: invalid zero values
SELECT SUM(CASE WHEN cholesterol = 0 THEN 1 ELSE 0 END) AS zero_cholesterol,
       SUM(CASE WHEN resting_bp = 0 THEN 1 ELSE 0 END) AS zero_resting_bp
FROM patients;

-- Q8 Window function: rank chest-pain types by disease rate within each sex
SELECT sex, chest_pain_type, disease_percentage,
       RANK() OVER (PARTITION BY sex ORDER BY disease_percentage DESC) AS rank_in_sex
FROM (SELECT sex, chest_pain_type,
             ROUND(100.0 * AVG(heart_disease), 2) AS disease_percentage
      FROM patients GROUP BY sex, chest_pain_type) t;

-- Q9 Save a summary as a managed Hive table
CREATE TABLE IF NOT EXISTS chest_pain_summary AS
SELECT chest_pain_type, COUNT(*) AS patients,
       ROUND(100.0 * AVG(heart_disease), 2) AS disease_percentage
FROM patients GROUP BY chest_pain_type;
SELECT * FROM chest_pain_summary;
