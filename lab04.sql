-- 以防万一，先drop掉所有表
drop table titles;
drop table salaries;
drop table dept_manager;
drop table dept_emp;
drop table employees;
drop table departments;

-- 用SQL创建关系表
CREATE TABLE employees (
    emp_no      INT             NOT NULL,
    birth_date  DATE            NOT NULL,
    first_name  VARCHAR(14)     NOT NULL,
    last_name   VARCHAR(16)     NOT NULL,
    gender      CHAR(1)         NOT NULL,    
    hire_date   DATE            NOT NULL,
    CONSTRAINT pk_employees PRIMARY KEY (emp_no)
);

CREATE TABLE departments (
    dept_no     CHAR(4)         NOT NULL,
    dept_name   VARCHAR(40)     NOT NULL,
    CONSTRAINT pk_departments PRIMARY KEY (dept_no)
);

CREATE TABLE dept_emp (
    emp_no      INT             NOT NULL,
    dept_no     CHAR(4)         NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    CONSTRAINT pk_dept_emp PRIMARY KEY (emp_no, dept_no),
    CONSTRAINT fk_dept_emp_employees FOREIGN KEY (emp_no)  REFERENCES employees(emp_no),
    CONSTRAINT fk_dept_emp_departments FOREIGN KEY (dept_no) REFERENCES departments(dept_no)
);

CREATE TABLE dept_manager (
   dept_no      CHAR(4)         NOT NULL,
   emp_no       INT             NOT NULL,
   from_date    DATE            NOT NULL,
   to_date      DATE            NOT NULL,
   CONSTRAINT pk_dept_manager PRIMARY KEY (emp_no, dept_no),
   CONSTRAINT fk_dept_manager_employees FOREIGN KEY (emp_no)  REFERENCES employees(emp_no),
   CONSTRAINT fk_dept_manager_departments FOREIGN KEY (dept_no) REFERENCES departments(dept_no)
); 

CREATE TABLE titles (
    emp_no      INT             NOT NULL,
    title       VARCHAR(50)     NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE,
    CONSTRAINT pk_titles PRIMARY KEY (emp_no, title, from_date),
    CONSTRAINT fk_titles_employees FOREIGN KEY (emp_no) REFERENCES employees (emp_no)
); 

CREATE TABLE salaries (
    
    emp_no      INT             NOT NULL,
    salary      INT             NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    CONSTRAINT pk_salaries PRIMARY KEY (emp_no, from_date),
    CONSTRAINT fk_salaries_employees FOREIGN KEY (emp_no) REFERENCES employees(emp_no)
);


-- 测试创建的空表
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM dept_emp;
SELECT * FROM dept_manager;
SELECT * FROM titles;
SELECT * FROM salaries;

-- 使用 COPY FROM语句将数据批量导入表中：
COPY employees FROM 'C:data_employees.txt' WITH(FORMAT text, DELIMITER ',');
COPY departments FROM 'C:data_departments.txt' WITH(FORMAT text, DELIMITER ',');
COPY dept_emp FROM 'C:data_dept_emp.txt' WITH(FORMAT text, DELIMITER ',');
COPY dept_manager FROM 'C:data_dept_manager.txt' WITH(FORMAT text, DELIMITER ',');
COPY titles FROM 'C:data_titles.txt' WITH(FORMAT text, DELIMITER ',');
COPY salaries FROM 'C:data_salaries.txt' WITH(FORMAT text, DELIMITER ',');

-- 测试导入数据之后的表
SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM departments;
SELECT COUNT(*) FROM dept_emp;
SELECT COUNT(*) FROM dept_manager;
SELECT COUNT(*) FROM titles;
SELECT COUNT(*) FROM salaries;

--将部门表的所有行复制到新表departments_copy中
CREATE TABLE departments_copy AS (SELECT * FROM departments);

--建立departments_copy_log表
CREATE TABLE departments_copy_log
(
	log_id SERIAL, -- 日志流水编号（自增）
	login_name VARCHAR(256), -- 登录名
	update_date TIMESTAMP WITH TIME ZONE, -- 修改时间
	dept_no CHAR(4), -- 部门编号
	dept_name_old VARCHAR(40), -- 部门名称的旧值
	dept_name_new VARCHAR(40), -- 部门名称的新值
	CONSTRAINT departments_copy_log_pk PRIMARY KEY(log_id)
);



-- 5.19（3） 触发器
CREATE OR REPLACE FUNCTION emp_stamp() RETURNS trigger AS $departments$
    BEGIN
		INSERT INTO departments_copy_log(login_name,update_date,dept_no,dept_name_old,dept_name_new)
		VALUES(USER,now(),OLD.dept_no,OLD.dept_name,NEW.dept_name);
		RETURN NULL;
    END;
$departments$ LANGUAGE plpgsql;

CREATE TRIGGER dept_trigger
AFTER UPDATE ON departments
FOR EACH ROW EXECUTE PROCEDURE emp_stamp();

-- DROP TRIGGER dept_trigger ON departments;

--5.19 (4) 执行UPDATE语句
UPDATE departments
SET dept_name = CONCAT(dept_name, ' Dept')
WHERE dept_no = 'd005';


SELECT * FROM departments_copy_log;
-- DROP TABLE departments_copy_log;

-- 5.20 建立财务部门（名称为Finance）的员工视图
create view finance_employees_view as select emp_no,first_name,last_name,birth_date,hire_date from employees;
--test 5.20
SELECT * FROM finance_employees_view LIMIT 10;

-- 5.21 索引的作用。
EXPLAIN ANALYSE SELECT * FROM employees WHERE first_name='Peternela' AND last_name='Anick';

create index employees_first_name_index on employees(first_name);
create index employees_last_name_index on employees(last_name);

EXPLAIN ANALYSE SELECT * FROM employees WHERE first_name='Peternela' AND last_name='Anick';

drop index employees_first_name_index;
drop index employees_last_name_index;

--5.22 索引与键
EXPLAIN ANALYSE SELECT d.dept_no, d.dept_name, e.emp_no, e.first_name, e.last_name, s.salary
FROM departments AS d
INNER JOIN dept_emp AS de ON d.dept_no=de.dept_no
INNER JOIN employees AS e ON de.emp_no=e.emp_no
INNER JOIN salaries AS s ON e.emp_no=s.emp_no
WHERE e.first_name='Peternela' AND e.last_name='Anick';

create index employees_first_name_index on employees(first_name);
create index employees_last_name_index on employees(last_name);

drop index employees_first_name_index;
drop index employees_last_name_index;

-- drop foreign keys
ALTER TABLE salaries DROP CONSTRAINT fk_salaries_employees;
ALTER TABLE titles DROP CONSTRAINT fk_titles_employees;
ALTER TABLE dept_emp DROP CONSTRAINT fk_dept_emp_employees;
ALTER TABLE dept_emp DROP CONSTRAINT fk_dept_emp_departments;
ALTER TABLE dept_manager DROP CONSTRAINT fk_dept_manager_employees;
ALTER TABLE dept_manager DROP CONSTRAINT fk_dept_manager_departments;

-- drop primary keys
ALTER TABLE employees DROP CONSTRAINT pk_employees;
ALTER TABLE departments DROP CONSTRAINT pk_departments;
ALTER TABLE dept_emp DROP CONSTRAINT pk_dept_emp;
ALTER TABLE salaries DROP CONSTRAINT pk_salaries;

-- add primary keys
ALTER TABLE employees ADD CONSTRAINT pk_employees PRIMARY KEY(emp_no);
ALTER TABLE departments ADD CONSTRAINT pk_departments PRIMARY KEY(dept_no);
ALTER TABLE dept_emp ADD CONSTRAINT pk_dept_emp PRIMARY KEY(emp_no, dept_no);
ALTER TABLE salaries ADD CONSTRAINT pk_salaries PRIMARY KEY(emp_no, from_date);

-- add foreign keys
ALTER TABLE salaries ADD CONSTRAINT fk_salaries_employees FOREIGN KEY (emp_no) REFERENCES employees(emp_no);
ALTER TABLE titles ADD CONSTRAINT fk_titles_employees FOREIGN KEY (emp_no) REFERENCES employees (emp_no);
ALTER TABLE dept_emp ADD CONSTRAINT fk_dept_emp_employees FOREIGN KEY (emp_no) REFERENCES employees(emp_no);
ALTER TABLE dept_emp ADD CONSTRAINT fk_dept_emp_departments FOREIGN KEY (dept_no) REFERENCES departments(dept_no);
ALTER TABLE dept_manager ADD CONSTRAINT fk_dept_manager_employees FOREIGN KEY (emp_no) REFERENCES employees(emp_no);
ALTER TABLE dept_manager ADD CONSTRAINT fk_dept_manager_departments FOREIGN KEY (dept_no) REFERENCES departments(dept_no);


-- 5.23 存储过程
CREATE OR REPLACE FUNCTION calc_avg_salary_for_emp_no(IN emp_no_in INTEGER, OUT avg numeric)
AS $$
BEGIN
	SELECT AVG(salary) INTO avg FROM salaries WHERE emp_no=emp_no_in;
END;
$$ LANGUAGE plpgsql;

do language plpgsql $$
declare res NUMERIC;
begin
select * from calc_avg_salary_for_emp_no(10002) into res;
raise notice '%',res;
end $$;

DROP FUNCTION calc_avg_salary_for_emp_no(integer);

--5.24 存储过程(函数、分支) **(选做)**
CREATE OR REPLACE FUNCTION is_manager (IN emp_no_in INTEGER)
RETURNS BOOLEAN AS $$
DECLARE 
	countt INTEGER;
BEGIN
	SELECT COUNT(*) INTO countt FROM dept_manager WHERE emp_no=emp_no_in;
	IF countt=1 THEN RETURN TRUE;
	ELSE RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT is_manager(110022) AS is_manager;
SELECT is_manager(100002) AS is_manager;

DROP FUNCTION is_manager(INTEGER);

-- 5.25 存储过程（游标、循环）**（选做）**
CREATE OR REPLACE FUNCTION calc_avg_and_var_salary_for_emp_no(IN emp_no_in INTEGER, OUT avg1 REAL, OUT var REAL)
AS $$
DECLARE
	n INTEGER :=0;
	tem INTEGER :=0;
	tem1 INTEGER :=0;
	mycur CURSOR(emp_no_in INTEGER) FOR SELECT salary FROM salaries WHERE emp_no=emp_no_in;
BEGIN
	SELECT AVG(salary) INTO avg1 FROM salaries WHERE emp_no_in=emp_no;
	OPEN mycur(emp_no_in);
	WHILE FOUND LOOP
		FETCH mycur INTO tem;
		exit when not found;
		tem1:=tem1+(tem-avg1)*(tem-avg1);
		n:=n+1;
	END LOOP;
	var:=tem1/n;
	CLOSE mycur;
END;
$$ LANGUAGE plpgsql;

do language plpgsql $$
declare avg_salary REAL;
declare var_salary REAL;
begin
SELECT * FROM calc_avg_and_var_salary_for_emp_no(10002) INTO avg_salary, var_salary;
raise notice 'avg:%', avg_salary;
raise notice  'var:%', var_salary;
end $$;

DROP FUNCTION calc_avg_and_var_salary_for_emp_no;