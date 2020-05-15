public with sharing class Demo
{
    final Long start = Datetime.now().getTime();
    public Boolean getIsEnabled() { return Datetime.now().getTime() - start < 60 * 1000; }

    Integer count = 0;
    public Integer getCount() { return count; }
    public PageReference incrementCounter() {
        count++;
        return null;
    }
}