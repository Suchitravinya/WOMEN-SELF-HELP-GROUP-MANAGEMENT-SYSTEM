CREATE DATABASE women1 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
show databases;
use women1;

CREATE TABLE ORG(
Username VARCHAR(25) NOT NULL,
Mail_adress VARCHAR(50) NOT NULL,
Pass_word  VARCHAR(20) NOT NULL ,
Group_Name VARCHAR(40) ,
No_members int ,
Grp_Location VARCHAR(100),
Meet_ptn VARCHAR(10) ,
intrest_perc int ,
Start_Date DATE,
-- Lead_name VARCHAR(40) NOT NULL,
-- lead_phNO VARCHAR(14) NOT NULL,
PRIMARY KEY(username)
);

CREATE TABLE GRPP(
gp_Username VARCHAR(25) ,
Member_id VARCHAR(25),
M_Name VARCHAR(50),
Age int,
Adress VARCHAR(50),
ph_no VARCHAR(15),
PRIMARY KEY(Member_id),
FOREIGN KEY(gp_Username) REFERENCES org(Username)
);

-- member id should be  in the for of "username_1","username_2" ...., and Leader id should be in the form of "username_1_L"
CREATE TABLE PAST_MEMB(
gp_Username VARCHAR(25) ,
Member_id VARCHAR(25),
M_Name VARCHAR(50),
Age int,
Adress VARCHAR(50),
ph_no VARCHAR(15),
PRIMARY KEY(Member_id),
FOREIGN KEY(gp_Username) REFERENCES org(Username)
); 

CREATE TABLE SAVING
( 
 username VARCHAR(25),
 Member_id VARCHAR(20),
 Saving_date DATE,
 Saving_amt int,
 week_no_mo int,
 fine_amt int,
 PRIMARY KEY(Member_id,Saving_date),
 FOREIGN KEY(Member_id) REFERENCES GRPP(Member_id),
 FOREIGN KEY(username) REFERENCES org(Username)
 );
 
 CREATE TABLE LOAN 
 (
   username VARCHAR(25),
   Loan_id VARCHAR(50) NOT NULL,
   Member_id VARCHAR(20) NOT NULL,
   Loan_date DATE ,
   week_no int,
   Amount int,
   PRIMARY KEY(Loan_id,Member_id),
   FOREIGN KEY(Member_id) REFERENCES GRPP(Member_id),
   FOREIGN KEY(username) REFERENCES org(Username)
 );
 select * from grpp;

 CREATE TABLE LOAN_RET
 (  
  username VARCHAR(25),
  Loan_id VARCHAR(50) NOT NULL,
  Member_id VARCHAR(20) NOT NULL,
  loan_Returned_Amount int,
  intrest_returned int,
  Return_week int,
  dateu DATE,
  PRIMARY KEY(Loan_id,Return_week),
  FOREIGN KEY(Loan_id) REFERENCES LOAN(Loan_id) ,
  FOREIGN KEY(Member_id) REFERENCES GRPP(Member_id),
  FOREIGN KEY(username) REFERENCES org(Username));
  
CREATE VIEW MemberSavingDetails AS
SELECT 
    S.username,
    S.Member_id,
    S.Saving_date,
    S.Saving_amt,
    S.week_no_mo,
    S.fine_amt,
    G.M_Name AS Name
FROM 
    SAVING S
JOIN 
    GRPP G ON S.Member_id = G.Member_id;
    
    
CREATE VIEW LoanDetails AS
SELECT 
    L.username,
    L.Member_id,
    L.Loan_id,
    L.Loan_date,
    L.week_no,
    L.Amount,
    G.M_Name AS Name,
    (O.intrest_perc * L.Amount) / 100 AS Loan_interest
FROM 
    LOAN L
INNER JOIN 
    GRPP G ON L.Member_id = G.Member_id
INNER JOIN 
    ORG O ON G.gp_Username = O.Username;


CREATE VIEW LoanReturnDetails AS
SELECT 
    LR.username AS Username,
    LR.Member_id AS Member_id,
    LR.Loan_id AS Loan_id,
    LR.loan_Returned_Amount AS Loan_returned_amount,
    LR.intrest_returned AS Interest_returned,
    LR.Return_week AS Week_no,
    LR.dateu AS Date,
    G.M_Name AS Name
FROM 
    LOAN_RET LR
JOIN 
    GRPP G ON LR.Member_id = G.Member_id;


DELIMITER //

CREATE PROCEDURE GetMaxWeekNoByUsername (IN specific_username VARCHAR(25))
BEGIN
    SELECT username, MAX(week_no_mo) AS max_week_no_mo
    FROM SAVING
    WHERE username = specific_username
    GROUP BY username;
END //

DELIMITER ;
select * from loan;


DELIMITER //
CREATE TRIGGER check_username_exists
BEFORE INSERT ON ORG
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM ORG WHERE Username = NEW.Username) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
    END IF;
END //
