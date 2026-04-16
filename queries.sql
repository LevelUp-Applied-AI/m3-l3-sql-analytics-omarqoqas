-- Q1: Employee Directory with Departments
SELECT e.first_name, e.last_name, e.title, e.salary, d.name AS department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
ORDER BY d.name ASC, e.salary DESC;

-- Q2: Department Salary Analysis
SELECT d.name AS department_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.name
HAVING SUM(e.salary) > 150000;

-- Q3: Highest-Paid Employee per Department
WITH SalaryRankings AS (
    SELECT 
        d.name AS department_name, 
        e.first_name, 
        e.last_name, 
        e.salary,
        RANK() OVER(PARTITION BY d.department_id ORDER BY e.salary DESC) as rnk
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
)
SELECT department_name, first_name, last_name, salary
FROM SalaryRankings
WHERE rnk = 1;

-- Q4: Project Staffing Overview
SELECT 
    p.name AS project_name, 
    COUNT(pa.employee_id) AS employee_count, 
    COALESCE(SUM(pa.hours_allocated), 0) AS total_hours
FROM projects p
LEFT JOIN project_assignments pa ON p.project_id = pa.project_id
GROUP BY p.project_id, p.name;

-- Q5: Above-Average Departments
WITH CompanyAvg AS (
    SELECT AVG(salary) AS avg_sal FROM employees
),
DeptAvg AS (
    SELECT d.name, AVG(e.salary) AS dept_avg_sal
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    GROUP BY d.name
)
SELECT da.name AS department_name, da.dept_avg_sal, ca.avg_sal AS company_avg
FROM DeptAvg da, CompanyAvg ca
WHERE da.dept_avg_sal > ca.avg_sal;

-- Q6: Running Salary Total
SELECT 
    d.name AS department_name, 
    e.first_name, 
    e.last_name, 
    e.hire_date, 
    e.salary,
    SUM(e.salary) OVER(PARTITION BY d.department_id ORDER BY e.hire_date) AS running_total
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- Q7: Unassigned Employees
SELECT e.first_name, e.last_name, d.name AS department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
WHERE pa.assignment_id IS NULL;

-- Q8: Hiring Trends
SELECT 
    EXTRACT(YEAR FROM hire_date) AS hire_year, 
    EXTRACT(MONTH FROM hire_date) AS hire_month, 
    COUNT(*) AS hires
FROM employees
GROUP BY hire_year, hire_month
ORDER BY hire_year, hire_month;

-- Q9: Schema Design — Employee Certifications
CREATE TABLE certifications (
    certification_id SERIAL PRIMARY KEY, 
    name VARCHAR(255) NOT NULL, 
    issuing_org VARCHAR(255), 
    level VARCHAR(50)
);

CREATE TABLE employee_certifications (
    id SERIAL PRIMARY KEY, 
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id), 
    certification_id INTEGER NOT NULL REFERENCES certifications(certification_id), 
    certification_date DATE NOT NULL
);

INSERT INTO certifications (name, issuing_org, level) VALUES
('AWS Certified Developer', 'Amazon', 'Intermediate'),
('Professional Scrum Master', 'Scrum.org', 'Advanced'),
('Google Data Analytics', 'Google', 'Beginner');

INSERT INTO employee_certifications (employee_id, certification_id, certification_date) VALUES
(1, 1, '2023-05-10'),
(1, 2, '2024-01-15'),
(2, 1, '2023-08-20'),
(4, 2, '2024-03-01'),
(12, 3, '2023-11-12');

SELECT e.first_name, e.last_name, c.name AS certification_name, c.issuing_org, ec.certification_date
FROM employees e
JOIN employee_certifications ec ON e.employee_id = ec.employee_id
JOIN certifications c ON ec.certification_id = c.certification_id;