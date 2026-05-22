
CREATE TABLE RAPIDO__TABLE
(
    Ride_ID VARCHAR(50),
    Booking_Date DATE,
    Booking_Time TIME,
    Pickup_Location VARCHAR(100),
    Drop_Location VARCHAR(100),
    Vehicle_Type VARCHAR(50),
    Distance_KM NUMERIC(12,2),
    Fare_INR NUMERIC(15,2),
    Payment_Mode VARCHAR(50),
    Ride_Status VARCHAR(50),
    Driver_Rating NUMERIC(5,2),
    Customer_Age INT,
    Weather_Condition VARCHAR(100),
    Time_Slot VARCHAR(100)
);
SELECT * FROM RAPIDO__TABLE;
SELECT COUNT(*) FROM RAPIDO__TABLE;

--1.  Find the total number of rides completed in each pickup location
SELECT Pickup_Location, COUNT(*) AS TOTAL_NUMBER_OF_RIDES 
FROM RAPIDO__TABLE
GROUP BY Pickup_Location;

--2.  Calculate the average fare and average distance for each vehicle type.
SELECT Vehicle_Type, ROUND(AVG(Distance_KM), 2) AS AVERAGE_DISTANCE_KM,
ROUND(AVG(Fare_INR),2) AS AVERAGE_FARE_INR
FROM RAPIDO__TABLE
GROUP BY Vehicle_Type;

--3.  Find the top 5 pickup locations generating the highest revenue
SELECT Pickup_Location, SUM(Fare_INR) AS REVENUE FROM RAPIDO__TABLE
GROUP BY Pickup_Location
ORDER BY SUM(Fare_INR) DESC
LIMIT 5;

--4. Calculate total revenue generated from completed rides by payment mode.
SELECT Payment_Mode, SUM(Fare_INR) AS REVENUE FROM RAPIDO__TABLE
WHERE Ride_Status = 'Completed'
GROUP BY Payment_Mode;

--5.  Find the busiest time slot based on number of rides.
SELECT Time_Slot as Busiest_Time_Slot, 
COUNT(*) AS NUMBER_OF_RIDES FROM RAPIDO__TABLE
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--6. Rank pickup locations based on total completed rides 
WITH NEW_RAPIDO__TABLE AS
(
SELECT Pickup_Location, COUNT(*) AS TOTAL_COMPLETED_RIDES
FROM RAPIDO__TABLE
WHERE Ride_Status = 'Completed'
GROUP BY Pickup_Location
)
SELECT *, DENSE_RANK() OVER (ORDER BY TOTAL_COMPLETED_RIDES DESC) 
AS RANKING FROM NEW_RAPIDO__TABLE;

--7.  Find month-wise revenue growth
WITH NEW_RAPIDO_TABLE AS
(
SELECT EXTRACT(MONTH FROM Booking_Date) AS MONTH_NUMBER,
SUM(Fare_INR) AS REVENUE
FROM RAPIDO__TABLE
GROUP BY 1
)
SELECT MONTH_NUMBER, REVENUE, LAG(REVENUE) OVER 
(ORDER BY MONTH_NUMBER) AS LAST_MONTH_REVENUE,
ROUND((REVENUE-LAG(REVENUE) OVER 
(ORDER BY MONTH_NUMBER))/(LAG(REVENUE) OVER 
(ORDER BY MONTH_NUMBER))*100,2) AS REVENUE_GROWTH_PERCENTAGE
FROM NEW_RAPIDO_TABLE;

--8. Find rides where fare per kilometer is above the overall average fare/km ratio.
SELECT * FROM RAPIDO__TABLE
WHERE (Fare_INR/Distance_KM) >(SELECT AVG(Fare_INR/Distance_KM)
FROM RAPIDO__TABLE);

--9. Identify top 3  pickup locations with highest cancellations
SELECT Pickup_Location, COUNT(*) AS CANCELLED_RIDES
FROM RAPIDO__TABLE
WHERE Ride_Status = 'Cancelled'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3

--10. Find top 5 customer ages taking highest rides 
SELECT Customer_Age, COUNT(Ride_ID) AS RIDE_COUNT
FROM RAPIDO__TABLE
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5