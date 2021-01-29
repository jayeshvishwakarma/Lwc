import { LightningElement, track,api } from 'lwc';

export default class RssFeedItem extends LightningElement {

    //@api record;
    @api title;
    @api description;
    @api publishDate;
    @api tags = [];
    @api author;
    @api link;

    renderedCallback(){
        this.template.querySelector(".description").innerHTML = this.description;
    }
    // connectedCallback(){
    //     if(this.record){
    //         this.title = this.record.title;
    //         this.description = this.record.description;
    //         this.publishDate = this.record.publishdate;
    //         this.link  = this.record.link;
    //         this.author = this.record.author;
    //         this.image = this.record.imageurl;
    //         this.tags = this.record.tags;
    //     }
    // }

}