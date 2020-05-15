public with sharing class UtilityClass {
     public static List<sObject> queryObjects(String theObject, List<String> theFields, List<String> theFilters, String sortField, String sortOrder) {
          String theQuery = 'SELECT ' + string.join(theFields, ',');
          theQuery += ' FROM ' + theObject;
          boolean firstFilter = true;
          for (String filter : theFilters) { //loop through the filters
               String clauseToUse = (firstFilter) ? ' WHERE ' : ' AND '; //get the right clause
               filter = filter.trim();
               filter = filter.replaceAll('(\\s+)', ' ');  //remove white spaces
               theQuery += clauseToUse + filter;  //add the filter to the query
               firstFilter = false;  //changes the filter clause
          }
          if(!String.isEmpty(sortField)) {
               theQuery += ' ORDER BY ' + sortField;
               if(!String.isEmpty(sortOrder)) {
                    theQuery += ' ' + sortOrder;
               }
          }
          String theQueryResult = string.escapeSingleQuotes(theQuery);  //escapes the string
          return database.query(theQueryResult);
     }
}