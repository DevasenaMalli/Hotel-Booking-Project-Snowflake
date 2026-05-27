# Hotel-Booking-Project-Snowflake


# Hotel Booking Analytics Project using Snowflake

## Project Overview
This project demonstrates an end-to-end data warehouse pipeline in Snowflake for hotel booking analytics. The pipeline follows a layered architecture using Bronze, Silver, and Gold tables to ingest raw hotel booking data, clean and validate it, and create analytics-ready datasets for reporting and dashboards.

## Architecture

Raw CSV File
→ Snowflake Stage
→ Bronze Table
→ Silver Cleaned Table
→ Gold Analytics Tables
→ Dashboard KPI Queries

## Technologies Used
- Snowflake
- SQL
- Snowflake Stage
- File Format
- COPY INTO
- Data Cleaning
- Data Validation
- Bronze / Silver / Gold Architecture

## Project Flow

### 1. Database and File Format Creation
Created a Snowflake database and CSV file format to load hotel booking data.

### 2. Stage Creation
Created an internal Snowflake stage to store and load raw CSV files into Snowflake.

### 3. Bronze Layer
Loaded raw hotel booking data into the `BRONZE_HOTEL_BOOKING` table without major transformations.

### 4. Data Validation
Performed data quality checks such as:
- Invalid customer email validation
- Negative amount check
- Check-in date greater than check-out date validation
- Booking status standardization

### 5. Silver Layer
Created `SILVER_HOTEL_BOOKINGS` table by applying:
- Date conversion
- Customer name formatting
- City name standardization
- Email cleanup
- Amount correction
- Booking status correction

### 6. Gold Layer
Created analytics-ready tables:
- `GOLD_BOOKING_CLEAN`
- `GOLD_AGG_DAILY_BOOKING`
- `GOLD_AGG_HOTEL_CITY_SALES`

These tables support reporting and dashboard analysis.

## Dashboard KPIs
The project includes SQL queries for:
- Total Revenue
- Total Bookings
- Total Guests
- Average Booking Value
- Revenue by Date
- Top Cities by Revenue
- Bookings by Status
- Bookings by Room Type

## Business Use Case
This project helps hotel business teams analyze booking performance, revenue trends, customer booking behavior, and city-level revenue contribution.

## Key Learning Outcomes
- Built a Snowflake data warehouse pipeline
- Implemented Bronze, Silver, and Gold architecture
- Loaded CSV data using Snowflake stage and COPY INTO
- Applied SQL-based data cleaning and transformation
- Created reporting-ready tables for dashboard analytics
