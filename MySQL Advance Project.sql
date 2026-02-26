create database sql2li;
use sql2li;
select * from employee_manages_shipment;
CREATE TABLE logistics AS
SELECT 
emp.E_ID, ship.SH_ID, cli.C_ID, pmt.PAYMENT_ID, memb.M_ID,
emp.E_NAME, emp.E_ADDR, emp.E_BRANCH, emp.E_DESIGNATION, emp.E_CONT_NO,
ship.SH_DOMAIN, ship.SH_CONTENT, ship.SR_ADDR, ship.DS_ADDR, ship.SH_WEIGHT, ship.SER_TYPE, 
ship.SH_CHARGES,
    	cli.C_NAME, cli.C_TYPE, cli.C_ADDR, cli.C_CONT_NO, cli.C_EMAIL_ID,
    	stat.SENT_DATE, stat.DELIVERY_DATE, stat.CURRENT_STATUS,
pmt.AMOUNT, pmt.PAYMENT_STATUS, pmt.PAYMENT_DATE, pmt.PAYMENT_MODE,
    	memb.Start_Date, memb.End_Date
    
FROM
    employee AS emp
    	INNER JOIN
employee_manages_shipment  as ems ON emp.E_ID = ems.Employee_E_ID
   	INNER JOIN
    		shipment AS ship ON ship.SH_ID = ems.Shipment_SH_ID
	INNER JOIN
		client AS cli ON cli.C_ID = ship.C_ID
	INNER JOIN
		status AS stat ON ship.SH_ID = stat.SH_ID
	INNER JOIN
		payment AS pmt ON ship.SH_ID = pmt.SH_ID
	INNER JOIN
		membership AS memb ON memb.M_ID = cli.M_ID;
        
use sql2li;
 
#1)	Find all the employees whose name starts with A and ends with A.

select * from employee where E_name like 'a%a';

#2)	Find all the common names from employee names and client names.

select distinct e_name from employee e where e_name in
(select c_name from client where c_name=e.e_name);

#3)	Create a view of those clients who have not paid the amount.
select * from payment;
create view Payment_not_done as
(select * from client where c_id in 
(select c_id from payment where payment_status ='Paid'));

#4)	What is the total percentage contribution of each Payment Mode?

select *, concat(round(Total/CumTotal*100), '%') as PerCent from
(select Payment_mode, count(payment_mode) Total, (select count(*) from payment) as CumTotal from payment
group by payment_mode) t;
# My Approach

SELECT Payment_Mode,CNT/SUM(CNT)OVER()*100  FROM (
SELECT  Payment_Mode,COUNT(*) CNT FROM payment GROUP BY Payment_Mode)T;
#Yash's approach

#5)	Create a new column 'Total_Payable_Charges' using shipping cost and price of the product. (Use logistics)

alter table logistics add column Total_Payable_Charges float;
set sql_safe_updates =0;
update logistics set Total_Payable_Charges = SH_CHARGES+AMOUNT;
#Yash's approach

#6)	What is the highest payable amount ? (Use logistics)
select max(Total_Payable_Charges) from logistics;

#7)	 Extract the client id and the name of the clients who were or will be the member of the branch for more than 10 years (Use logistics)
desc logistics;

select * from logistics;

select c_id, c_name, year from 
(select *, (datediff(str_to_date(end_date, '%Y-%m-%d'), str_to_date(start_date, '%Y-%m-%d'))/365) as Year from logistics) temp
where year>10;
# My Approach

SELECT 
    e_name,
    c_id,
    DATEDIFF(STR_TO_DATE(end_date , '%Y-%m-%d'),
            STR_TO_DATE(start_date , '%Y-%m-%d')) / 365.25 as  tenure
FROM
    logistics

haVING TENURE >10;
#1979-11-05

#Yash's Approach


#8)	Fetch the records which got the product delivered on the next day the product was sent? (Use logistics)
SELECT 
    *
FROM
    (SELECT 
        DATEDIFF(STR_TO_DATE(DELIVERY_DATE, '%m/%d/%Y'), STR_TO_DATE(SENT_DATE, '%m/%d/%Y')) delIN
    FROM
        logistics
    WHERE
        CURRENT_STATUS = 'DELIVERED') t
WHERE
    delIN < 2;
SELECT 
    *
FROM
    logistics
WHERE
    DATEDIFF(STR_TO_DATE(DELIVERY_DATE, '%m/%d/%Y'),
            STR_TO_DATE(SENT_DATE, '%m/%d/%Y')) = 1;
# Yash's Approach

#9)	Which shipping content had the highest total amount (Top 5). (Use logistics)

select sh_content, sum(amount) as TotalAmount from logistics group by Sh_content
order by sum(amount) desc
limit 5;

select * from
(select  sh_content, Total_Amount, dense_rank()over(order by Total_Amount desc) Drnk from
(select distinct sh_content, sum(amount) over(partition by sh_content) as Total_Amount 
from logistics
order by Total_Amount) t) temp 
where drnk <=5;

#10)	 Which product categories from shipment content are transferred more       (Top 5)?
  
select * from
(select  sh_content, Transfer, dense_rank()over(order by Transfer desc) Drnk from
(select distinct sh_content, count(current_status) over(partition by sh_content) as Transfer 
from logistics
order by Transfer) t) temp 
where drnk <=5;

#11)	Create a new view ‘TXLogistics’ where the employee branch is Texas.
select * from logistics;
create view TXLOGISTICS as 
select * from logistics where E_Branch='TX';

select * from Txlogistics;

#12)	The Texas(TX) branch is giving a 5% discount on total payable amount. 
#Create a new column ‘New_Price’ for a new payable price obtained after applying a discount.

alter view TXLOGISTICS as
select *, (amount- amount*.05) as New_Price from logistics;
select * from txlogistics;

select *, (amount-amount*.05) as New_Price from TXLOGISTICS;

alter view TXLOGISTICS as
select *, (amount- amount*.1) as New_Price2 from logistics
where e_branch='Tx' ;
select * from txlogistics;

#13)	Drop the view TXLogistics

DROP VIEW TXLOGISTICS;

#14)	The employee branch in New York (NY) is shut down temporarily. Thus, the branch needs to be replaced with New Jersey (NJ).

select distinct E_branch from logistics;

update logistics set e_branch='NJ' WHERE E_branch='NY';
set sql_safe_updates=0;

#15)	 Find the unique designations of the employees.

select distinct e_designation from logistics;

#16)	Rank employees based on the total weight of shipments they manage?

select * from logistics;


select *, dense_rank()over(ORDER BY TOTAL_WEIGHT DESC) DRNK from
(select e_id, e_name, sum(sh_weight) over(partition by e_id, e_name) as Total_Weight 
from logistics) temp;


#17)	Rename the column SER_TYPE to SERVICE_TYPE.

alter table logistics rename column SER_TYPE to Service_type;
alter table logistics change ser_type Service_type varchar(50) ;

#18)	 Which service type is preferred more?
select * from logistics;

select * from
(select *, dense_rank()over(order by preference desc) Rnk from
(select distinct service_type, count(service_type) over(partition by service_type) as Preference from logistics)
temp) t
where rnk=1;

#19)	 Find the shipment id and shipment content where the weight is greater than the average weight.

select sh_id, sh_content, sh_weight from logistics where sh_weight> 
(select avg(sh_weight) from logistics);

#20) Calculate the average payment amount for each employee's shipments:

select e_id, e_name, avg(amount) over(partition by e_id, e_name)as Average 
from logistics;