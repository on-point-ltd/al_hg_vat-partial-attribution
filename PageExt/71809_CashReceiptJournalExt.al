pageextension 71809 "Cash Receipt Journal Ext." extends "Cash Receipt Journal"
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