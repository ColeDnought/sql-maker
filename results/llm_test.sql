





SELECT * FROM flight_stop




SELECT   * FROM flight_stop WHERE   arrival_airline = 'Salt Lake City' AND destination = 'Phoenix';
SELECT   * FROM flight_stop WHERE   departure_airline = 'pittsburgh' AND arrival_airline = 'phoenix';

SELECT * FROM flight_stop



SELECT   * FROM flight WHERE   to_airport = 'cleveland' AND arrival_time < '12:00';












SELECT dual_carrier FROM flight WHERE flight_id = 'FL12345'   AND flight_id = 'FL67890'   AND flight_id = 'FL11223'   AND flight_id = 'FL33445'   AND flight_id = 'FL55667'   AND flight_id = 'FL77889'   AND flight_id = 'FL99001'   AND flight_id = 'FL22223'   AND flight_id = 'FL33445'   AND flight_id = 'FL55667'   AND flight_id = 'FL77889'   AND flight_id = 'FL99001'   AND flight_id = 'FL22223'   AND flight_id = 'FL33445'   AND flight_id = 'FL55667'   AND flight_id = 'FL77889'   AND flight_id = 'FL99001';







SELECT   * FROM flight WHERE   to_airport = 'indianapolis'   AND from_airport = 'cleveland'   AND departure_time = 'noon';






SELECT   f.flight_id,   a.airline_name FROM flight_fare AS f JOIN flight_leg AS fl   ON f.flight_id = fl.flight_id JOIN flight AS f2   ON fl.leg_flight = f2.flight_id JOIN flight_fare AS fl2   ON fl2.flight_id = f2.flight_id JOIN aircraft AS a   ON fl2.aircraft_code_sequence = a.aircraft_code WHERE   f2.flight_id = 'DENVER-SLC'   AND fl.leg_flight > '17:00'   AND month(f2.flight_date) = '2';






SELECT flight_id, airline_name FROM flight WHERE to_airport = 'oakland'   AND departure_time < '8:00:00'   AND departure_flight_number = '12345';









SELECT   flight_id FROM flight WHERE   to_airport = 'oakland'   AND arrival_time < '6:00 AM'   AND airport = 'salt lake city';




SELECT   * FROM flight_stop WHERE   arrival_flight_number < '12:00:00';




SELECT   * FROM flight_stop WHERE   departure_airline = 'Delta' AND arrival_airline = 'Alaska Airlines' AND departure_time BETWEEN '2024-07-01' AND '2024-07-31';


SELECT   date_day.day_name FROM date_day WHERE   date_day.city = 'St. Louis' AND date_day.state_code = 'MO' AND date_day.airport_service = 'miles_distant';
SELECT   * FROM flight_stop WHERE   departure_airline = 'oakland' AND arrival_airline = 'salt lake city';
SELECT * FROM flight_fare
SELECT * FROM flight_fare


SELECT flight_id FROM flight_fare










SELECT   flight FROM flight WHERE   to_airport = 'Burbank'   AND arrival_time < '7:00 PM'   AND destination = 'Seattle';





SELECT   * FROM flight WHERE   to_airport = 'new york'   AND from_airport = 'miami'   AND restriction_code = 'any';






SELECT   flight FROM flight WHERE   to_airport = 'milwaukee'   AND from_airport = 'orlando'   AND flight_id > '6pm'   AND flight_day = 'wednesday';






SELECT   T1.fare FROM flight_fare AS T1 INNER JOIN flight AS T2   ON T1.flight_id = T2.flight_id INNER JOIN flight_leg AS T3   ON T1.flight_id = T3.flight_id INNER JOIN aircraft AS T4   ON T3.aircraft_code = T4.aircraft_code WHERE   T2.to_airport = 'montreal' AND T3.arrival_airport = 'orlando' AND T4.airline = 'dual_carrier';
SELECT   f.fare FROM flight AS f JOIN flight_leg AS fl   ON f.flight_id = fl.flight_id JOIN flight_fare AS ff   ON fl.leg_number = ff.flight_id JOIN fare AS f2   ON ff.fare_id = f2.fare JOIN airport AS a   ON f2.from_airport = a.airport_code JOIN airport_service AS as   ON a.airport_code = as.airport_code WHERE   a.airport_name = 'orlando'   AND f2.to_airport = 'montreal' ORDER BY   f2.fare ASC LIMIT 1;







SELECT   * FROM flight_fare WHERE   to_airport = 'baltimore'   AND arrival_airline = 'united'   AND fare_basis_code = 'economy';








SELECT * FROM flight_leg WHERE flight_id = 'FL123' AND leg_number = 1 AND flight_days = '4' AND day_name = 'Wednesday' AND restriction_code = '1';









SELECT   flight.to_airport,   flight.arrival_airport,   flight.flight_number,   flight.departure_time,   flight.arrival_time FROM flight JOIN flight_leg   ON flight.flight_id = flight_leg.flight_id JOIN flight_fare   ON flight_leg.leg_number = flight_fare.flight_id JOIN fare   ON flight_fare.fare_id = fare.fare_id JOIN state   ON fare.from_airport = state.country_name JOIN city   ON state.state_code = city.state_code WHERE   flight.to_airport = 'new york' AND flight.arrival_airport = 'miami' AND flight.flight_number = 'round trip' AND flight.arrival_time IS NOT NULL;
SELECT   flight.to_airport,   flight.arrival_airport,   flight.flight_number,   flight.departure_time,   flight.arrival_time FROM flight JOIN flight_leg   ON flight.flight_id = flight_leg.flight_id JOIN flight_fare   ON flight_leg.leg_number = flight_fare.flight_id JOIN fare   ON flight_fare.fare_id = fare.fare_id JOIN state   ON fare.from_airport = state.country_name JOIN city   ON state.state_code = city.state_code WHERE   flight.to_airport = 'new york' AND flight.arrival_airport = 'miami' AND flight.flight_number = 'round trip' AND flight.arrival_time IS NOT NULL;
SELECT   * FROM flight_stop WHERE   departure_airline = 'New York' AND arrival_airline = 'Miami' AND restriction_code = 'round_trip' AND flight_id <> '?'

SELECT flight_id FROM flight










SELECT   flight_id,   fare FROM flight WHERE   to_airport = 'toronto' AND arrival_airline = 'direct' AND destination_airport = 'st. petersburg';








SELECT   * FROM flight WHERE   to_airport = 'Chicago'   AND from_airport = 'Chicago'   AND destination = 'Kansas City'   AND departure_time BETWEEN '08:00:00' AND '17:00:00';


SELECT   * FROM flight WHERE   to_airport = 'milwaukee'   AND from_airport = 'san jose'   AND departure_time = 'wednesday';













SELECT   * FROM flight_stop WHERE   departure_airline = 'LA GUARDIA' AND arrival_airline = 'BURLANKIN';



SELECT * FROM flight_fare WHERE to_airport = 'indianapolis' AND arrival_flight_number = 'memphis' AND saturday_stay_required = FALSE AND restriction_code = 'code_description' AND fare_basis_code = 'fare_basis_code';







SELECT   airfare FROM flight_fare WHERE   to_airport = 'detroit'   AND from_airport = 'st. petersburg'   AND restriction_code = 'first_class'   AND round_trip_required = 'true';








SELECT   seat_capacity FROM flight_stop WHERE   stopover = 'seattle'   AND destination = 'salt lake city';
SELECT   flight.to_airport,   flight.flight_number FROM flight JOIN flight_leg   ON flight.flight_id = flight_leg.flight_id JOIN flight_fare   ON flight_leg.leg_number = flight_fare.flight_id JOIN aircraft   ON flight_leg.aircraft_code_sequence = aircraft.aircraft_code WHERE   flight.to_airport = 'seattle' AND flight.flight_number = 'delta' AND flight_fare.round_trip_required = 'true';







SELECT   flight_fare,   fare_basis FROM flight_fare WHERE   to_airport = 'Miami'   AND departure_time = 'Wednesday';










SELECT   * FROM flight_stop WHERE   departure_airline = 'Continental' AND arrival_airline = 'Continental' AND stop_days = 1 AND stop_time = 'Saturday' AND meal_code = 'EarlySaturdayMorning';
SELECT   flight_id FROM flight WHERE   to_airport = 'Chicago'   AND arrival_time LIKE 'Sat%'   AND destination = 'Seattle'   AND restriction_code = 'continental'   AND meal_code = 'early_saturday_morning';







SELECT   flight FROM flight WHERE   to_airport = 'Charlotte' AND to_airport = 'Baltimore' AND day = 'Tuesday' AND meal_code = 'Food Service';








SELECT   CASE     WHEN fare_basis_code = 'economy'     THEN 'yes'     ELSE 'no'   END FROM fare WHERE   to_airport = 'pittsburgh' AND stopovers = 'cleveland' AND restriction_code = 'code_description' AND round_trip_required = 'yes' AND fare_id > 200;










SELECT   * FROM flight WHERE   to_airport = 'new york city'   AND from_airport = 'las vegas'   AND to_airport = 'las vegas'   AND from_airport = 'memphis'   AND to_airport = 'las vegas';
SELECT   * FROM flight WHERE   to_airport = 'new york city'   AND from_airport = 'las vegas'   AND to_airport = 'las vegas'   AND from_airport = 'memphis'   AND to_airport = 'las vegas';









SELECT * FROM flight WHERE to_airport = 'baltimore' AND arrival_time BETWEEN '5' AND '8'






SELECT   flight FROM flight WHERE   to_airport = 'dallas'   AND arrival_time > '4:00 PM';

SELECT   flight_id FROM flight_leg WHERE   flight_number = 'AA123' AND flight_carrier = 'american airlines' AND route = 'philadelphia to dallas';






SELECT   flight_id,   fare FROM flight WHERE   restriction_code = 'first_class' AND restriction_code = 'coach' AND application = 'kennedy' AND maximum_stay = 'unknown' AND saturday_stay_required = 'false' AND stopovers = 'unknown';
SELECT   flight_id,   fare FROM flight WHERE   restriction_code = 'first_class' AND restriction_code = 'coach' AND application = 'jfk' AND maximum_stay = 'unknown' AND saturday_stay_required = 'false' AND stopovers = 'unknown';










SELECT   fare(to_airport, restriction_code, round_trip_required, fare_id, from_airport, one_direction_cost, fare_basis_code, round_trip_cost, fare_airline) FROM flight WHERE   to_airport = 'detroit'   AND restriction_code = 'first_class'   AND round_trip_required = '1'   AND fare_id = '12345';








SELECT   * FROM flight_stop WHERE   arrival_time BETWEEN '20:00:00' AND '21:00:00'   AND departure_time BETWEEN '19:00:00' AND '20:00:00';









SELECT * FROM flight_stop WHERE arrival_airport = 'denver' AND arrival_time BETWEEN '20:00' AND '22:00';








SELECT * FROM flight







SELECT * FROM flight_stop WHERE arrival_time BETWEEN '20:00' AND '22:00'




SELECT   CASE     WHEN arrival_time = '842' THEN 'true'     ELSE 'false'   END AS is_ground_transport FROM flights;









SELECT   flight_id FROM flight WHERE   to_airport = 'Cincinnati'   AND arrival_time > '12:00:00'   AND departure_time < '19:00:00';








SELECT   * FROM flight_stop WHERE   arrival_flight_number < '12:00:00';






SELECT   flight FROM flight WHERE   flight_id = 'FL12345' AND flight_date = 'Tuesday' AND flight_departure_time BETWEEN '14:00' AND '18:00';




SELECT   flight_fare FROM flight_fare WHERE   to_airport = 'kansascity'   AND arrival_flight_number = 'chicago'   AND departure_flight_number = 'chicago'   AND departure_time = 'wednesday'   AND return_flight_number = 'chicago'   AND return_time = 'following day';









SELECT   * FROM flight WHERE   month(date_day(date_trunc('month', '2024-07-01'), 2)) = 'July'   AND to_airport = 'Charlotte'   AND to_airport = 'Phoenix'   AND restriction_code = '1';









SELECT   flight FROM flight WHERE   to_airport = 'Cincinnati'   AND arrival_time < '2024-07-07 18:00:00'   AND arrival_airline = 'American'   AND restriction_code = 'cincinnati';
SELECT * FROM flight_stop











SELECT   flight_id FROM flight WHERE   to_airport = 'Kansas City' AND flight_id = 'kansas_city_to_chicago_16_06';
SELECT   flight_id FROM flight WHERE   to_airport = 'Chicago' AND arrival_airline = 'United' AND destination_airport = 'Kansas City' AND flight_id > '1';
SELECT   * FROM flight_stop WHERE   arrival_airline = 'United' AND arrival_flight_number = 'UA123' AND   departure_airline = 'Delta' AND departure_flight_number = 'DL456' AND   stop_airport = 'Kansas City' AND   stop_days = '14' AND   month = '06';
SELECT   * FROM flight_stop WHERE   departure_airline = 'United' AND arrival_airline = 'United' AND stop_airport = 'Chicago' AND stop_number = '12345' AND destination_airport = 'Kansas City' AND month = 'June' AND restriction_code = '12345' AND application = 'Flight';





SELECT   flight_id,   fare FROM flight WHERE   to_airport = 'kansascity'   AND flight_days = '2023-05-26'   AND arrival_time = '19:00';








SELECT   flight.to_airport,   flight.departure_time FROM flight JOIN flight_leg   ON flight.flight_id = flight_leg.flight_id JOIN flight_fare   ON flight_leg.leg_number = flight_fare.flight_id JOIN flight_fare_leg   ON flight_fare_leg.flight_id = flight_id JOIN airport   ON flight_fare_leg.leg_flight = airport.airport_code WHERE   airport_name = 'Newark'   AND airport_code = '001'   AND flight.departure_time BETWEEN '18:00' AND '20:00'   AND flight.to_airport = 'Nashville'   AND flight.departure_time BETWEEN '18:00' AND '20:00';





SELECT DISTINCT airline_code FROM flight_fare WHERE to_airport = 'Burbank' AND from_airport = 'St. Louis' AND destination_airport = 'Milwaukee' AND arrival_airport = 'Burbank';






SELECT   * FROM flight WHERE   to_airport = 'Cincinnati'   AND arrival_time > '2024-07-28 18:00:00'   AND arrival_airport = 'New York City';




