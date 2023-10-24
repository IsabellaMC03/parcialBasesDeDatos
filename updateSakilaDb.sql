use sakila;

DELIMITER $$

CREATE PROCEDURE InsertOrUpdateCountry(
    IN p_country_name VARCHAR(100),
    IN p_alpha2Code VARCHAR(2),
    IN p_alpha3Code VARCHAR(3),
    IN p_region ENUM('','Polar', 'Oceania', 'Europe', 'Americas', 'Africa', 'Asia'),
    IN p_subregion ENUM (
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
    IN p_population INT,
    IN p_latitude DECIMAL(9, 6),
    IN p_longitude DECIMAL(9, 6),
    IN p_demonym VARCHAR(255),
    IN p_area DECIMAL(12, 2),
    IN p_gini DECIMAL(5, 2),
    IN p_nativeName VARCHAR(255),
    IN p_numericCode VARCHAR(3),
    IN p_flag TEXT,
    IN p_cioc VARCHAR(5),
    OUT o_country_id SMALLINT UNSIGNED
    
)
BEGIN
    DECLARE v_country_id INT;
    
    -- Check if the country already exists in the country table
    SELECT country_id INTO v_country_id FROM country WHERE name = p_country_name LIMIT 1;

    -- If the country exists, update the existing row
    IF v_country_id IS NOT NULL THEN
        UPDATE country
        SET alpha2Code = p_alpha2Code,
            alpha3Code = p_alpha3Code,
            region = p_region,
            subregion = p_subregion,
            population = p_population,
            latitude = p_latitude,
            longitude = p_longitude,
            demonym = p_demonym,
            area = p_area,
            gini = p_gini,
            nativeName = p_nativeName,
            numericCode = p_numericCode,
            flag = p_flag,
            cioc = p_cioc
        WHERE country_id = v_country_id;
        SET o_country_id = v_country_id;
    ELSE
        -- If the country doesn't exist, insert a new row
        INSERT INTO country (name, alpha2Code, alpha3Code, region, subregion, population, latitude, longitude, demonym, area, gini, nativeName, numericCode, flag,cioc)
        VALUES (p_country_name, p_alpha2Code, p_alpha3Code, p_region, p_subregion, p_population, p_latitude, p_longitude, p_demonym, p_area, p_gini, p_nativeName, p_numericCode, p_flag,p_cioc);
			SET o_country_id = last_insert_id();
        -- Get the inserted country_id

    END IF;

END;
$$

DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddCountryDomain(IN in_country_id SMALLINT UNSIGNED, IN in_domain_name VARCHAR(10))
BEGIN
    DECLARE domain_exists INT;

    -- Check if the domain already exists for the country
    SELECT COUNT(*) INTO domain_exists
    FROM country_domain
    WHERE country_id = in_country_id AND domain_name = in_domain_name;

    IF domain_exists = 0 THEN
        -- Domain does not exist, insert it
        INSERT INTO country_domain (country_id, domain_name)
        VALUES (in_country_id, in_domain_name);
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertCallingCode(IN in_country_id SMALLINT UNSIGNED, IN in_calling_code VARCHAR(10))
BEGIN
        INSERT INTO country_calling_code (country_id, calling_code)
        VALUES (in_country_id, in_calling_code);
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertOrUpdateCapital(IN in_country_id SMALLINT UNSIGNED, IN p_city VARCHAR(50))
BEGIN

    DECLARE v_city_id SMALLINT UNSIGNED;
    
    -- Check if the country already exists in the country table
    SELECT city_id INTO v_city_id FROM city WHERE city = p_city LIMIT 1;
    
    IF v_city_id IS NULL THEN
		INSERT INTO city (city,country_id) VALUES (p_city,in_country_id);
        SET v_city_id = last_insert_id();
    END IF;
    
    INSERT INTO country_capital (country_id,city_id)
		VALUES (in_country_id, v_city_id);
	
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertOrUpdateAltSpelling(IN in_country_id SMALLINT UNSIGNED, IN in_alt_spelling VARCHAR(255))
BEGIN
    IF EXISTS (SELECT 1 FROM country WHERE country_id = in_country_id) THEN
        -- Country record exists, update alternate spelling
        INSERT INTO country_alternate_spelling (country_id, alternate_spelling)
        VALUES (in_country_id, in_alt_spelling)
        ON DUPLICATE KEY UPDATE alternate_spelling = in_alt_spelling;
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertOrUpdateTimezone(IN in_country_id SMALLINT UNSIGNED, IN in_timezone_name VARCHAR(50))
BEGIN
    DECLARE existing_timezone_id INT;
    
    -- Check if the timezone with the given name exists
    SELECT timezone_id INTO existing_timezone_id FROM timezone
    WHERE timezone_name = in_timezone_name;
    
    IF existing_timezone_id IS NOT NULL THEN
        -- Timezone with the given namecountry_domain exists, associate it with the country
        INSERT INTO country_timezone (country_id, timezone_id)
        VALUES (in_country_id, existing_timezone_id);
    ELSE
        -- Timezone with the given name doesn't exist, create a new timezone
        INSERT INTO timezone (timezone_name)
        VALUES (in_timezone_name);
        
        -- Get the newly created timezone_id
        SELECT LAST_INSERT_ID() INTO existing_timezone_id;
        
        -- Associate the new timezone with the country
        INSERT INTO country_timezone (country_id, timezone_id)
        VALUES (in_country_id, existing_timezone_id);
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertOrUpdateCurrency(
    IN in_country_id SMALLINT UNSIGNED,
    IN in_currency_code VARCHAR(10),
    IN in_currency_name VARCHAR(255),
    IN in_currency_symbol VARCHAR(10)
)
BEGIN
    DECLARE existing_currency_id INT;

    -- Check if a currency with the provided code exists
    SELECT currency_id INTO existing_currency_id FROM currency
    WHERE code = in_currency_code;

    IF existing_currency_id IS NOT NULL THEN
        -- Currency with the provided code exists, associate it with the country
        INSERT INTO country_currency (country_id, currency_id)
        VALUES (in_country_id, existing_currency_id);
    ELSE
        -- Currency with the provided code doesn't exist, create a new currency
        INSERT INTO currency (code, name, symbol)
        VALUES (in_currency_code, in_currency_name, in_currency_symbol);

        -- Get the newly created currency_id
        SELECT LAST_INSERT_ID() INTO existing_currency_id;

        -- Associate the new currency with the country
        INSERT INTO country_currency (country_id, currency_id)
        VALUES (in_country_id, existing_currency_id);
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertOrUpdateLanguage(
    IN in_country_id SMALLINT UNSIGNED,
    IN in_iso639_1 VARCHAR(2),
    IN in_iso639_2 VARCHAR(3),
    IN in_language_name VARCHAR(255),
    IN in_native_name VARCHAR(255)
)
BEGIN
    DECLARE existing_language_id TINYINT UNSIGNED;

    -- Check if a language with the provided ISO 639-1 code exists
    SELECT language_id INTO existing_language_id FROM `language`
    WHERE iso639_1 = in_iso639_1;

    IF existing_language_id IS NOT NULL THEN
        -- Language with the provided ISO 639-1 code exists, associate it with the country
        INSERT INTO country_language (country_id, language_id)
        VALUES (in_country_id, existing_language_id);
    ELSE
        -- Language with the provided ISO 639-1 code doesn't exist, create a new language
        INSERT INTO `language` (iso639_1, iso639_2, name, nativeName)
        VALUES (in_iso639_1, in_iso639_2, in_language_name, in_native_name);

        -- Get the newly created language_id
        SELECT LAST_INSERT_ID() INTO existing_language_id;

        -- Associate the new language with the country
        INSERT INTO country_language (country_id, language_id)
        VALUES (in_country_id, existing_language_id);
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertOrUpdateRegionalBloc(
    IN in_country_id SMALLINT UNSIGNED,
    IN in_acronym VARCHAR(255),
    IN in_name VARCHAR(255),
    OUT out_regionalbloc_id INT
)
BEGIN
    DECLARE existing_regionalbloc_id INT;

    -- Check if a regional bloc with the provided acronym exists
    SELECT regionalBloc_id INTO existing_regionalbloc_id FROM regionalBloc
    WHERE acronym = in_acronym;

    IF existing_regionalbloc_id IS NOT NULL THEN
        -- Regional bloc with the provided acronym exists, associate it with the country
        INSERT INTO country_regionalBloc (country_id, regionalBloc_id)
        VALUES (in_country_id, existing_regionalbloc_id);
    ELSE
        -- Regional bloc with the provided acronym doesn't exist, create a new regional bloc
        INSERT INTO regionalBloc (acronym, name)
        VALUES (in_acronym, in_name);

        -- Get the newly created regionalbloc_id
        SELECT LAST_INSERT_ID() INTO existing_regionalbloc_id;

        -- Associate the new regional bloc with the country
        INSERT INTO country_regionalBloc (country_id, regionalBloc_id)
        VALUES (in_country_id, existing_regionalbloc_id);
    END IF;

    -- Set the OUT parameter to the ID of the regional bloc
    SET out_regionalbloc_id = existing_regionalbloc_id;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertOtherNameForRegionalBloc(
    IN in_regionalbloc_id INT,
    IN in_name VARCHAR(255)
)
BEGIN
    INSERT INTO otherName (name, regionalBloc_id)
    VALUES (in_name, in_regionalbloc_id);
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertOtherAcronymForRegionalBloc(
    IN in_regionalbloc_id INT,
    IN in_acronym VARCHAR(255)
)
BEGIN
    INSERT INTO otherAcronym (name, regionalBloc_id)
    VALUES (in_acronym, in_regionalbloc_id);
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE PopulateCountryBordersByAlpha3Codes(
    IN in_alpha3code_country1 VARCHAR(3),
    IN in_alpha3code_country2 VARCHAR(3)
)
BEGIN
    DECLARE country_id_country1 SMALLINT UNSIGNED;
    DECLARE country_id_country2 SMALLINT UNSIGNED;

    -- Get the country_id of both countries based on their alpha3Codes
    SELECT country_id INTO country_id_country1
    FROM country
    WHERE alpha3Code = in_alpha3code_country1;

    SELECT country_id INTO country_id_country2
    FROM country
    WHERE alpha3Code = in_alpha3code_country2;

    IF country_id_country1 IS NOT NULL AND country_id_country2 IS NOT NULL THEN
        INSERT INTO country_border (country_id, bordering_country_id)
        VALUES (country_id_country1, country_id_country2);
    ELSE
        -- Handle the case where one or both of the countries do not exist
        -- You can choose to log an error or handle it in a way that fits your needs.
        -- This example logs an error.
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'One or both of the specified countries with the provided alpha3Codes do not exist.';
    END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE PopulateTranslations(
    IN in_country_id SMALLINT UNSIGNED,
    IN in_language_name CHAR(2),
    IN in_translation VARCHAR(255)
)
BEGIN
        INSERT INTO translation (translation, country_id,language_name)
        VALUES (in_translation, in_country_id,in_language_name);
END;
//
DELIMITER ;

