-- 3
-- 用SQL创建关系表
drop table employees;
drop table departments;
drop table dept_emp;
drop table dept_manager;
drop table salaries;
drop table titles;
--  注：外键和内建需要提前声明，中途在加就不行了，即需要先做好E/R
CREATE TABLE employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR(14) NOT NULL,
	last_name VARCHAR(16) NOT NULL,
	gender CHAR(1) NOT NULL,
	hire_date DATE NOT NULL,
	CONSTRAINT pk_employees PRIMARY KEY (emp_no)
);

CREATE TABLE departments (
	dept_no CHAR(4) NOT NULL,
	dept_name VARCHAR(40) NOT NULL,
	CONSTRAINT pk_departments PRIMARY KEY (dept_no)
);

CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no CHAR(4) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	CONSTRAINT pk_dept_emp PRIMARY KEY (emp_no, dept_no),
	CONSTRAINT fk_dept_emp_employees FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	CONSTRAINT fk_dept_emp_departments FOREIGN KEY (dept_no) REFERENCES departments(dept_no)
);

CREATE TABLE dept_manager (
	dept_no CHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	CONSTRAINT pk_dept_manager PRIMARY KEY (emp_no, dept_no),
	CONSTRAINT fk_dept_manager_employees FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	CONSTRAINT fk_dept_manager_departments FOREIGN KEY (dept_no) REFERENCES departments(dept_no)
);

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR(50) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE,
	CONSTRAINT pk_titles PRIMARY KEY (emp_no, title, from_date),
	CONSTRAINT fk_titles_employees FOREIGN KEY (emp_no) REFERENCES employees (emp_no)
);

CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
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

-- 导入数据
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

-- 5.1
-- 返回前10行员工数据。
select *
from employees
Limit 10;

-- 5.2查询first_name为Peternela且last_name为Anick的员工的编号、出生日期、性别和入职日期。
select emp_no,birth_date,gender,hire_date
from employees
where first_name = 'Peternela' and last_name='Anick';

-- 5.3
-- 5.3 查询出生日期在1961-7-15（包括）到1961-7-20（包括）之间的员工的编号、姓名和出生日期。
select emp_no,first_name || ' '||last_name,birth_date
from employees
where birth_date <='1961-07-20'::DATE and birth_date >= '1961-07-15'::DATE;


-- -- 5.4
-- 5.4 查询所有first_name中含有前缀Peter或last_name中含有前缀Peter的员工数据（返回所有列）。
select *
from employees
where first_name like '%Peter%' or last_name like '%Peter%'

-- 5.5
-- 5.5 查询工资数额的最大值，并将查询结果的列名命名为max_salary。
SELECT salary AS max_salary
FROM salaries 
order by salary desc 
limit 1;


SELECT MAX(salary) as max_salary FROM salaries;

-- 5.6--
-- 查询部门编号及相应部门的员工人数，并按照部门编号由小到大的顺序排序（将员工人数列命名为dept_emp_count）。
select dept_no,count(dept_no) as dept_emp_count
from dept_emp
group by dept_no
order by dept_no;

-- 5.7
-- 5.7 查询员工“Peternela Anick”的员工编号、所在部门编号和在该部门的工作起始时间。
select emp_no,dept_no,from_date
from dept_emp
where emp_no in
	(
		select emp_no
		from employees
		where first_name || ' '||last_name = 'Peternela Anick' 
	)
	
-- 5.8
-- 5.8 查询姓名相同的员工x和员工y的编号和姓名（只列出前10行结果）。
select employees.emp_no,employees2.emp_no,employees.first_name,employees.last_name
from employees,employees as employees2
where employees.first_name = employees2.first_name and employees.last_name = employees2.last_name 
		and employees.emp_no <> employees2.emp_no
order by employees.emp_no
limit 10;

-- 5.9
-- 查询姓名为“Margo Anily”的员工编号和出生日期为“1959-10-30”且入职日期为“1989-09-12”的员工编号的并集。
select emp_no
from employees
where first_name = 'Margo' and last_name = 'Anily' UNION
	(
		select emp_no
		from employees
		where birth_date = '1959-10-30' and hire_date = '1989-09-12'
	);

-- 5.10
-- 查询员工“Margo Anily”所在的部门的名称（要求用子查询实现）
select dept_name
from departments
where dept_no =
	(
		select dept_no
		from dept_emp
		where emp_no =
			(
				select emp_no
				from employees
				where first_name || ' ' || last_name = 'Margo Anily'
			)
	);
	
-- 5.11
-- 要求用JOIN…ON连接语法实现查询5.10。
-- select departments.dept_name as dept_name
-- from (departments CROSS JOIN dept_emp) CROSS JOIN employees;
-- where employees.first_name || ' ' || employees.last_name = 'Margo Anily';
select dept_name
from departments 
where dept_no in
	(
		select dept_no
		from dept_emp left join employees 
		on (dept_emp.emp_no = employees.emp_no) 
		where employees.first_name || ' '|| employees.last_name ='Margo Anily'
	);

-- 5.12
-- 查询在全部部门中工作过的员工的编号和姓名（提示：用NOT EXISTS连接的子查询）。
-- 思路：不存在一个部门，雇员没有在该部门工作过
select emp_no,first_name,last_name
from employees
where not exists(
		select *
		from departments
		where not exists
			(
				select *
				from dept_emp
				where departments.dept_no = dept_emp.dept_no and dept_emp.emp_no = employees.emp_no
			)
	);
--这个逻辑上会简单一些	
-- 思路：雇员工作的部门数等于departments里的部门数	
select employees.emp_no,first_name, last_name 
from employees, dept_emp 
where employees.emp_no=dept_emp.emp_no 
group by employees.emp_no 
having count(*) = 
	( 
		select count(*) 
		from departments
	);

---- 5.13
-- 查询员工人数大于等于50000的部门编号、部门名称和部门员工人数，按照部门编号由小到大的顺序排序（将部门员工人数列命名为dept_emp_count）。
select foo.dept_no,departments.dept_name,foo.dept_emp_count as dept_emp_cpunt
from departments natural join
	(	
		select dept_no as dept_no,count(*) as dept_emp_count
		from  dept_emp
		where dept_emp.emp_no > 0
		group by dept_emp.dept_no 
		having count(*)>=50000
		order by dept_emp.dept_no
	)foo;

-- 5.14
-- 在员工表中添加一行记录： (10000, 1981-10-1, Jimmy, Lin, M, 2011-12-8)
INSERT INTO employees(emp_no,birth_date,first_name,last_name,gender,hire_date)
VALUES(10000, '1981-10-1', 'Jimmy', 'Lin', 'M', '2011-12-8');

-- 5.15
-- 将5.14添加的员工记录的first_name属性值修改为Jim
update employees 
set first_name = 'Jim'
where emp_no = 10000 and birth_date = '1981-10-01' and first_name = 'Jimmy'and last_name='Lin';

-- 5.16
-- 删除5.14添加的员工记录
delete  from employees
where emp_no = 10000 and birth_date = '1981-10-01' and first_name = 'Jim'and last_name='Lin';

-- 5.17
-- 在员工表中添加一行记录，(10001, 1981-10-1, Jimmy, Lin, M, 2011-12-8)
select * from employees;

INSERT INTO employees(emp_no,birth_date,first_name,last_name,gender,hire_date)
VALUES(10001, '1981-10-01', 'Jimmy', 'Lin','M', '2011-12-08');

--执行这条语句输出：
-- ERROR: 错误:  重复键违反唯一约束"employees_pkey"
-- DETAIL:  键值"(emp_no)=(10001)" 已经存在

-- 5.18
-- 删除编号为10001的员工，观察执行输出结果。
select *
from employees
where emp_no = 10001; 
-- 以防万一，在此提前记录一下10001号员工的信息
--10001 1953-09-02，Georgi,Facello,M,1986-06-26

delete from employees
where emp_no=10001;

