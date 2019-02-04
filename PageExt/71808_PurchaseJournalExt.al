pageextension 71808 "Purchase Journal Ext." extends "Purchase Journal"
{
    layout
    {
        addafter("Account No.")
        {
            field("VAT Partial Attribution"; "VAT Partial Attribution")
            {
                ApplicationArea = All;
            }
        }        
    }
}