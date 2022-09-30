DROP DATABASE IF EXISTS data_analytics;
CREATE DATABASE IF NOT EXISTS data_analytics;
USE data_analytics;
show databases;
CREATE TABLE IF NOT EXISTS zillow(
    zip int,
    beds float,
    baths float,
    size float,
    price float,
    house_type varchar(20),
    year_built float,
    days_on_zillow float,
	zestimate int
);

create table if not exists zipcode(
    zipcode int not null primary key,
    race_div float,
    poverty_rate float,
    labour_part float,
    unemp_rate float,
    educ_college float,
    ueduc_high float,
    hse_single float,
    born_ny float,
    perc_asian float,
    perc_black float,
    perc_hispanic float,
    perc_white float,
    pop_disable float,
    income_div float,
    ind_apprec float,
    tot_violate float,
    home_own float,
    pop_den float,
    crime_sr float,
    car_free float,
    mtime_work float,
    mrent float,
    hse_voucher float
);

show tables from data_analytics;


LOAD DATA LOCAL INFILE 'C:/Users/quan/Desktop/da group data/zillow_data.csv' 
INTO TABLE zillow
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/quan/Desktop/da group data/Final_zipdata.csv' 
INTO TABLE zipcode
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from zillow;
select * from zipcode;

select * from zillow b 
inner join zipcode a on a.zipcode=b.zip;
