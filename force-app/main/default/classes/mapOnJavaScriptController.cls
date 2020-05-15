public class mapOnJavaScriptController{
    public string mapPriceCodeEvaluateOutput {get; set;}
    public mapOnJavaScriptController(){
        map<String, String> mapPriceCodeEvaluate = new map<String, String>();
        mapPriceCodeEvaluate.Put('AD','1 && 1');
        mapPriceCodeEvaluate.Put('IF','1 && 0');
        mapPriceCodeEvaluateOutput  = JSON.serialize(mapPriceCodeEvaluate);
    }
}