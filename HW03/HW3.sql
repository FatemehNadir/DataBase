-- DATABASE DESIGN 1 3991 @ IUT
-- YOUR NAME: Fatemeh Nadi
-- YOUR STUDENT NUMBER: 9636753


---- Q01

Create View V1 as 
select P.name as ProductName,productnumber as ProductNumber ,C.name as ProductCategory,
SC.ProductSubCategoryID as ProductSubCategory
,
TransactionID,ReferenceOrderID,ReferenceOrderLineID ,
TransactionDate,TransactionType,Quantity,ActualCost 
from  production.product as P
		JOIN production.transactionhistory as T ON(P.productid = T.productid)  
		JOIN production.productsubcategory as SC ON(P.ProductSubcategoryID = SC.ProductSubcategoryID)
		JOIN production.productcategory as C ON(SC.ProductCategoryID = C.ProductCategoryID)
		
---- Q02

---- Q03
select name , salesorderID
from production.product LEFT OUTER JOIN Sales.salesorderdetail USING(ProductID)


---- Q04
select name , salesorderID
from production.product LEFT OUTER JOIN Sales.salesorderdetail USING(ProductID)
where salesorderID is NULL

---- Q05
select SalesOrderID , SalesPersonID , SalesYTD
from Sales.salesorderheader as SOH LEFT OUTER JOIN Sales.Salesperson as SP ON(SOH.salespersonid = SP.businessentityid)

---- Q06
select SalesOrderID , SOH.SalesPersonID , SalesYTD , P.firstname 
from Sales.salesorderheader as SOH 
	LEFT OUTER JOIN Sales.Salesperson as SP ON(SOH.salespersonid = SP.businessentityid) 
	FULL JOIN Sales.store  ON(SP.businessentityid = Sales.store.salespersonid)
	FULL JOIN Person.businessentity as B ON(B.businessentityid = Sales.store.businessentityid)
	FULL JOIN Person.person as P ON(P.businessentityid = B.businessentityid)
	
	---- where Sales.store.salespersonid is not  NULL

---- Q07
select Sales.CurrencyRate.CurrencyRateID , AverageRate ,SalesOrderID , ShipBase
from Sales.salesorderheader as SOH 
	LEFT OUTER JOIN Purchasing.shipmethod  ON(SOH.shipmethodid = Purchasing.shipmethod.shipmethodid) 
	LEFT OUTER JOIN Sales.CurrencyRate  ON(SOH.currencyrateid = Sales.CurrencyRate.currencyrateid) 
	
---- Q08

select Sales.salesperson.BusinessEntityID , P.productid
from Sales.salesperson 
	LEFT OUTER JOIN Sales.salesorderheader as SOH ON(Sales.salesperson.BusinessEntityID = SOH.salespersonid )
	JOIN Sales.salesorderDetail as SOD ON(SOH.salesorderid = SOD.salesorderid )
	JOIN Sales.specialofferproduct as SOP  ON (SOD.specialofferid = SOP.specialofferid and SOD.ProductID = SOP.ProductID ) 
	JOIN Production.product as P  ON (P.productid = SOP.productid ) 

---- Q09
select Per.firstname , per.lastname , P.name
from Sales.salesorderheader as SOH 
	JOIN Sales.salesorderdetail as SOD ON(SOH.salesorderid = SOD.salesorderid) 
	JOIN Production.product as P  ON(SOD.productid = P.productid)
	JOIN Sales.customer as C ON(C.customerid = SOH.customerid)
	LEFT OUTER JOIN Person.person as Per ON(Per.businessentityid = C.PersonID)
	
---- Q10
SELECT schemaname,relname,n_live_tup 
  FROM pg_stat_user_tables 
  ORDER BY n_live_tup DESC;

---- Q11

SELECT
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    tablename = 'table_name';

---- Q12
select *
from sales.salesorderheader
where territoryid = 4

---- Q13
select *
from sales.salesorderheader
where territoryid < 4

---- Q14
select *
from sales.salesorderheader
where territoryid > 4

---- Q15

CREATE INDEX index_territoryid ON sales.salesorderheader
(
    territoryid
);

select *
from sales.salesorderheader
where territoryid = 4



---- Q16
select *
from sales.salesorderheader
where territoryid < 4


---- Q17


select *
from sales.salesorderheader
where territoryid > 4


