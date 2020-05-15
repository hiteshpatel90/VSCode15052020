trigger CreateDefaultSubscriptions on Contact (after insert) {
  
//  UpdateSubscriptions us = new UpdateSubscriptions();
 // us.doAutoSubscribe(Trigger.newMap);
UpdateSubscriptions.doAutoSubscribe(Trigger.newMap.keyset());

}