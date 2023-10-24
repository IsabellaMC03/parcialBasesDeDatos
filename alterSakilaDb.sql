USE sakila;

ALTER TABLE country 
CHANGE COLUMN country name VARCHAR(100),
ADD COLUMN alpha2Code VARCHAR(2) UNIQUE,
ADD COLUMN alpha3Code VARCHAR(3) UNIQUE,
ADD COLUMN region ENUM(
   '', 'Polar', 'Oceania', 'Europe', 'Americas', 'Africa', 'Asia'
),

ADD COLUMN subregion ENUM (
'',
    'Eastern Africa',
    'Eastern Europe',
    'South-Eastern Asia',
    'Southern Asia',
    'Polynesia',
    'Caribbean',
    'Northern Africa',
    'Northern Europe',
    'Micronesia',
    'Southern Africa',
    'Central America',
    'South America',
    'Middle Africa',
    'Southern Europe',
    'Western Asia',
    'Australia and New Zealand',
    'Western Europe',
    'Western Africa',
    'Northern America',
    'Eastern Asia',
    'Melanesia',
    'Central Asia'
),
ADD COLUMN population INT,
ADD COLUMN latitude DECIMAL(9, 6),
ADD COLUMN longitude DECIMAL(9, 6),
ADD COLUMN demonym VARCHAR(255),
ADD COLUMN area DECIMAL(12, 2),
ADD COLUMN gini DECIMAL(5, 2),
ADD COLUMN nativeName VARCHAR(255) DEFAULT NULL,
ADD COLUMN numericCode VARCHAR(3) DEFAULT NULL,
ADD COLUMN flag TEXT,
ADD COLUMN cioc varchar(5);

CREATE TABLE timezone (
  timezone_id INT AUTO_INCREMENT primary key,
  timezone_name VARCHAR(50) UNIQUE 
);

CREATE TABLE country_timezone (
  country_timezone_id INT AUTO_INCREMENT PRIMARY KEY,
  country_id  SMALLINT UNSIGNED,
  timezone_id INT,
  FOREIGN KEY (country_id) REFERENCES country(country_id),
  FOREIGN KEY (timezone_id) REFERENCES timezone(timezone_id)
);

CREATE TABLE country_domain (
    domain_id INT AUTO_INCREMENT PRIMARY KEY,
    country_id SMALLINT UNSIGNED,
    domain_name VARCHAR(10),
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE country_calling_code (
    calling_code_id INT AUTO_INCREMENT PRIMARY KEY,
    country_id SMALLINT UNSIGNED,
    calling_code VARCHAR(10),
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE country_capital (
    capital_id INT AUTO_INCREMENT PRIMARY KEY,
    country_id SMALLINT UNSIGNED,
    city_id SMALLINT UNSIGNED,
    FOREIGN KEY (country_id) REFERENCES country(country_id),
    FOREIGN KEY (city_id) REFERENCES city(city_id)
);

CREATE TABLE country_alternate_spelling (
    alternate_spelling_id INT AUTO_INCREMENT PRIMARY KEY,
    country_id SMALLINT UNSIGNED,
    alternate_spelling VARCHAR(255),
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE country_border (
  border_id INT AUTO_INCREMENT PRIMARY KEY,
  country_id SMALLINT UNSIGNED,
  bordering_country_id SMALLINT UNSIGNED,
  FOREIGN KEY (country_id) REFERENCES country(country_id),
  FOREIGN KEY (bordering_country_id) REFERENCES country(country_id)
);

CREATE TABLE currency (
  currency_id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(10),
  name VARCHAR(255),
  symbol VARCHAR(10)
);

CREATE TABLE country_currency (
  country_id SMALLINT UNSIGNED,
  currency_id INT,
  PRIMARY KEY (country_id, currency_id),
  FOREIGN KEY (country_id) REFERENCES country(country_id),
  FOREIGN KEY (currency_id) REFERENCES currency(currency_id)
);

ALTER TABLE `language`
  ADD COLUMN iso639_1 VARCHAR(2) UNIQUE,
  ADD COLUMN iso639_2 VARCHAR(3) UNIQUE,
  ADD COLUMN nativeName VARCHAR(255),
  MODIFY COLUMN `name` VARCHAR(255);

CREATE TABLE country_language (
  country_id SMALLINT UNSIGNED,
  language_id TINYINT UNSIGNED,
  PRIMARY KEY (country_id, language_id),
  FOREIGN KEY (country_id) REFERENCES country(country_id),
  FOREIGN KEY (language_id) REFERENCES language(language_id)
);

CREATE TABLE translation (
  translation_id INT AUTO_INCREMENT PRIMARY KEY,
  translation VARCHAR(255),
  language_name CHAR(2),
  country_id SMALLINT UNSIGNED,

  FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE regionalBloc (
  regionalBloc_id INT AUTO_INCREMENT PRIMARY KEY,
  acronym VARCHAR(255),
  name VARCHAR(255)
);
CREATE TABLE otherName (
  otherName_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  regionalBloc_id INT,
  FOREIGN KEY (regionalBloc_id) REFERENCES regionalBloc(regionalBloc_id)
);
CREATE TABLE otherAcronym (
  otherAcronym_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  regionalBloc_id INT,
   FOREIGN KEY (regionalBloc_id) REFERENCES regionalBloc(regionalBloc_id)
);

CREATE TABLE country_regionalBloc (
  country_id SMALLINT UNSIGNED,
  regionalBloc_id INT,
  PRIMARY KEY (country_id, regionalBloc_id),
  FOREIGN KEY (country_id) REFERENCES country(country_id),
  FOREIGN KEY (regionalBloc_id) REFERENCES regionalBloc(regionalBloc_id)
);

