public class TodayDateController{
    public string strTodayDate {get; set;}
    public void displayDate(){
        strTodayDate = string.valueOf(system.today());
    }
}