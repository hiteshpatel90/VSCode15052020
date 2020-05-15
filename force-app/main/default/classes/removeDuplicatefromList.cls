public class removeDuplicatefromList{
    /* 
    Description :  This Method is used to remove duplicate elemets from List
    Parameter   :  List of Integer
    Return type :  Unique List of Integers
    */
    public static List<Integer> removeDuplicate(List<Integer> lstIntegerA, List<Integer> lstIntegerB){
        List<Integer> finalUniqueList = new List<Integer>();
        
        // Remove Duplicate Element from List 1 -- START
        List<Integer> duplicateElemA = new List<Integer>();
        for(Integer i = 0; i<lstIntegerA.size(); i++){
            for(Integer j = i+1; j<lstIntegerA.size(); j++){
                if(lstIntegerA[i] == lstIntegerA[j]){
                    duplicateElemA.add(lstIntegerA[i]);
                }
            }
        }
        List<Integer> uniqueElemA = new List<Integer>();
        for(Integer i = 0; i<lstIntegerA.size(); i++){
            if(duplicateElemA.contains(lstIntegerA[i]) == false){
                uniqueElemA.add(lstIntegerA[i]);
            }
        }
        // Remove Duplicate Element from List 1 -- END
        
        // Remove Duplicate Element from List 2 -- START
        lstIntegerB.addAll(uniqueElemA);
        List<Integer> duplicateElemB = new List<Integer>();
        for(Integer i = 0; i<lstIntegerB.size(); i++){
            for(Integer j = i+1; j<lstIntegerB.size(); j++){
                if(lstIntegerB[i] == lstIntegerB[j]){
                    duplicateElemB.add(lstIntegerB[i]);
                }
            }
        }
        
        for(Integer i = 0; i<lstIntegerB.size(); i++){
            if(duplicateElemB.contains(lstIntegerB[i]) == false){
                finalUniqueList.add(lstIntegerB[i]);
            }
        }
        // Remove Duplicate Element from List 1 -- END
        
        return finalUniqueList;
    }
}