

SELECT * FROM flight_stop WHERE arrival_airport = 'baltimore' AND arrival_date = 'Thursday' AND arrival_time < '09:00';









SELECT   * FROM flight_stop WHERE   departure_airline = 'american airlines'   AND stop_days = 'Friday'   AND destination = 'Milwaukee'   AND restriction_code = 'code_description'   AND application = 'flight_stop'   AND maximum_stay = 'false'   AND saturday_stay_required = 'true';






SELECT   flight(to_airport, dual_carrier, flight_id, "morning", "8") FROM flight




SELECT   * FROM flight_stop WHERE   departure_airline = 'P leteco'   AND arrival_flight_number = 'B123'   AND arrival_time < '10:00:00'   AND month = 'Thursday';














SELECT   SUM(fare) FROM fare WHERE   to_airport = 'boston'   AND from_airport = 'boston'   AND to_airport = 'denver'   AND from_airport = 'denver';




SELECT   flight FROM flight WHERE   to_airport = 'denver'   AND flight_id BETWEEN '14:00' AND '17:00'   AND arrival_time = '17:00';







SELECT fare(to_airport, code_description, "american airlines") FROM flight(19, "aircraft_code_sequence", dual_carrier)








SELECT   flight_id FROM flight WHERE   to_airport = 'Boston' AND arrival_time = 'Atlanta' AND departure_time = 'Atlanta';


SELECT   * FROM flight WHERE   month(flight_date) = '12'   AND to_date(flight_date, 'YYYY-MM-DD') = '2023-12-16';







SELECT   * FROM flight_stop WHERE   departure_airline = 'Delta' AND arrival_airline = 'United' AND arrival_time = '19:00' AND city = 'Baltimore';














SELECT * FROM flight_stop



SELECT   * FROM flight WHERE   month(date_day(date('now', 'Monday')), month_name) = 'January'   AND restriction_code = 'continental'   AND departure_time < '12:00:00'   AND to_airport = 'denver'   AND arrival_airport = 'chicago';









SELECT aircraft_description FROM flight_fare WHERE to_airport = 'Boston' AND flight_id = 'flight_fare' AND time_elapsed > '17:00' AND restriction_code = 'flight_stop';


SELECT aircraft_name FROM flight_fare WHERE airline = 'united' AND flight_id = 'DENVER_SFCN' AND departure_time < '10:00'









SELECT   * FROM flight_stop WHERE   departure_flight_number BETWEEN '12:00' AND '17:00'   AND arrival_flight_number = 'boston';









SELECT   flight_id FROM flight WHERE   to_airport = 'Miami' AND arrival_flight_number = 'US Air' AND departure_flight_number = 'CLEveland' AND departure_time > '12:00';
SELECT * FROM flight_stop






SELECT flight_id FROM flight_fare WHERE to_airport = 'atlanta'   AND from_airport = 'baltimore'   AND arrival_time = '7:00 PM'   AND airline = 'boeing'   AND aircraft_code_sequence = '757';





SELECT * FROM flight_fare WHERE to_airport = 'pittsburgh' AND from_airport = 'dallas' AND flight_id > '12pm' AND fare_basis_code = '1100' AND round_trip_required = false;











SELECT   * FROM flight_stop WHERE   departure_airline = 'american'   AND departure_flight_number LIKE 'DALL%'   AND arrival_airline = 'delta'   AND stop_airport = 'baltimore'   AND arrival_flight_number LIKE 'BAL%';





SELECT   * FROM flight_fare WHERE   to_airport = 'cleveland'   AND from_airport = 'miami'   AND arrival_time < '4pm';







SELECT * FROM flight_fare WHERE to_airport = 'atlanta' AND from_airport = 'dallas' AND flight_id > '12pm' AND fare_basis_code = 'round_trip' AND fare_id < '1100'







SELECT   airline FROM code_description WHERE   description = 'Washington'   AND airline NOT IN ('United', 'Delta', 'American');




SELECT   * FROM flight WHERE   to_airport = 'denver'   AND to_airport = 'philadelphia'   AND departure_time > 'sunday 12:00:00'   AND restriction_code = 'restriction';









SELECT DISTINCT   flight_id FROM flight_stop WHERE   restriction_code = 'first_class'   AND flight_id LIKE 'DENVER%'   AND flight_id LIKE '%BALTIMORE%';






SELECT   * FROM flight_leg WHERE   flight_id IN (     SELECT       flight_id     FROM flight     WHERE       airline = 'united'       AND flight_id IN (         SELECT           flight_id         FROM flight_leg         WHERE           leg_flight = 1         GROUP BY           leg_flight         HAVING           COUNT(*) > 1       )   );











SELECT * FROM flight








SELECT   * FROM flight_stop WHERE   departure_airline = 'Atlanta' AND arrival_flight_number = 'Washington DC' AND departure_time < '0900';






SELECT   flight_id FROM flight WHERE   to_airport = 'atlanta' AND flight_id = 'FL123' AND restriction_code = '1' AND arrival_time BETWEEN '23:00' AND '23:59' AND stopovers = '0' AND arrival_airline = 'AA';






SELECT * FROM flight_stop WHERE departure_time BETWEEN '14:00' AND '17:00'









SELECT   flight_id FROM flight WHERE   to_airport = 'st. petersburg' AND arrival_flight_number = 'milwaukee' AND day = 'tomorrow';







SELECT   fare FROM fare WHERE   to_airport = 'oakland'   AND from_airport = 'dallas'   AND month = 'december'   AND sixteenth = '16';






SELECT * FROM flight_stop





SELECT aircraft_description FROM aircraft WHERE aircraft_code = '825' AND flight_id = '825';










SELECT   flight(to_airport, dual_carrier, flight_id, "wednesday", "atlanta", "one_direction_cost", "washington dc", "double_direction_cost", "2024-04-22", "00:00", "flight_id") FROM flight WHERE   restriction(no_discounts, minimum_stay, stopovers, restriction_code, application, maximum_stay, saturday_stay_required, advance_purchase);




SELECT   * FROM flight_stop WHERE   departure_airport = 'philadelphia'   AND arrival_airport = 'denver'   AND departure_time BETWEEN '14:00' AND '16:00';









SELECT flight_id FROM flight WHERE to_airport = 'denver' AND from_airport = 'pittsburgh' OR to_airport = 'pittsburgh' AND from_airport = 'atlanta';





SELECT   * FROM flight_stop WHERE   arrival_time = '2024-04-06 06:00:00'   AND departure_time = '2024-04-06 05:00:00';




SELECT   * FROM flight WHERE   to_airport = 'Philadelphia'   AND arrival_time = '2024-04-16 22:00';




SELECT   CASE     WHEN flight_id = '813' THEN 'yes'     ELSE 'no'   END AS flight_status FROM flight;

SELECT   * FROM flight WHERE   flight_id = '497766'   AND flight_date = 'tomorrow morning'   AND restriction_code = '1'   AND stopovers = '1';








SELECT   flight_id,   flight_number,   flight_date FROM flight WHERE   to_airport = 'pittsburgh'   AND from_airport = 'denver'   AND to_airport = 'denver'   AND flight_number LIKE '%denver%';












SELECT   * FROM flight WHERE   to_airport = 'Chicago'   AND from_airport = 'Chicago'   AND arrival_airline = 'United'   AND arrival_time = '2023-06-17 19:00:00'   AND destination_airport = 'Kansas City';

SELECT   * FROM flight_stop WHERE   departure_airline = 'Toronto' AND arrival_airline = 'Salt Lake City' AND departure_time BETWEEN '530' AND '19'







SELECT * FROM flight_stop












SELECT   flight_id FROM flight WHERE   to_airport = 'san francisco' AND month(month_number, month_name) = 'monday' AND restriction_code = 'first_class';


SELECT   flight_id,   fare_basis FROM flight_fare WHERE   month = 'December'   AND month_name = 'December'   AND to_airport = 'Indianapolis'   AND to_airport = 'Orlando';








SELECT   days FROM flight_leg WHERE   flight_id = 'FL123' AND flight_number = 'KCN' AND airport_code = 'MKE';









SELECT   * FROM flight_stop WHERE   departure_airline = 'United' AND arrival_airline = 'United' AND stop_airport = 'Dallas Fort Worth' AND arrival_time > '2024-01-01';




SELECT   flight_id FROM flight WHERE   to_airport = 'new york' AND arrival_airline = 'airline1' AND destination_airport = 'los angeles' AND stopovers = 'milwaukee';







SELECT * FROM flight WHERE to_airport = 'pittsburgh' AND from_airport = 'philadelphia' AND departure_time < '09:00';









SELECT * FROM flight WHERE to_airport = 'San Francisco' AND airline = 'United Airlines';






SELECT   flight_id FROM flight WHERE   to_airport = 'baltimore'   AND to_airport = 'san francisco'   AND arrival_time = '2024-10-27 20:00:00'   AND saturday_stay_required = FALSE;













SELECT   fare FROM flight_fare WHERE   to_airport = 'san francisco' AND arrival_flight_number = '852' AND destination_airport = 'dallas fort worth' AND airline = 'delta';
SELECT * FROM flight WHERE to_airport = 'pittsburgh' AND from_airport = 'philadelphia' AND arrival_time = '6' AND month = 'Tuesday';










SELECT   * FROM flight WHERE   to_airport = 'boston'   AND arrival_time < '5 00 00'   AND route = 'atlanta'   AND month = 'Thursday';










SELECT * FROM flight








SELECT   flight_id FROM flight WHERE   to_airport = 'Boston' AND flight_id LIKE '29%';







SELECT   fare(to_airport, restriction_code, round_trip_required, fare_id, from_airport, one_direction_cost, fare_basis_code, round_trip_cost, fare_airline) FROM flight WHERE   to_airport = 'atlanta' AND restriction_code = 'Downtown';




SELECT * FROM flight




SELECT   * FROM flight WHERE   to_airport = 'dallas'   AND destination_airport = 'oakland'   AND departure_time < '12:00';
