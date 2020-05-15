/*
  * @auther : Srinivas Sattoor, Cloud Sherpas Inc.
  * @date : 03/18/2016
  * @description : This is the factory class for default model.
  */
public class DefaultObjFactory {

    /*
     * @auther : Srinivas Sattoor, Cloud Sherpas Inc.
     * @date : 03/18/2016
     * @description : Create concrete classes for default.
     * @parameters : objIdStr - The object ID.
     * @returns : DefaultAbstract
     */
    public static DefaultAbstract build(String objIdStr) {
        return null;
        //return new DefaultGenericImpl();        
    }
}