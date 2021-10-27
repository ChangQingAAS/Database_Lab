-- 为了简便，同时创建所有表。
-- 因此，实现时，我是同时删除所有表，然后同时建立所有表
-- drop table contract;
-- drop table bid;
-- drop table waybill;
-- drop table shipper;
-- drop table carrier;
-- drop table usr;

Create table usr(
	id int NOT NULL,
	name varchar(30)
);
alter table usr
ADD PRIMARY KEY (id);

Create table shipper
(
	id INT,
	Address varchar(100)
);
alter table shipper
add foreign key (id) references usr(id),
add constraint shipper_key primary key(id);

Create table carrier
(
	id INT,
	point int
);
alter table carrier
add foreign key(id) references usr(id),
add constraint carrier_key primary key(id);

Create table waybill
(
	id int,
	goods_name varchar(100),
	loading_addr varchar(100),
	unloading_addr varchar(100),
	Freight int,
	order_time DATE,
	Waybill_shipper int
);
alter table waybill
add constraint waybill_key primary key(id);

Create table bid
(
	id int,
	Bid_time DATE,
	Price int,
	Waybill_carrier int
);
alter table bid
add foreign key(id) references waybill(id);

Create table contract
(
	shipper_id int,
	carrier_id int,
	waybill_id int
);
alter table contract
add foreign key (shipper_id) references shipper(id),
add foreign key (carrier_id) references carrier(id),
add foreign key (waybill_id) references waybill(id);


-- -- 添加数据给对应的表
-- create data for usr for shippers
select *
from usr;

Insert into usr values (1,'shipper_a');
Insert into usr values (2,'shipper_b');
Insert into usr values (3,'shipper_c');
Insert into usr values (4,'shipper_d');
Insert into usr values (5,'shipper_e');

-- create data for usr for carriers
Insert into usr values (11,'carrier_a');
Insert into usr values (22,'carrier_b');
Insert into usr values (33,'carrier_c');
Insert into usr values (44,'carrier_d');
Insert into usr values (55,'carrier_e');

-- create data for shippers
Insert into shipper values (1,'1 Weijin Road,Nankai District,Tianjin');
insert into shipper values (2,'2 Weijin Road,Nankai District,Tianjin');
insert into shipper values (3,'3 Weijin Road,Nankai District,Tianjin');
insert into shipper values (4,'4 Weijin Road,Nankai District,Tianjin');
insert into shipper values (5,'5 Weijin Road,Nankai District,Tianjin');

-- create data for carrier
Insert into carrier values (11,10);
insert into carrier values (22,10);
insert into carrier values (33,10);
insert into carrier values (44,10);
insert into carrier values (55,10);

-- create data for waybill
insert into waybill values
(
	11111111,
	'A book called “A First Course in Database Systems”',
	'1 Weijin Road,Nankai District,Tianjin',
	'11 Weijin Road,Nankai District,Tianjin',
	1111,
	'1948-1-6',
	1
);
insert into waybill values
(
	22222222,
	'A book called “A First Course in Database Systems”',
	'2 Weijin Road,Nankai District,Tianjin',
	'22 Weijin Road,Nankai District,Tianjin',
	2222,
	'1948-1-6',
	2
);
insert into waybill values
(
	33333333,
	'A book called “A First Course in Database Systems”',
	'3 Weijin Road,Nankai District,Tianjin',
	'33 Weijin Road,Nankai District,Tianjin',
	3333,
	'1948-1-6',
	3
);
insert into waybill values
(
	44444444,
	'A book called “A First Course in Database Systems”',
	'4 Weijin Road,Nankai District,Tianjin',
	'44 Weijin Road,Nankai District,Tianjin',
	4444,
	'1948-1-6',
	4
);
insert into waybill values
(
	55555555,
	'A book called “A First Course in Database Systems”',
	'5 Weijin Road,Nankai District,Tianjin',
	'55 Weijin Road,Nankai District,Tianjin',
	5555,
	'1948-1-6',
	5
);


-- create data for bid

insert into bid values
(
	11111111,
	'1948-2-8',
	111,
	11
);
insert into bid values
(
	22222222,
	'1948-2-8',
	222,
	22
);
insert into bid values
(
	33333333,
	'1948-2-8',
	333,
	33
);
insert into bid values
(
	44444444,
	'1948-2-8',
	444,
	44
);
insert into bid values
(
	55555555,
	'1948-2-8',
	555,
	55
);

-- create data for  contract
insert into contract values(1,11,11111111);
insert into contract values(2,22,22222222);
insert into contract values(3,33,33333333);
insert into contract values(4,44,44444444);
insert into contract values(5,55,55555555);
