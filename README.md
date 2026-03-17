#LogiSQL: Logistics & Shipment Analytics System#

##  Project Overview
This project focuses on designing and analyzing a comprehensive **Logistics Management Database**. It involves managing complex relationships between employees, shipments, clients, payments, and memberships. The goal is to transform raw operational data into actionable business insights using SQL.

##  Tech Stack & Skills
* **Database:** MySQL / PostgreSQL
* **Advanced SQL Techniques:**
    * **Joins:** Complex multi-table Inner Joins.
    * **Window Functions:** `DENSE_RANK()`, `SUM() OVER()`, `AVG() OVER()`.
    * **DDL/DML:** Table creation, View management, and Data cleaning (Updates/Alters).
    * **Analytics:** Date manipulation (`DATEDIFF`), percentage contribution, and subqueries.

## Database Architecture
The project utilizes a centralized `logistics` table (denormalized view) derived from the following entities:
* **Employee:** Staff details, branches, and designations.
* **Shipment:** Parcel content, weight, and addresses.
* **Client:** Customer demographics and contact info.
* **Status:** Tracking sent and delivery dates.
* **Payment:** Transaction amounts and modes.
* **Membership:** Client loyalty and tenure data.

## Key Insights & Queries
Some of the critical business questions solved in this project include:
1.  **Revenue Analysis:** Calculating the percentage contribution of each payment mode.
2.  **Operational Efficiency:** Identifying next-day deliveries and ranking service type preferences.
3.  **Customer Loyalty:** Extracting clients with over 10 years of membership tenure.
4.  **Staff Performance:** Ranking employees based on the total weight of shipments managed.
5.  **Regional Management:** Handling branch shutdowns (NY to NJ) and applying regional discounts (Texas branch).

