import { LightningElement } from 'lwc';

export default class WithoutTrackDecorator extends LightningElement {
    inputMessage11 = 'World';

     handleChange(event){
        this.inputMessage11 = event.target.value;
     }
}