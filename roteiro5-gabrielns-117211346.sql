-- Q01
SELECT COUNT(*) FROM employee WHERE sex = 'F';

-- Q02
SELECT AVG(salary) FROM employee WHERE address LIKE '%TX' AND sex = 'M';

-- Q03
SELECT superssn, COUNT(*) as qtd_supervisionados FROM employee GROUP BY superssn ORDER BY qtd_supervisionados ASC;

-- Q04
SELECT S.fname AS nome_supervisor, COUNT(*) AS qtd_supervisionados FROM employee AS E JOIN employee AS S ON E.superssn = S.ssn GROUP BY nome_supervisor ORDER BY qtd_supervisionados ASC;

-- Q05
SELECT S.fname AS nome_supervisor, COUNT(*) AS qtd_supervisionados FROM employee AS E LEFT JOIN employee AS S ON E.superssn = S.ssn GROUP BY nome_supervisor ORDER BY qtd_supervisionados ASC;

-- Q06
SELECT MIN(conta) FROM (SELECT pno,COUNT(pno) conta FROM works_on GROUP BY pno) AS contador;

-- Q07
SELECT W.pno AS num_projeto, COUNT(W.pno) AS qtd_func FROM works_on AS W, (SELECT MIN(num_funcionarios) AS qtd FROM (SELECT pno, COUNT(pno) AS num_funcionarios FROM works_on GROUP BY works_on.pno) AS projetos) as tabela GROUP BY W.pno, tabela.qtd HAVING COUNT(W.pno) = tabela.qtd;

-- Q08
SELECT W.pno AS num_proj, AVG(E.salary) AS med_sal FROM employee AS E, works_on AS W WHERE E.ssn = W.essn GROUP BY num_proj;

-- Q09
SELECT W.pno AS proj_num, P.pname AS proj_nome ,AVG(E.salary) AS media_sal FROM employee AS E, works_on AS W, project AS P WHERE E.ssn = W.essn AND P.pnumber = W.pno GROUP BY proj_num, proj_nome ORDER BY media_sal ASC;

-- Q10
SELECT E.fname, E.salary FROM employee AS E, (SELECT MAX(E.salary) AS maior FROM employee AS E, works_on AS W WHERE W.pno = 92 AND W.essn = E.ssn) AS max_salary WHERE E.salary > maior;

-- Q11 
SELECT E.ssn, COUNT(pno) AS qtd_proj FROM employee AS E FULL JOIN works_on AS W ON E.ssn = W.essn GROUP BY E.ssn ORDER BY qtd_proj ASC;

-- Q12
SELECT W.pno AS num_proj, COUNT(*) AS qtd_func FROM employee AS E FULL JOIN works_on AS W ON E.ssn = W.essn  GROUP BY num_proj HAVING COUNT(*) <5 ORDER BY qtd_func ASC;

-- Q13
SELECT e.fname FROM employee AS e WHERE e.ssn in (SELECT w.essn FROM project AS p, works_on AS w WHERE p.pnumber = w.pno AND p.plocation = 'Sugarland') AND e.ssn IN (SELECT d.essn FROM dependent AS d);

-- Q14
SELECT d.dname FROM department AS d WHERE NOT EXISTS (SELECT * FROM project AS proj WHERE proj.dnum = d.dnumber);

--Q15
SELECT E.fname, E.lname FROM employee AS E WHERE E.ssn <> '123456789' AND E.ssn IN (SELECT W.essn FROM works_on AS W, works_on AS W2 WHERE W.essn = W2.essn AND W.pno <> W2.pno AND W.pno IN (SELECT W.pno FROM works_on AS W WHERE W.essn = '123456789') AND W2.pno IN (SELECT W.pno FROM works_on AS W WHERE W.essn = '123456789'));