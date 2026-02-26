# MySQL_advanced_projects
This repository contains MySQL queries and explanations covering advanced concepts, including window functions, subqueries, and ranking.

Topics Covered
1. *Window Functions*
    - ROW_NUMBER()
    - RANK()
    - DENSE_RANK()
    - LAG() and LEAD()
2. *Subqueries*
    - Correlated subqueries
    - Uncorrelated subqueries
3. *Ranking and Top N Queries*
    - Get top N records per group
    - Rank employees by salary

Queries
- `SELECT *, ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num FROM employees;` - Assign a row number
- `SELECT *, RANK() OVER (ORDER BY salary DESC) AS salary_rank FROM employees;` - Rank employees by salary
- `SELECT * FROM employees WHERE salary IN (SELECT MAX(salary) FROM employees GROUP BY department);` - Get employees with max salary per department
