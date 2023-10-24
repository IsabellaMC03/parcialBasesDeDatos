import json
import mysql.connector as conn

# Load MySQL credentials from a separate configuration file
with open('mysql_credentials.json', 'r') as config_file:
    mysql_config = json.load(config_file)

# Establish a connection to the MySQL database
connection = conn.connect(
    host=mysql_config['host'],
    user=mysql_config['user'],
    password=mysql_config['password'],
    database=mysql_config['database'],
    charset = 'utf8',
)

try:
    with open('countries.json', 'r',encoding='utf-8') as json_file:
        countries_data = json.load(json_file)


        countries_ids = []

            # Execute the stored procedure to insert or update the country
            
        with connection.cursor() as cursor:

            for country in countries_data:

            
                # Extract relevant data from the JSON
                name = country['name']
                alpha2Code = country['alpha2Code']
                alpha3Code = country['alpha3Code']
                region = country['region']
                subregion = country['subregion']
                population = country['population']
                latlng = country['latlng']
                demonym = country['demonym']
                area = country['area']
                gini = country['gini']
                nativeName = country['nativeName']
                numericCode = country['numericCode']
                flag = country['flag']
                cioc = country['cioc']
                domains = country["topLevelDomain"]
                callingCodes = country["callingCodes"]
                capital = country["capital"]
                altSpellings = country["altSpellings"]
                timezones = country["timezones"]
                currencies = country["currencies"]
                languages = country["languages"]
                regionalBlocs = country["regionalBlocs"]
                

                # Convert latlng to latitude and longitude
                if latlng == []:
                    latlng,longitude = None,None
                else:
                    latitude, longitude = latlng
                args = [name, alpha2Code, alpha3Code, region, subregion, population,
                                                            latitude, longitude, demonym, area, gini, nativeName, numericCode, flag,cioc,0]
                result_args = cursor.callproc('InsertOrUpdateCountry', args)

                country_id = result_args[-1]
                countries_ids.append(country_id)

                    # Load Domains

                for domain in domains:

                    args = [country_id,domain]
                    cursor.callproc("AddCountryDomain",args)
                    
                for callingCode in callingCodes:

                    args = [country_id,callingCode]

                    cursor.callproc("InsertCallingCode",args)
                    

                args = [country_id,capital]

                cursor.callproc("InsertOrUpdateCapital",args)
                
                for altSpelling in altSpellings:

                    args = [country_id,altSpelling]

                    cursor.callproc("InsertOrUpdateAltSpelling",args)

                for timezone in timezones:

                    args = [country_id,timezone]
                    cursor.callproc("InsertOrUpdateTimezone",args)

                for currency in currencies:

                    args = [country_id,currency["code"],currency["name"],currency["symbol"]]

                    cursor.callproc("InsertOrUpdateCurrency",args)

                for language in languages:

                    args = [country_id,language["iso639_1"],language["iso639_2"],language["name"],language["nativeName"]]
                    cursor.callproc("InsertOrUpdateLanguage",args)

                for regionalBloc in regionalBlocs:

                    args = [country_id,regionalBloc["acronym"],regionalBloc["name"],0]

                    result_args = cursor.callproc("InsertOrUpdateRegionalBloc",args)

                    regionalBloc_id = result_args[-1]
                        
                    for acronym in regionalBloc["otherAcronyms"]:
                        args = [regionalBloc_id,acronym]
                        cursor.callproc("InsertOtherAcronymForRegionalBloc",args)

                    for name in regionalBloc["otherNames"]:
                        args = [regionalBloc_id,name]
                        cursor.callproc("InsertOtherNameForRegionalBloc",args)

                    
                for lang,translation in country["translations"].items():

                    args = [country_id,lang,translation]

                    cursor.callproc("PopulateTranslations",args)
                # Commit the changes
                connection.commit()

            for country in countries_data:

                alpha3Code = country["alpha3Code"]
                borders = country["borders"]

                for border in borders:

                    args = [alpha3Code,border]

                    cursor.callproc("PopulateCountryBordersByAlpha3Codes",args)



                connection.commit()


            
                
            
        

finally:
    # Close the database connection
    connection.close()