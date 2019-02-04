tableextension 71803 "Invoice Post. Buffer Ext." extends "Invoice Post. Buffer"
{
    fields
    {
        field(71800; "VAT Partial Attribution"; Option)
        {
            OptionMembers = "Full Attribution","Partial Attribution",Blocked;
        }    
    }  
}