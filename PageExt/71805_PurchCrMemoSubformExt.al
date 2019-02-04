pageextension 71805 "Purch. Cr. Memo Subform Ext." extends "Purch. Cr. Memo Subform"
{
    layout
    {
        addafter("No.")
        {
            field("VAT Partial Attribution"; "VAT Partial Attribution")
            {
                ApplicationArea = All;
            }
        }
    }
}