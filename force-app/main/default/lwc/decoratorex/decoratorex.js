import { LightningElement } from 'lwc';

export default class Decoratorex extends LightningElement {
     inputMessage = 'World';

     handleChange(event){
        this.inputMessage = event.target.value;
     }
}