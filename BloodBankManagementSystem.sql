Clear Screen
SET SERVEROUTPUT ON;
SET VERIFY OFF;

DROP TABLE Donor CASCADE CONSTRAINTS;
DROP TABLE Blood_Bank CASCADE CONSTRAINTS;
DROP TABLE Transfusion CASCADE CONSTRAINTS; 
DROP TABLE Appointment CASCADE CONSTRAINTS;

CREATE TABLE Donor (
    DID INT PRIMARY KEY,
    Name VARCHAR2(20) NOT NULL,
    BloodType VARCHAR(5) NOT NULL,
    LastDonated DATE,
    Contact VARCHAR2(20)
);

CREATE TABLE Blood_Bank (
    UnitID INT PRIMARY KEY,
    DID INT NOT NULL,
    BloodType VARCHAR2(5) NOT NULL,
    CollectionDate DATE,
    Address VARCHAR2(20) NOT NULL,
    FOREIGN KEY (DID) REFERENCES Donor(DID)
);

CREATE TABLE Transfusion (
    PID INT PRIMARY KEY,
    Name VARCHAR2(20) NOT NULL,
    UnitID INT NOT NULL,
    BloodType VARCHAR2(5) NOT NULL,
    TransfusionDate DATE,
    FOREIGN KEY (UnitID) REFERENCES Blood_Bank(UnitID)
);

CREATE TABLE Appointment (
    AID INT PRIMARY KEY,
    DID INT NOT NULL,
    BloodType VARCHAR2(5) NOT NULL,
    Date1 DATE,
    FOREIGN KEY (DID) REFERENCES Donor(DID)
);

INSERT INTO Donor VALUES (1,'John Doe', 'A+', DATE '2023-06-16', '555-1234');
INSERT INTO Donor VALUES (2,'ppn Dre', 'A-', DATE '2023-05-30', '555-4586');
INSERT INTO Donor VALUES (3,'Emily Brown', 'AB+', DATE '2023-07-12', '555-4567');
INSERT INTO Donor VALUES (4,'William Lee', 'O-', DATE '2023-06-05', '555-1572');
INSERT INTO Donor VALUES (5,'Olivia Wilson', 'B+', DATE '2023-07-02', '555-2345');
INSERT INTO Donor VALUES (6,'Jane Smith', 'AB+', DATE '2023-04-27', '555-7748');
	
INSERT INTO Blood_Bank VALUES (1, 1, 'A+', DATE '2023-06-27', 'Dhaka');
INSERT INTO Blood_Bank VALUES (2, 2, 'A-', DATE '2023-06-06', 'Chittagong');
INSERT INTO Blood_Bank VALUES (3, 5, 'B+', DATE '2023-07-12', 'Dhaka');
INSERT INTO Blood_Bank VALUES (4, 4, 'O-', DATE '2023-06-25', 'Chittagong');
INSERT INTO Blood_Bank VALUES (5, 6, 'AB+', DATE '2023-07-27', 'Chittagong');
INSERT INTO Blood_Bank VALUES (6, 3, 'AB+', DATE '2023-07-25', 'Dhaka');



INSERT INTO Transfusion VALUES (1,'Sarah Johnson', 1, 'A+', DATE '2023-06-30');
INSERT INTO Transfusion VALUES (2,'Robert Williams', 2, 'A-', DATE '2023-06-25');
INSERT INTO Transfusion VALUES (3,'Finley Tucker', 6, 'AB+', DATE '2023-07-25');
INSERT INTO Transfusion VALUES (4,'Layne Nelson', 3, 'B+', DATE '2023-07-19');
INSERT INTO Transfusion VALUES (5,'Nixon Nelson', 5, 'AB+', DATE '2023-06-15');
INSERT INTO Transfusion VALUES (6,'Morgan Burns', 4, 'O-', DATE '2023-07-05');

INSERT INTO Appointment VALUES (1, 5, 'B+', DATE '2023-07-02');
INSERT INTO Appointment VALUES (2, 3, 'AB+', DATE '2023-07-12');
INSERT INTO Appointment VALUES (3, 1, 'A+', DATE '2023-06-16');
INSERT INTO Appointment VALUES (4, 6, 'AB+', DATE '2023-05-27');
INSERT INTO Appointment VALUES (5, 4, 'O-', DATE '2023-06-05');
INSERT INTO Appointment VALUES (6, 2, 'A-', DATE '2023-05-30');
INSERT INTO Appointment VALUES (7, 6, 'AB+', DATE '2023-08-25');


select * from Donor;
select * from Blood_Bank;
select * from Transfusion;
select * from Appointment;

CREATE OR REPLACE PACKAGE BLOOD_BANK_PACKAGE AS

  FUNCTION GET_NEXT_APPOINTMENT(DID IN NUMBER, BloodType IN VARCHAR2) RETURN DATE;
  FUNCTION IS_BLOOD_TYPE_AVAILABLE(BloodType IN VARCHAR2) RETURN BOOLEAN;
  FUNCTION GET_LAST_DONATION_DATE(DID IN NUMBER) RETURN DATE;
  FUNCTION GET_DONOR_INFO(DID IN NUMBER) RETURN Donor%ROWTYPE;

  PROCEDURE ADD_DONOR(Name IN VARCHAR2, BloodType IN VARCHAR2, LastDonated IN DATE, Contact IN VARCHAR2);
  PROCEDURE BOOK_APPOINTMENT(DID IN NUMBER, BloodType IN VARCHAR2, Date1 IN DATE);

END BLOOD_BANK_PACKAGE;
/

CREATE OR REPLACE PACKAGE BODY BLOOD_BANK_PACKAGE AS

  FUNCTION GET_NEXT_APPOINTMENT(DID IN NUMBER, BloodType IN VARCHAR2) RETURN DATE IS
    NextAppointmentDate DATE;
  BEGIN

    SELECT MIN(Date1) INTO NextAppointmentDate
    FROM Appointment
    WHERE DID = GET_NEXT_APPOINTMENT.DID AND BloodType = GET_NEXT_APPOINTMENT.BloodType AND Date1 > SYSDATE;
    
    RETURN NextAppointmentDate;
  END GET_NEXT_APPOINTMENT;

  FUNCTION IS_BLOOD_TYPE_AVAILABLE(BloodType IN VARCHAR2) RETURN BOOLEAN IS
    BloodTypeCount NUMBER;
  BEGIN

    SELECT COUNT(*) INTO BloodTypeCount
    FROM Blood_Bank
    WHERE BloodType = IS_BLOOD_TYPE_AVAILABLE.BloodType AND CollectionDate < SYSDATE;
    
    RETURN BloodTypeCount > 0;
  END IS_BLOOD_TYPE_AVAILABLE;

  FUNCTION GET_LAST_DONATION_DATE(DID IN NUMBER) RETURN DATE IS
    LastDonationDate DATE;
  BEGIN
    SELECT MAX(LastDonated) INTO LastDonationDate
    FROM Donor
    WHERE DID = GET_LAST_DONATION_DATE.DID;
    
    RETURN LastDonationDate;
  END GET_LAST_DONATION_DATE;

  FUNCTION GET_DONOR_INFO(DID IN NUMBER) RETURN Donor%ROWTYPE IS
    DonorInfo Donor%ROWTYPE;
  BEGIN
    SELECT * INTO DonorInfo
    FROM Donor
    WHERE DID = GET_DONOR_INFO.DID;
    
    RETURN DonorInfo;
  END GET_DONOR_INFO;

  PROCEDURE ADD_DONOR(Name IN VARCHAR2, BloodType IN VARCHAR2, LastDonated IN DATE, Contact IN VARCHAR2) IS
  BEGIN
    INSERT INTO Donor
    VALUES (9, Name, BloodType, LastDonated, Contact);
    
    COMMIT;
  END ADD_DONOR;

  PROCEDURE BOOK_APPOINTMENT(DID IN NUMBER, BloodType IN VARCHAR2, Date1 IN DATE) IS
  BEGIN
    INSERT INTO Appointment
    VALUES (9, DID, BloodType, Date1);
    
    COMMIT;
  END BOOK_APPOINTMENT;


END BLOOD_BANK_PACKAGE;
/


DECLARE
  NextAppointmentDate DATE;
  BloodTypeAvailability BOOLEAN;
  LastDonationDate DATE;
  DonorInfo Donor%ROWTYPE;
  ID_AppointmentDate Appointment.DID%TYPE := &DIDForNextAppointment;
  Bloodd Appointment.BloodType%TYPE := &NEXTAppointment;
  Blood_Avail Blood_Bank.BloodType%TYPE := &BloodAvailable;
  LastDonation Donor.DID%TYPE := &DIDForLastDonationDate;
  Info Donor.DID%TYPE := &DIDForDonorInfo;

BEGIN

  NextAppointmentDate := BLOOD_BANK_PACKAGE.GET_NEXT_APPOINTMENT(ID_AppointmentDate, Bloodd);
  BloodTypeAvailability := BLOOD_BANK_PACKAGE.IS_BLOOD_TYPE_AVAILABLE(Blood_Avail);
  LastDonationDate := BLOOD_BANK_PACKAGE.GET_LAST_DONATION_DATE(LastDonation);
  DonorInfo := BLOOD_BANK_PACKAGE.GET_DONOR_INFO(Info);
  
  DBMS_OUTPUT.PUT_LINE('Next Appointment Date: ' || NextAppointmentDate);

  IF BloodTypeAvailability THEN
    DBMS_OUTPUT.PUT_LINE('Blood Type ' || Blood_Avail || ' is available.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Blood Type ' || Blood_Avail || ' is not available.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Last Donated in ' || LastDonationDate);
  DBMS_OUTPUT.PUT_LINE('Donor Info - Name: ' || DonorInfo.Name || ', Blood Type: ' || DonorInfo.BloodType ||
  ', Contact: ' || DonorInfo.Contact);

  BLOOD_BANK_PACKAGE.ADD_DONOR('John Doe', 'B+', SYSDATE - 30, '123-456-7890');
  DBMS_OUTPUT.PUT_LINE('Donor added successfully.');
  COMMIT;

  BLOOD_BANK_PACKAGE.BOOK_APPOINTMENT(9, 'A+', SYSDATE + 7);
  DBMS_OUTPUT.PUT_LINE('Appointment booked successfully.');
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER trigger1
AFTER INSERT ON Blood_Bank
DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE('successfully inserted on Blood Bank');
END;
/

CREATE OR REPLACE TRIGGER trigger2
AFTER INSERT ON Donor
DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE('successfully inserted on Donor');
END;
/

CREATE OR REPLACE TRIGGER trigger3
AFTER INSERT ON Appointment
DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE('successfully inserted on Appointment');
END;
/

CREATE OR REPLACE TRIGGER trigger4
AFTER INSERT ON Transfusion
DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE('successfully inserted on Transfusion');
END;
/

