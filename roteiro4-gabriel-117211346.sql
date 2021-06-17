--Q1
SELECT * FROM department;

--Q2
SELECT * FROM dependent;

--Q3
SELECT * FROM dept_locations;

--Q4
SELECT * FROM employee;

--Q5
SELECT * FROM project;

--Q6
SELECT * FROM works_on;

--Q7
SELECT fname, lname FROM employee WHERE sex = 'M';

--Q8
SELECT fname FROM employee WHERE superssn IS NULL;

--Q9
SELECT E.fName AS employee_name FROM employee AS E, employee AS D WHERE E.superssn IS NOT NUll AND E.superssn = D.ssn;

--Q10
SELECT E.fName AS employee_name FROM employee AS E, employee AS D WHERE E.superssn is NOT NUll AND E.superssn = D.ssn AND D.fName = 'Franklin';

--Q11
SELECT E.dname AS department_name, D.dlocation AS department_location FROM department AS E, dept_locations AS D WHERE D.dnumber = E.dnumber;

--Q12
SELECT E.dname AS department_name FROM department AS E, dept_locations AS D WHERE D.dnumber = E.dnumber and SUBSTRING(dlocation, 1, 1 ) = 'S';

--Q13
SELECT E.fname, E.lname, D.dependent_name FROM employee AS E, dependent AS D WHERE E.ssn = D.essn;

--Q14
SELECT fname || ' ' || minit || ' ' || lname AS full_name, salary FROM employee WHERE salary > 50000;

--Q15
SELECT E.pname AS project_name, D.dname AS department_name FROM project AS E, department AS D WHERE E.dnum = D.dnumber;

--Q16
SELECT E.pname AS project_name, D.fname AS supervisor_name FROM project AS E, employee AS D, department AS K WHERE E.dnum = K.dnumber AND K.mgrssn = D.ssn AND E.pnumber > 30;

--Q17
SELECT E.pname AS project_name, D.fname AS funcionarios FROM project AS E, employee AS D, department AS K WHERE E.dnum = K.dnumber AND D.dno = K.dnumber;

--Q18
SELECT D.fname AS fname, E.dependent_name AS dependent_name, E.relationship AS relationship FROM employee AS D, dependent AS E, project AS F, department AS G WHERE F.pnumber = 91 AND G.dnumber = F.dnum AND D.dno = G.dnumber AND E.essn = D.ssn;