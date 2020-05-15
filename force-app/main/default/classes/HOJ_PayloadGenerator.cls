/**
* @author JF Guilbert
* @date 12/01/2017
* @description Framework to generate HTTP payloads from SObject, with support for both REST & SOAP
* <p>
* Test Class: HOJ_PayloadGenerator_Test
* V1.0 -> 12/01/2017, JF Guilbert, Initial Commit + raw JSON support
* V1.5 -> 04/12/2018, Kejia Hu, Refactoring
* V2.0 -> 02/14/2018, JF Guilbert, Basic SOAP hooks
*/
global without sharing class HOJ_PayloadGenerator //without sharing is needed to query object/fields the user may not have access ex: FeedComment
{
    global enum HTTPMethod {GET, POST, PUT, DEL, SOAP}
    global static final string DATETIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';
    global static final string timezone = 'GMT';
    global static string LogFile = '';

    private static map<Id, SObject> StagingMap;
    private static map<Id, Payload_Field__c> PaylodGenMap;
    private static final Id SF_NULLID = '000000000000000AAA';

    /**
    * @Name          JSONObjectNode inner class
    * @Description   Transmit payload JSON API parameter structure baseline definition - JSON API call must [extend] this class
    * @Author        JF Guilbert
    * @CreatedDate   2017-11-27
    * @Param
    */
    global virtual class JSONObjectNode {
        /**
        * @Name          isStrValueBlank
        * @Description   Indicated if the specified JSON parameter name has a blank value or not - Blank = Null or '' or '   '
        * @Author        JF Guilbert
        * @CreatedDate   2017-11-27
        * @Param         String  parmName : Name of the JSON structure parameter to check
        * @Return        Boolean
        */
        public Boolean isStrValueBlank(String parmName){
            return String.isBlank(String.valueOf(this.get(parmName)));
        }

        /**
        * @Name          getValue
        * @Description   Dynamically get the JSON field value Object - the caller needs to cast appropriatelly
        * @Author        JF Guilbert
        * @CreatedDate   2017-11-27
        * @Param         String  parmName : Name of the JSON structure parameter to check
        * @Return        Object  - the caller needs to cast appropriatelly
        */
        public Object get(String parmName){
            try {
                return ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(this))).get(parmName);
            }
            catch(Exception ex){
                return null; // -- The caller needs to handle this situation
            }
        }
    }

    /**
    * @author JF Guilbert
    * @date 02/14/2018
    * @description SOAPObjectStub inner class -- IMPORTANT: Make the WSDL2Apex [SoapPort_*] class a sub-class of this one
    */
    global virtual class SOAPObjectStub { }
    /**
    * @author JF Guilbert
    * @date 02/14/2018
    * @description SOAPObjectRequest inner class -- IMPORTANT: Make the WSDL2Apex [request_x] class a sub-class of this one
    */
    global virtual class SOAPObjectRequest { }

    /**
    * @Name          ObjectNode
    * @Description   A helper Class to build node of SObject
    * @Author        Fan Yang
    * @CreatedDate   2017-05-13
    */
    global class ObjectNode
    {
        public list<ObjectNode> ChildNodes {get;set;}
        public SObject ReferenceObject {get; set;}
        public Id ObjectId {get; set;}

        public Boolean hasObjectId { get { return ObjectId != null && ObjectId != SF_NULLID; } }
        public Boolean hasJSONNode { get { return JSONNode != null && ObjectId == SF_NULLID; } }
        public JSONObjectNode JSONNode {get; set;}

        /**
        * @Name          ObjectNode contructor APIs (JSON)
        * @Description   Contructors for direct JSON string with Apex Type OR direct instance from a sub-class of the above JSONObjectNode class (version 2.0)
        * @Author        JF Guilbert
        * @CreatedDate   2017-11-30
        */
        public ObjectNode(String jsonInput, String jsonObjectNodeTypeName)
        {
            this((JSONObjectNode)JSON.deserialize(jsonInput, Type.forName(jsonObjectNodeTypeName)));
        }
        public ObjectNode(JSONObjectNode jsonObjNode)
        {
            JSONNode = jsonObjNode;
            ObjectId = SF_NULLID;
            ChildNodes = new List<ObjectNode>();
        }
        /**
        * @Name          ObjectNode contructor APIs (SObject Id)
        * @Description   Contructors for SObject Id dynamic handling (version 1.*)
        * @Author        Fan Yang
        * @CreatedDate   2017-05-13
        */
        public ObjectNode(Id objectId)
        {
            this(objectId, new list<ObjectNode>());
        }
        public ObjectNode(Id objectId, list<ObjectNode> childNodes)
        {
            this.ObjectId = objectId;
            this.ChildNodes = childNodes;
        }
        public ObjectNode(sObject refObject)
        {
            this(refObject, new list<ObjectNode>());
        }
        public ObjectNode(sObject refObject, list<ObjectNode> childNodes)
        {
            this.ReferenceObject = refObject;
            this.ChildNodes = childNodes;
        }
    }

    /**
    * @Name          generateJSON
    * @Description   generate JSON payload based on operation and fields
    * @Author        Kejia Hu
    * @CreatedDate   2017-11-29
    * @Param         Id objectId
    * @Param         String opsName
    * @Return        String
    */
    public static String generateJSON(Id objectId, String opsName){
        HOJ_PayloadOperation ops = HOJ_PayloadOperation.getByName(opsName);
        HOJ_PayloadGenerator.HTTPMethod method = HOJ_PayloadGenerator.parseHttpMethod(ops.HttpMethod);
        return HOJ_PayloadGenerator.Serialize(new HOJ_PayloadGenerator.ObjectNode(objectId), opsName, method);
    }

    /**
    * @Name          Serialize
    * @Description   Serialize SObject into JSON String
    * @Author        Fan Yang
    * @CreatedDate   2017-05-13
    * @Param         ObjectNode objectNode
    * @Param         String operationName
    * @Param         HTTPMethod httpMethod
    * @Return        string
    */
    webservice static string Serialize(ObjectNode objectNode, String operationName, HTTPMethod httpMethod)
    {
        String retVal = '';
        HOJ_PayloadOperation operation = HOJ_PayloadOperation.getByName(operationName);
        if(operation == null)
            throw new PayloadException('Payload Operation is not defined - ' + operationName);

        if(objectNode.hasJSONNode)
            retVal = JSON.serializePretty(objectNode.JSONNode);
        else{
            PaylodGenMap =  InitPayloadEntries(operation, httpMethod);
            StagingMap = BuildStagingMap(objectNode);
            StagingMap = GetSObjects(StagingMap.keyset());
            map<Id, SObject> extendedMap = BuildExtendedStagingMap(StagingMap, objectNode, 1, operation, httpMethod);
            StagingMap.putAll(GetSObjects(extendedMap.keyset()));
            map<String,Object> aMap = PopulateMap(objectNode, operation, httpMethod);
            retVal = Serialize(PopulateMap(objectNode, operation, httpMethod));
        }
        return retVal;
    }

    private static string Serialize(Object objectMap)
    {
        string retVal = JSON.serializePretty(objectMap);
        WriteLog('Serialize Map JSON String', retVal);
        return retVal;
    }

    private static map<Id, SObject> BuildStagingMap(ObjectNode objectNode)
    {
        map<Id, SObject> retVal = new map<Id, SObject>();

        retVal.put(objectNode.ObjectId, null);

        if (objectNode.ChildNodes != null)
            for (ObjectNode childNode : objectNode.ChildNodes)
                retVal.putAll(BuildStagingMap(childNode));

        return retVal;
    }

    private static map<Id, SObject> BuildExtendedStagingMap(map<Id, SObject> baseMap, ObjectNode objectNode, integer groupingLevel, HOJ_PayloadOperation operation, HTTPMethod httpMethod)
    {
        map<Id, SObject> retVal = new map<Id, SObject>();
        SObject refRecord = baseMap.get(objectNode.ObjectId);

        List<Payload_Field__c> payloadEntries = RetrievePayloadEntries(operation, httpMethod, groupingLevel);
        for (Payload_Field__c payloadEntry : payloadEntries)
        {
            if (payloadEntry.Salesforce_Field__c != null)
            {
                if (payloadEntry.Salesforce_Field__c != '')
                {
                    string fieldName = payloadEntry.Salesforce_Field__c;

                    if (payloadEntry.Salesforce_Field__c.indexOf('.') != -1)
                    {
                        Schema.SObjectField field = refRecord.getSobjectType().getDescribe().fields.getMap().get(payloadEntry.Salesforce_Field__c.split('\\.')[0].replace('__r', '__c'));

                        if (field != null)
                        {
                            if (refRecord.get(field) != null)
                                retVal.put((Id)refRecord.get(field), null);
                        }
                    }
                }
            }
        }
        if (objectNode.ChildNodes != null)
            for (ObjectNode childNode : objectNode.ChildNodes)
                retVal.putAll(BuildExtendedStagingMap(baseMap, childNode, groupingLevel + 1, operation, httpMethod));

        return retVal;
    }

    private static map<string, Object> PopulateMap(ObjectNode objectNode, HOJ_PayloadOperation operation, HTTPMethod httpMethod)
    {
        return PopulateMap(objectNode, 1, operation, httpMethod);
    }

    private static map<string, Object> PopulateMap(ObjectNode objectNode, integer groupingLevel, HOJ_PayloadOperation operation, HTTPMethod httpMethod)
    {
        sObject refObject = null;

        if (StagingMap.containsKey(objectNode.ObjectId))
            refObject = StagingMap.get(objectNode.ObjectId);

        map<string, Object> retVal = new map<string, Object>();

        WriteLog('PopulateMap refObject', string.valueof(refObject));
        List<Payload_Field__c> payloadEntries = RetrievePayloadEntries(operation, httpMethod, groupingLevel);

        for (Payload_Field__c payloadEntry : payloadEntries)
        {
            if(GetPayloadValue(refObject, payloadEntry) !=  null || payloadEntry.Render_If_Null__c == true){
                if (payloadEntry.Grouping_Array__c == null)
                    NavigateToFolder(retval, payloadEntry.Path__c).put(payloadEntry.JSON_Field__c, GetPayloadValue(refObject, payloadEntry));
                if (payloadEntry.Grouping_Array__c != null)
                    retval.put(payloadEntry.JSON_Field__c, GetPayloadValue(refObject, payloadEntry));
            }
        }
        if (objectNode.ChildNodes != null)
        {
            List<Payload_Field__c> childEntries = RetrievePayloadEntries(operation, httpMethod,  groupingLevel + 1);

            string groupingArray = null;
            string groupingPath = null;

            for (Payload_Field__c payloadEntry : childEntries)
            {
                if (payloadEntry.Grouping_Array__c != null)
                {
                    groupingArray = payloadEntry.Grouping_Array__c;
                    groupingPath = payloadEntry.Path__c;
                }
            }

            list<Object> childList = new list<Object>();

            for (ObjectNode childNode : objectNode.ChildNodes)
                childList.add(PopulateMap(childNode, groupingLevel + 1, operation, httpMethod));

            if (groupingArray != null)
            {
                map<String, Object> groupingMap = NavigateToFolder(retVal, groupingPath);
                groupingMap.put(groupingArray, childList);
            }
        }
        return retVal;
    }

    private static Map<String, Object> NavigateToFolder(Map<String, Object> rootMap, String path)
    {
        Map<String, Object> retVal = rootMap;

        if (path != null)
        {
            for (string folder : path.split('\\/'))
            {
                if (folder != null && folder != '')
                {
                    if (IsGroup(folder))
                    {
                        list<Map<String, Object>> groupingList;

                        if (!retVal.containsKey(GroupName(folder)))
                            retVal.put(GroupName(folder), new List<Map<String, Object>>());

                        groupingList = (list<Map<String, Object>>)retVal.get(GroupName(folder));

                        Integer groupIndex = 0;

                        while( groupIndex  <= GroupIndex(folder))
                        {
                            if(groupingList.size() < groupIndex + 1)
                                groupingList.add(new Map<String, Object>());
                            groupIndex ++;
                        }

                        retVal = groupingList[GroupIndex(folder)];
                    }
                    else
                    {
                        if (!retVal.containsKey(folder))
                        {
                            Map<String, Object> currentMap = new map<String, Object>();
                            retVal.put(folder, currentMap);

                        }
                        retVal = (map<String, Object>)retVal.get(folder);
                    }
                }
            }
        }
        return retval;
    }

    public static boolean IsGroup(String path)
    {
        String strRegEx = '(?<=\\[)[0-9](?=\\])';

        Pattern MyPattern = Pattern.compile(strRegEx);
        Matcher MyMatcher = MyPattern.matcher(path);

        return MyMatcher.find();
    }

    public static Integer GroupIndex(String path)
    {
        Integer retVal = null;
        String strRegEx = '(?<=\\[)[0-9](?=\\])';

        Pattern MyPattern = Pattern.compile(strRegEx);
        Matcher MyMatcher = MyPattern.matcher(path);

        if (MyMatcher.find())
            retVal = Integer.valueOf(MyMatcher.group(0));

        return retVal;
    }

    public static String GroupName(String path)
    {
        String strRegEx = '[a-zA-Z]*(?=\\[)';
        String retVal = null;

        Pattern MyPattern = Pattern.compile(strRegEx);
        Matcher MyMatcher = MyPattern.matcher(path);

        if (MyMatcher.find())
            retVal = MyMatcher.group(0);

        return retVal;
    }

    @TestVisible
    private static Map<Id, Payload_Field__c> InitPayloadEntries(HOJ_PayloadOperation operation, HTTPMethod httpMethod)
    {
            Map<Id, Payload_Field__c> retVal =  new Map<Id, Payload_Field__c>(
                [SELECT Active__c,Grouping_Level__c, Default_Value__c, Cross_Object_Id_Field__c,
                Grouping_Array__c,HTTP_GET__c, HTTP_POST__c, HTTP_PUT__c, HTTP_DELETE__c,
                JSON_Field__c,Null_to_Blank__c,Operation_Id__c, Path__c, Salesforce_Field__c,
                Target_System_Type__c,Target_Object_Name__C, Transformation__c, Render_If_Null__c
                FROM Payload_Field__c where Operation_Id__c =: operation.Id and Active__c = true order by JSON_Field__c ASC]);

            return retVal;
    }

    private static list<Payload_Field__c> RetrievePayloadEntries(HOJ_PayloadOperation operation, HTTPMethod httpMethod, integer groupingLevel)
    {
        list<Payload_Field__c> retVal = new list<Payload_Field__c>();

        for (Payload_Field__c payloadEntry : PaylodGenMap.values())
        {
            if (payloadEntry.Grouping_Level__c == groupingLevel)
            {
                if (httpMethod == HOJ_PayloadGenerator.HTTPMethod.GET && payloadEntry.HTTP_GET__c)
                    retVal.add(payloadEntry);
                if (httpMethod == HOJ_PayloadGenerator.HTTPMethod.POST && payloadEntry.HTTP_POST__c)
                    retVal.add(payloadEntry);
                if (httpMethod == HOJ_PayloadGenerator.HTTPMethod.PUT && payloadEntry.HTTP_PUT__c)
                    retVal.add(payloadEntry);
                if (httpMethod == HOJ_PayloadGenerator.HTTPMethod.DEL && payloadEntry.HTTP_DELETE__c)
                    retVal.add(payloadEntry);
            }
        }
        WriteLog('Payload Generator List', string.valueof(retVal));
        return retVal;
    }

    private static object GetPayloadValue(SObject refRecord,  Payload_Field__c payloadEntry)
    {
        Object retVal = payloadEntry.Default_Value__c;
        String fieldName = null;
        SObject sRefRecord = refRecord;
        //if (refRecord != null)
        {
            if (payloadEntry.Salesforce_Field__c != null)
            {
                if (payloadEntry.Salesforce_Field__c != '')
                {
                    fieldName = payloadEntry.Salesforce_Field__c;

                    if (payloadEntry.Salesforce_Field__c.indexOf('.') != -1)
                    {
                        Schema.SObjectField field = sRefRecord.getSobjectType().getDescribe().fields.getMap().get(payloadEntry.Salesforce_Field__c.split('\\.')[0].replace('__r', '__c'));

                        if (field != null)
                        {
                            sRefRecord = sRefRecord.getSObject(field);
                            if (sRefRecord != null)
                            {

                                sRefRecord = StagingMap.get(sRefRecord.Id);
                                fieldName = payloadEntry.Salesforce_Field__c.split('\\.')[1];
                            }
                        }
                    }
                    if (sRefRecord != null)
                    {
                        if (ValidateField(sRefRecord, fieldName))
                        {
                            retVal = sRefRecord.get(fieldName);
                            if (retVal == null)
                                retVal = payloadEntry.Default_Value__c;
                        }
                    }
                }
            }

            WriteLog(fieldName + ' before transformation', string.valueof(retval));
            if (payloadEntry.Transformation__c != null)
            {
                retval = TransformValue( (map<String, Object>)JSON.deserializeUntyped(payloadEntry.Transformation__c), retVal);
            }

            WriteLog(fieldName + ' after transformation', string.valueof(retval));

            if(payloadEntry.Target_System_Type__c  != null)
            {
                if (payloadEntry.Target_System_Type__c.ToLowerCase() == 'boolean' || payloadEntry.Target_System_Type__c.ToLowerCase() == 'checkbox')
                {
                    retVal = retVal == null ? false : Boolean.valueof(retVal);
                }
                if (payloadEntry.Target_System_Type__c.ToLowerCase()  == 'text' || payloadEntry.Target_System_Type__c.ToLowerCase()  == 'string'  || payloadEntry.Target_System_Type__c.ToLowerCase()  == 'lookup'  || payloadEntry.Target_System_Type__c.ToLowerCase()  == 'picklist' )
                {
                    if (retVal != null && retVal instanceof boolean)
                        retVal = retVal == true ? 'true' : 'false';
                    else{
                            retVal = string.valueof(retVal);

                        }
                }
                if (payloadEntry.Target_System_Type__c.ToLowerCase() == 'integer')
                {
                    if (retVal == false)
                        retVal = 0;
                    else if (retVal == true)
                        retVal = 1;
                    else
                        retVal = Integer.valueOf(retVal);
                }
                if (payloadEntry.Target_System_Type__c.ToLowerCase()  == 'date' ||  payloadEntry.Target_System_Type__c.ToLowerCase()  == 'datetime')
                {
                    if (retval != null)
                    {
                        //Date is instanceof DateTime but DateTime is not instanceof Date
                        // need to check instanceof Date first
                        if (retVal instanceof Date)
                            retVal =  DateToString((Date)retVal);

                        if (retVal instanceof DateTime)
                            retVal =  DatetimeToString((DateTime)retVal);


                    }
                }
                if (payloadEntry.Target_System_Type__c.ToLowerCase()  == 'decimal')
                {
                    if (retVal != null)
                        retVal = Decimal.valueOf(string.valueOf(retVal));
                }
            }

            if(payloadEntry.Render_If_Null__c == true){
                if (retVal == null && payloadEntry.Null_To_Blank__c == true)
                {
                    retVal = '';
                }
            }
        }
        return retVal;
    }

    private static Object TransformPayload(Map<String, Object> transformationMap, list<Object> payloadValues)
    {
        Object retVal = null;

        if (payloadValues != null)
        {
            if (transformationMap.get('TransformationId') == 'ConvertToList')
            {
                String listSeparator = (String)transformationMap.get('ListSeparator');
                String entryKey = (String)transformationMap.get('ListEntryKey');

                for (Object tempObject : payloadValues)
                {
                    map<string, Object> objectMap = (map<string, Object>)tempObject;

                    if (retVal == null)
                        retVal = String.format('{0}{1}', new String[]{String.valueof(objectMap.get(entryKey)), listSeparator});
                    else
                        retVal = String.format('{0}{1}{2}', new String[]{String.valueof(retVal), String.valueof(objectMap.get(entryKey)), ListSeparator});
                }
            }

            if (transformationMap.get('TransformationId') == 'Replace')
            {
                list<Object> replacementList = (list<Object>)transformationMap.get('Replace');

                for (Object tempObject : payloadValues)
                {
                    for (Object replacementEntry : replacementList)
                    {
                        map<string, Object> replacementMap = (map<string,Object>)replacementEntry;

                        for(string key : replacementMap.keyset())
                        {
                            string keyValue = string.valueof(replacementMap.get(key));
                            // First we check is there is a corresponding entry in the map by keyset
                            if (key.ToLowerCase() == string.valueof(tempObject).ToLowerCase())
                            {
                                retVal = replacementMap.get(key);
                            }
                            // Then we also check if there is a match on the value side of the transformation map.
                            if (keyValue.ToLowerCase() == string.valueof(tempObject).ToLowerCase())
                            {
                                retVal = key;
                            }
                        }
                    }
                }
            }
            if (transformationMap.get('TransformationId') == 'Sanitize')
            {
                Object anObject = payloadValues.get(0);
            }

            if (transformationMap.get('TransformationId') == 'calculateClosingDate') {
                retVal = String.valueOf(HOJ_CalculatePaymentHandler.calculateNextBusinessDay(Date.today()));
            }
        }
        return retVal;
    }

    /**
    * @Name          TransformValue
    * @Description   Transform field value based on the transformation rule
    * @Author        Fan Yang
    * @CreatedDate   2017-05-23
    * @Param         map<String, Object> transformationMap
    * @Param         Object value
    * @Return        Object
    */
    @TestVisible
    private static Object TransformValue(map<String, Object> transformationMap, Object value)
    {
        Object retVal = value;

        if (value != null)
        {
            if (transformationMap.get('TransformationId') == 'Replace')
            {
                list<Object> replacementList = (list<Object>)transformationMap.get('Replace');

                for (Object replacementEntry : replacementList)
                {
                    map<string, Object> replacementMap = (map<string,Object>)replacementEntry;

                    for(string key : replacementMap.keyset())
                    {
                        if (key.ToLowerCase() == string.valueof(value).ToLowerCase())
                        {
                            retVal = replacementMap.get(key);
                        }
                    }
                }
            }

            if (transformationMap.get('TransformationId') == 'ConvertToList')
            {
                String listSeparator = (String)transformationMap.get('ListSeparator');
                String entryKey = (String)transformationMap.get('ListEntryKey');
                List<Object> arrayList = new List<Object>();

                if (value != null)
                {
                    for (string listEntry : string.valueof(value).split(listSeparator))
                    {
                        map<string, string> objectMap = new map<string, string>();
                        objectMap.put(entryKey, listEntry);
                        arrayList.add(objectMap);
                    }
                }

                retVal = arrayList;
            }

            if (transformationMap.get('TransformationId') == 'Format')
            {
                String formatString = (String)transformationMap.get('FormatString');
                retVal = String.format(formatString, new string[]{string.valueof(value)});
            }

            if (transformationMap.get('TransformationId') == 'Template'){
                String template = String.valueOf(transformationMap.get('Template'));
                while(String.isEmpty(template)){
                    template = String.valueOf(transformationMap.get('template'));
                    if(String.isEmpty(template)){
                        throw new PayloadException('Couldn\'t find the payloader template attribute');
                    }
                }
                retval = template.replaceAll('this.value', String.valueOf(value));
            }

            if (transformationMap.get('TransformationId') == 'FormatDate')
            {
                //retVal = String.valueOf(value).substring(0,10);
                List<String> res = String.valueOf(value).split(' ');
                if (res.size() > 1)
                    retVal = res[0];
            }

        }

        if (transformationMap.get('TransformationId') == 'calculateClosingDate') {
            retVal = String.valueOf(HOJ_CalculatePaymentHandler.calculateNextBusinessDay(Date.today()));
        }

        return retVal;
    }



    @TestVisible private static void PopulateObjectValue(SObject refObject,  Payload_Field__c payloadEntry, map<string, Object> payloadMap)
    {
        Object fieldValue = payloadEntry.Default_Value__c;

        if (payloadEntry.JSON_Field__c != null)
        {
            if(payloadMap.containsKey(payloadEntry.JSON_Field__c))
            {
                Object payloadValue = payloadMap.get(payloadEntry.JSON_Field__c);
                fieldValue = payloadValue;
            }
        }

        if (payloadEntry.Salesforce_Field__c != null)
        {
            String fieldName = payloadEntry.Salesforce_Field__c.indexOf('.') == -1 ? payloadEntry.Salesforce_Field__c : payloadEntry.Salesforce_Field__c.split('\\.')[0].replace('__r', '__c');

            if ( ValidateFieldIsCreateable(refObject, fieldName) || ValidateFieldIsUpdatable(refObject, fieldName) )
            {
                Schema.DisplayType fieldType =  GetFieldType( refObject, fieldName);

                if ( fieldValue != null)
                {
                    if (payloadEntry.Transformation__c != null)
                    {
                        try
                        {
                            if (! (fieldValue instanceof list<Object>))
                            {
                                list<Object> tempList = new list<Object>();
                                tempList.add(fieldValue);
                                fieldValue = tempList;
                            }

                            refObject.put(fieldName, TransformPayload((map<String, Object>)JSON.deserializeUntyped(payloadEntry.Transformation__c), (list<Object>)fieldValue));
                        }
                        catch(Exception e)
                        {
                            WriteLog('Transformation Exception', string.valueOf(e));
                        }
                    }
                    else
                    {
                        fieldValue = ParseValue(refObject, fieldName, fieldValue);

                        if (fieldType == Schema.DisplayType.Reference && payloadEntry.Default_Value__c == null)
                        {
                            if(payloadEntry.Cross_Object_Id_Field__c != null)
                                SetExternalId(refObject, payloadEntry, fieldValue);
                        }
                        else
                        {
                            refObject.put(fieldName, fieldValue);
                        }
                    }
                }
            }
        }
    }

    @TestVisible
    private static Object ParseValue(sObject refObject, string fieldName, Object fieldValue)
    {
        Object retVal = fieldValue;
        Schema.DisplayType fieldType =  GetFieldType( refObject, fieldName);
        if (fieldType ==  Schema.DisplayType.Boolean)
        {
            if (string.valueof(fieldValue) == '0')
                retVal = false;
            else if (string.valueof(fieldValue) == '1')
                retVal = true;
            else
                retVal =  boolean.valueof(fieldValue);
        }
        else if (fieldType ==  Schema.DisplayType.DateTime)
        {
            retVal = StringToDateTime(string.valueof(fieldValue));
        }
        else if (fieldType ==  Schema.DisplayType.Date)
        {
            retVal = StringToDate(string.valueof(fieldValue));
        }
        else if (fieldType ==  Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Percent || fieldType == Schema.DisplayType.Double )
        {
            retVal =  Decimal.valueOf(string.valueOf(fieldValue));
            //fieldValue =  tempValue.setScale(2);
        }
        else if (fieldType ==  Schema.DisplayType.Integer)
        {
             retVal =  Integer.valueof(fieldValue);
        }
        else if (fieldType != Schema.DisplayType.Reference) // Mostly text fields
        {
              retVal = String.valueof(fieldValue);
        }
        return retVal;

    }

    /**
    * @Name          SetExternalId
    * @Description   Set Id of cross object
    * @Author        Fan Yang
    * @CreatedDate   2017-05-22
    * @Param         Sobject refObject
    * @Param         Payload_Field__c setting
    * @Param         Object value
    * @Return        void
    */
    @TestVisible
    private static void SetExternalId(Sobject refObject, Payload_Field__c setting, Object value)
    {
        String relationshipName = setting.Relationship_Name__c;
        String fieldName = setting.Cross_Object_Id_Field__c;
        String lookupField = setting.Salesforce_Field__c.indexOf('.') == -1 ? setting.Salesforce_Field__c : setting.Salesforce_Field__c.split('\\.')[0];

        if  (relationshipName != null && fieldName != null)
        {
            if (lookupField != null)
            {
                refObject.putSobject(relationshipName, null);

                if (value != null)
                {
                    schema.SObjectType targetType = Schema.getGlobalDescribe().get(setting.Target_Object_Name__C);
                    sobject targetObject = targetType.newSObject();

                    // 2015-05-28 - Terrible limitation of auto-number with external id.  https://community.informatica.com/docs/DOC-2805
                    if (targetObject.getSobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().isAutoNumber() || targetObject.getSobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().isExternalID() == false)
                    {
                        string extObjQuery = string.format('Select Id from {0} where {1} = \'\'{2}\'\' limit 1', new string[]{setting.Target_Object_Name__C, fieldName, string.valueof(value)});

                        for (sObject tempObject : Database.query(extObjQuery))
                        {
                            targetObject =  tempObject;

                            refObject.put(lookupField.replace('__r', '__c'), targetObject.Id);
                        }
                    }
                    else
                    {
                        targetObject.put(fieldName, ParseValue(targetObject, fieldName, value));
                        refObject.putSobject(relationshipName, targetObject);
                    }
                }
            }
        }
    }

    private static void WriteLog(string subject, string message)
    {
        if (Limits.getHeapSize() < 275000)
        {
            string logEntry = String.format('Payload Generator Log | Timestamp : {0} Subject : {1},  Message : {2}', new string[]{string.valueof(Datetime.now()),  subject, message});

            LogFile = String.format('{0}\n {1}', new string[]{LogFile, logEntry});
        }
    }

    /**
    * @Name          DateToString
    * @Description   Convert a Salesforce datetime to ISO 8601 datetime.
    * @Author        Fan Yang
    * @CreatedDate   2017-05-22
    * @Param         Date sfdcDate
    * @Return        String
    */
    public Static String DateToString(Date sfdcDate)
    {
        DateTime tempTime = DateTime.newInstanceGmt(sfdcDate, Time.newInstance(0,0,0,0));
        return tempTime.format(DATETIME_FORMAT, 'GMT');//a date needs to stay as a date no timezone is applied
    }

    public Static String DatetimeToString(Datetime sfdcDate)
    {
        string retVal = '';
        retVal = sfdcDate.format(DATETIME_FORMAT, timezone);
        return retVal;
    }

    public static DateTime StringToDateTime(String jsonDateTime) {
        String dateTimeResult = null;
        if (jsonDateTime != null)
            if (jsonDateTime.indexOf('"') == -1)
                dateTimeResult = string.format('\"{0}\"', new string[]{jsonDateTime});

        Datetime retVal = (Datetime)JSON.deserialize(dateTimeResult, DateTime.class);

        // Pierre Dufour - 2015-05-25 -   Known bugs on date time parsing : http://salesforce.stackexchange.com/questions/1013/parsing-an-iso-8601-timestamp-to-a-datetime
        retVal = DateTime.newInstance( retVal.getTime());

        return retVal;
    }

    public static Date StringToDate(String sJsonDate) {
        Date retVal = null;

        DateTime tempValue = StringToDateTime(sJsonDate);

        if (tempValue != null)
        {
            retval = tempValue.dateGmt();
        }

        return retVal;
    }

    public static void FlushLog()
    {
        LogFile = '';
    }

    /**
    * @Name          GetSObject
    * @Description   Get all fields for sobject ids passed in parameters
    * @Author        Fan Yang
    * @CreatedDate   2017-05-22
    * @Param         Id recordId
    * @Return        sObject
    */
    public static sObject GetSObject(Id recordId)
    {
        SObject retVal = null;
        List<Id> idsList = new List<Id>();
        idsList.add(recordId);

        for (SObject tempObject : GetSObjects(idsList))
            retVal = tempObject;

        return retVal;
    }

    /**
    * @Name          GetSObjects
    * @Description   Get all field for sobject ids passed in parameters
    * @Author        Fan Yang
    * @CreatedDate   2017-05-22
    * @Param         set<Id> recordIds
    * @Return        map<Id, sObject>
    */
    public static map<Id, sObject> GetSObjects(set<Id> recordIds)
    {
        map<Id, SObject> retVal = new map<Id, SObject>();

        map<string, set<Id>> idsMap= new map<string, set<Id>>();

        for (Id tempId : recordIds)
        {
            if (tempId == SF_NULLID) continue;

            String idPrefix = String.valueOf(tempId).substring(0,3);
            if (!idsMap.containsKey(idPrefix))
                idsMap.put(idPrefix, new set<Id>());

            set<Id> IdsSet = idsMap.get(idPrefix);
            IdsSet.add(tempId);
        }

        for (set<Id> IdsSet : idsMap.values())
            for (sObject tempObject : GetSObjects(new list<Id>(IdsSet)))
                retVal.put(tempObject.Id, tempObject);

        return retVal;
    }

    /**
    * @Name          GetSObjects
    * @Description   Get all field for sobject ids passed in parameters
    * @Author        Fan Yang
    * @CreatedDate   2017-05-22
    * @Param         list<Id> recordIds
    * @Return        list<sObject>
    */
    public static list<sObject> GetSObjects(list<Id> recordIds)
    {
        list<sObject> retVal = new list<sObject>();

        if (!recordIds.isEmpty())
        {
            Id recordId = null;
            list<string> recordIdsString = new list<string>();

            for (Id tempId : recordIds)
            {
                recordId = tempId;
                recordIdsString.add('\'' +  string.valueOf(tempId) + '\'');
            }

            String objectName = recordId.getSObjectType().getDescribe().getName();
            List<String> fieldsList = new List<String>();

            for(SObjectField field  : recordId.getSObjectType().getDescribe().fields.getMap().values())
            {
                fieldsList.add(field.getDescribe().getName());
                if(field.getDescribe().getType() == Schema.DisplayType.Reference)
                    if (field.getDescribe().getRelationshipName() != null)
                        fieldsList.add(string.format('{0}.Id', new string[]{field.getDescribe().getName().replace('__c', '__r').replace('Id', '')}));
            }

            String soqlQuery= ''
                    + ' select ' + String.join(fieldsList, ',')
                    + ' from ' + objectName
                    + ' where Id in  (' + String.join(recordIdsString, ',') +  ') ALL ROWS' ;
            retVal =  Database.query(soqlQuery);
        }
        return retVal;
    }

    public static boolean ValidateField(SObject refObject, string fieldName)
    {
        boolean retVal = false;
        retval = refObject.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);

        return retVal;
    }

    public static boolean ValidateFieldIsCreateable(SObject refObject, string fieldName)
    {
        boolean retVal = false;
        retval = refObject.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);

        if (retVal)
            retVal = refObject.getSobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().isCreateable ();

        return retVal;
    }

    public static boolean ValidateFieldIsUpdatable(SObject refObject, string fieldName)
    {
        boolean retVal = false;
        retval = refObject.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);

        if (retVal)
            retVal = refObject.getSobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().isUpdateable();

        return retVal;
    }

    public static Schema.DisplayType GetFieldType(SObject refObject, string fieldName)
    {
        Schema.DisplayType retVal = null;
        retVal = refObject.getSobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
        return retVal;
    }

    /**
    * @Name          parseHttpMethod
    * @Description   Parse String into HttpMethod enum
    * @Author        Fan Yang
    * @CreatedDate   2017-05-22
    * @Param         String s
    * @Return        HTTPMethod
    */
    public static HTTPMethod parseHttpMethod(String s){
        if(!String.isEmpty(s)){
            List<HTTPMethod> enumValues = HTTPMethod.values();
            for(HTTPMethod e : enumValues){
                String v = e.name().toLowerCase();
                if(s.toLowerCase().equals(v)){
                    return e;
                }
            }
        }

        return null;
    }


    /**
    * @Name          PayloadException
    * @Description   Exception Class
    * @Author        Fan Yang
    * @CreatedDate   2017-05-22
    */
    global class PayloadException extends Exception{}
}