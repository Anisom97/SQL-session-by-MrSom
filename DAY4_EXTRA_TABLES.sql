CREATE TABLE ORD_CUST_DETAILS (     
TNXID INT PRIMARY KEY,    
CUST_EMAIL VARCHAR(255),
CUST_ADDRESS VARCHAR(255),
CUST_CITY VARCHAR(255),
);

INSERT INTO ORD_CUST_DETAILS       
VALUES                  
(1001,'ABC@GMAIL.COM','ACC HOUSE','BOM'), 
(1003,'A12@YAHOO.COM','CV NAGAR','AHMD'),
(1004,'XYZ@HOTMAIL.COM','ST PAULS ROAD','IXC'),
(1002,'qwe@gmail.com','Kalyan nagar','BOM'),
(1005,'rty@yahoo.com','BTM','CHN'),
(2011,'kkr@gmail.com','bly nest','CCU'),
(1007,'FCB@YAHOO.COM','BEL RD','CCU'),
(2008,'RMA@zoho.com','xz area','DEL'),
(1009,'ram@rediffmail.com','abc zone','GWT')
;

CREATE TABLE LOC_DETAILS (     
LOC_NAME CHAR(50) PRIMARY KEY,    
REGION CHAR(50)
);

INSERT INTO LOC_DETAILS
VALUES
('BOM','WEST'),
('KOC','SOUTH'),
('CHN','SOUTH'),
('BBU','EAST'),
('CCU','EAST'),
('GWT','EAST'),
('DEL','NORTH'),
('IXC','NORTH'),
('AHMD','WEST')
;

SELECT * FROM  ORD_CUST_DETAILS;
SELECT * FROM LOC_DETAILS;