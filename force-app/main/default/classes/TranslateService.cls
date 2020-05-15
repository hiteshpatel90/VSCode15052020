public class TranslateService {

    map<string,string>  Languages = new map<string,string>{
      'ARABIC' => 'ar',
      'BULGARIAN' => 'bg',
      'CHINESE' => 'zh',
      'CHINESE_S' => 'zh-CN',
      'CHINESE_T' => 'zh-TW',
      'CROATIAN' => 'hr',
      'CZECH' => 'cs',
      'DANISH' => 'da',
      'DUTCH'=> 'nl',  
      'ENGLISH' => 'en',
      'FILIPINO' => 'tl',
      'FINNISH' => 'fi',
      'FRENCH' => 'fr',
      'GERMAN' => 'de',
      'GREEK' => 'el',
      'HEBREW' => 'iw',
      'HINDI' => 'hi',
      'INDONESIAN' => 'id',
      'ITALIAN' => 'it',
      'JAPANESE' => 'ja',
      'KOREAN' => 'ko',
      'LATVIAN' => 'lv',
      'LITHUANIAN' => 'lt',
      'NORWEGIAN' => 'no',
      'POLISH' => 'pl',
      'PORTUGUESE' => 'pt-PT',
      'ROMANIAN' => 'ro',
      'RUSSIAN' => 'ru',
      'SERBIAN' => 'sr',
      'SLOVAK' => 'sk',
      'SLOVENIAN' => 'sl',
      'SPANISH' => 'es',
      'SWEDISH' => 'sv',
      'UKRAINIAN' => 'uk',
      'VIETNAMESE' => 'vi',
      '--None--' => ''
    };
    
    public list <SelectOption> LanguageOptions { get { 
        if (LanguageOptions == null ) {
            LanguageOptions = new list <SelectOption>();
            list<string> s = new list<string>(this.Languages.keyset());
            s.sort();
            for (string key : s ) {
                LanguageOptions.add(new selectOption( this.Languages.get(key),key ) );
            } 
        }
        return LanguageOptions ;
    } private set; }
    public integer responseStatus { get { return response.getValue('responseStatus').num ; } } 
    public string responseDetails { get { return response.getValue('responseDetails').str; } } 
    public string translatedText { 
        get {
            system.debug('@@@@@@@'+response);
            system.debug('@@@@@@@'+response.getValue('responseData'));
            return response.getValue('responseData').obj.getString('translatedText'); 
        } 
    } 
 
    private jsonobject response;
    public integer debug { get; set; } { debug = 1; } 
    private string uri = 'http://ajax.googleapis.com/ajax/services/language/translate';
    // use: http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=hello%20world&langpair=en%7Cit
    
    GoogleService service = new GoogleService('translate');
    
    public googledata getfeed( string url) {
        system.debug('@@@@@@@###'+url);
        service.getFeedMethod('GET',url,null, null);
        if (debug > 1) system.debug( service.response.getBody() );
        return parseResponse( service.response.getBody() ); 
    } 

    public googledata translate (string origin,string pair ) {
        system.assert( origin.length() <= 500 , ' Google terms of service restrict to 500 chars');   
        return this.getFeed( uri + '?v=1.0&q=' + EncodingUtil.urlEncode( origin, 'UTF-8') 
         + '&langpair='  + EncodingUtil.urlEncode( pair, 'UTF-8' ) );
    }
 
    private googledata parseResponse(string body ) { 
        
        body = body.replaceAll('\\\\u0026#39;','\''); // are there others?
        response =  new jsonobject( body );
        
        if ( debug> 1) { 
            system.debug( translatedText );
            system.debug( responseStatus );
            system.debug( responseDetails );
        }
        return new GoogleData( new xmldom('<entry><translatedText>'+
            translatedText+'</translatedText><responseStatus>'+responseStatus+
            '</responseStatus></entry>') );
        
    }   
    
    
   
      
    
}