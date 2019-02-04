pageextension 71807 "Sales Journal Ext." extends "Sales Journal"
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