export const fieldColumns = [
                                //{label : "ID", fieldName : "Id", value: 'text'},
                                {label: "Account Name",fieldName : "Name", type : "text", editable:true},
                                {label: "Account Phone",fieldName : "Phone", type : "text", editable:true},
                                {label: "Account City",fieldName : "BillingCity", type : "phone", editable:true},
                                {
                                    label: 'Delete',
                                    type: "button", 
                                    typeAttributes: {
                                    iconName:'utility:delete',   
                                    name: 'Delete_Record',
                                    title: 'Delete',
                                    disabled: false,
                                    value: 'Delete',
                                }},
                            ];