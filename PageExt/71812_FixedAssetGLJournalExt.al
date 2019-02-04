pageextension 71812 "Fixed Asset G/L Journal Ext." extends "Fixed Asset G/L Journal"
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