public with sharing class FindNearbyController{


    public List<Map<String,Double>> locations { get; private set; }
    public String currentPosition { 
        get {
            if (String.isBlank(currentPosition)) {
                currentPosition = '37.77493,-122.419416'; // San Francisco
            }
            return currentPosition;
        }
        set; 
    }
    
    public Boolean resultsAvailable {
        get {
            if(locations == Null) {
                return false;
            }
            return true;
        }
    }
    
    public PageReference findNearby() {
        String lat, lon;

        // FRAGILE: You'll want a better lat/long parsing routine
        // Format: "<latitude>,<longitude>" (must have comma, but only one comma)
        List<String> latlon = currentPosition.split(',');
        lat = latlon[0].trim();
        lon = latlon[1].trim();

        // SOQL query to get the nearest Contacts
           String queryString =
           'SELECT Id, Name, MailingStreet, MailingCity, MailingState, Phone, Location__longitude__s, Location__latitude__s ' +
           'FROM Contact ' +
           'WHERE DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') < 20 ' +
           'ORDER BY DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') ' +
           'LIMIT 10';
        System.Debug('>>>> the value of queryString is ' + queryString);
        // Run the query
 
       List <Contact> contacts = database.query(queryString);
        if(contacts.size() > 0 ) {
            // Convert to locations that can be mapped
            locations = new List<Map<String,Double>>();
            for (Contact con : contacts) {
                locations.add( new Map<String,Double>{
                        'latitude' => con.Location__latitude__s, 
                        'longitude' => con.Location__longitude__s
                    }
                );
            }
        }
        else {
            System.debug('No results. Query: ' + queryString);
        }
                
        return null;
    }
}