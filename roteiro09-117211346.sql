--Q1
--1A
CREATE VIEW vw_dptmgr 
AS (SELECT dnumber,fname 
FROM department, employee 
WHERE dnumber=dno AND mgrssn=ssn);

--1B
CREATE VIEW vw_empl_houston 
AS SELECT d.ssn, d.fname 
FROM employee AS d 
WHERE d.address LIKE '%Houston%';

--1C
CREATE VIEW vw_deptstats
AS (SELECT f.dname, f.dnumber, COUNT(*) 
FROM employee AS e 
INNER JOIN department AS f ON e.dno = f.dnumber 
GROUP BY f.dname, f.dnumber);

--1D
CREATE VIEW vw_projstats
AS (SELECT d.pnumber, COUNT(*) 
FROM works_on AS e 
INNER JOIN employee AS f ON f.ssn = e.essn 
INNER JOIN project AS d ON d.pnumber = e.pno 
GROUP BY d.pnumber);

-- Q2
SELECT * FROM vw_dptmgr;
SELECT * FROM vw_empl_houston;
SELECT * FROM vw_deptstats;
SELECT * FROM vw_projstats;

--Q3
DROP VIEW vw_dptmgr;
DROP VIEW vw_empl_houston;
DROP VIEW vw_deptstats;
DROP VIEW vw_projstats;

--Q4
CREATE OR REPLACE FUNCTION check_age(IN ssn_employee CHAR(9))
    RETURNS VARCHAR(7) AS 
    $$

    DECLARE 
    employee_age INTEGER;

    BEGIN
        SELECT EXTRACT (YEAR FROM AGE(E.bdate)) 
        INTO employee_age 
        FROM employee AS E 
        WHERE E.ssn = ssn_employee;

        IF employee_age >= 50 THEN RETURN 'SENIOR';
        ELSEIF employee_age  < 50 AND employee_age  > 0 THEN RETURN 'YOUNG';
        ELSEIF employee_age IS NULL THEN RETURN 'UNKOWN';
        ELSE RETURN 'INVALID';
        END IF;

    END;
    $$ LANGUAGE plpgsql;

--TESTS
-- SELECT check_age('666666609');
-- SELECT check_age('555555500');
-- SELECT check_age('987987987');
-- SELECT check_age('x');
-- SELECT check_age(null);
-- SELECT ssn FROM employee WHERE check_age(ssn) = 'SENIOR';

--Q5
CREATE OR REPLACE FUNCTION check_mgr() 
    RETURNS trigger AS
    $check_mgr$

    DECLARE
    quantity_supervised integer;
    functionary_classification varchar(7);
    functionary_dno integer;

    BEGIN
        SELECT f.dno INTO functionary_dno FROM employee f WHERE f.ssn = NEW.mgrssn;
        SELECT COUNT(*) INTO quantity_supervised FROM employee d WHERE d.superssn = NEW.mgrssn;
        SELECT check_age(NEW.mgrssn) INTO functionary_classification;

        IF (functionary_dno <> NEW.dnumber) OR (functionary_dno IS NULL)THEN RAISE EXCEPTION 'manager must be a department''s employee';
        ELSEIF (functionary_classification <> 'SENIOR') THEN RAISE EXCEPTION 'manager must be a SENIOR employee';
        ELSEIF (quantity_supervised = 0) THEN RAISE EXCEPTION 'manager must have supervisees';
        ELSE RETURN NEW;
        END IF;

    END;
    $check_mgr$ LANGUAGE plpgsql;

--5A
DROP TRIGGER check_mgr ON department;

--5B, deve funcionar
INSERT INTO department VALUES ('Test', 2, '999999999', now());

--5C, deve funcionar
INSERT INTO employee VALUES ('Joao','A','Silva','999999999','10-OCT-1950','123 Peachtree, Atlanta, GA','M',85000,null,2);
INSERT INTO employee VALUES ('Jose','A','Santos','999999998','10-OCT-1950','123 Peachtree, Atlanta, GA','M',85000,'999999999',2);

--5D
CREATE TRIGGER check_mgr BEFORE INSERT OR UPDATE ON department
FOR EACH ROW EXECUTE PROCEDURE check_mgr();

--5E
-- o update deve funcionar normalmente
UPDATE department SET mgrssn = '999999999' WHERE dnumber=2;

-- não permite executar update
UPDATE department SET mgrssn = null WHERE dnumber=2;
-- ERROR:  manager must be a department's employee


-- não permite executar update
UPDATE department SET mgrssn = '999' WHERE dnumber=2;
-- ERROR:  manager must be a department's employee

-- não permite executar update
UPDATE department SET mgrssn = '111111100' WHERE dnumber=2;
-- ERROR:  manager must be a department's employee

-- o update deve funcionar normalmente
UPDATE employee SET bdate = '10-OCT-2000' WHERE ssn = '999999999';

-- não permite executar update
UPDATE department SET mgrssn = '999999999' WHERE dnumber=2;
-- ERROR:  manager must be a SENIOR employee

-- o update deve funcionar normalmente
UPDATE employee SET bdate = '10-OCT-1950' WHERE ssn = '999999999';

-- o update deve funcionar normalmente
UPDATE department SET mgrssn = '999999999' WHERE dnumber=2;

-- o delete deve funcionar normalmente
DELETE FROM employee WHERE superssn = '999999999';

-- não permite executar update
UPDATE department SET mgrssn = '999999999' WHERE dnumber=2;
-- ERROR:  manager must have supevisees

-- o delete deve funcionar normalmente
DELETE FROM employee WHERE ssn = '999999999';

-- o delete deve funcionar normalmente
DELETE FROM department where dnumber=2;