trigger AccountTrigger1 on Account (before insert) {
for(Account objacc : trigger.new){
if(objacc.AnnualRevenue > 1000){
objacc.Name = 'Clerk';
}
}
}