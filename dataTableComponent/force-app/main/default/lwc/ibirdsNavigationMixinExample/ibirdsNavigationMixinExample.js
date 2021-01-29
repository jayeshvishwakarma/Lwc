import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class IbirdsNavigationMixinExample extends NavigationMixin(LightningElement) {


    handleAccountHomePageClick()
    {
        this[NavigationMixin.Navigate](
                                        {
                                            type : "standard__objectPage",
                                            attributes :    {
                                                                objApiName : "Account",
                                                                actionName : "home"
                                                            }
                                        } 
                                     )
    }

    handleAccountRecentList()
    {
        this[NavigationMixin.Navigate](
                                        {
                                            type : "standard__objectPage",
                                            attributes :    {
                                                                objApiName : "Account",
                                                                actionName : "list"
                                                            },
                                            state : {
                                                        filterName : "Recent"
                                                    }
                                        } 
                                    )
    }

}