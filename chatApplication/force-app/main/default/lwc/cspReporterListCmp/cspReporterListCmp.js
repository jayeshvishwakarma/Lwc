import { LightningElement } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import gliter from '@salesforce/resourceUrl/gliter'

export default class CspReporterListCmp extends LightningElement {
    connectedCallback() {

        Promise.all([
          loadStyle(this, gliter + '/glider.css'),
          loadScript(this, gliter + '/glider.js')
        ]).then(() => {
            console.log('come in js');
            this.template.querySelector('.glider').addEventListener('glider-slide-visible', function(event){
                var glider = Glider(this);
                console.log('Slide Visible %s', event.detail.slide)
            });
            this.template.querySelector('.glider').addEventListener('glider-slide-hidden', function(event){
                console.log('Slide Hidden %s', event.detail.slide)
            });
            this.template.querySelector('.glider').addEventListener('glider-refresh', function(event){
                console.log('Refresh')
            });
            this.template.querySelector('.glider').addEventListener('glider-loaded', function(event){
                console.log('Loaded')
            });
    
            window._ = new Glider(this.template.querySelector('.glider'), {
                slidesToShow: 1, //'auto',
                slidesToScroll: 1,
                itemWidth: 150,
                draggable: true,
                scrollLock: false,
                dots: '#dots',
                rewind: true,
                arrows: {
                    prev: '.glider-prev',
                    next: '.glider-next'
                },
                responsive: [
                    {
                        breakpoint: 800,
                        settings: {
                            slidesToScroll: 'auto',
                            itemWidth: 300,
                            slidesToShow: 'auto',
                            exactWidth: true
                        }
                    },
                    {
                        breakpoint: 700,
                        settings: {
                            slidesToScroll: 4,
                            slidesToShow: 4,
                            dots: false,
                            arrows: false,
                        }
                    },
                    {
                        breakpoint: 600,
                        settings: {
                            slidesToScroll: 3,
                            slidesToShow: 3
                        }
                    },
                    {
                        breakpoint: 500,
                        settings: {
                            slidesToScroll: 2,
                            slidesToShow: 2,
                            dots: false,
                            arrows: false,
                            scrollLock: true
                        }
                    }
                ]
            });
        });
      }
}