pageextension 71801 "General Journal Ext." extends "General Journal"
{
    layout
    {
        addafter("Account No.")
        {
            field("VAT Partial Attribution"; "VAT Partial Attribution")
            {
                ApplicationArea = all; 
            }
        }
    }
}