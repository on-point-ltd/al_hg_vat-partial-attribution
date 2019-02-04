pageextension 71810 "Payment Journal Ext." extends "Payment Journal"
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