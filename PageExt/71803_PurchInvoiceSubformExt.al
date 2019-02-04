pageextension 71803 "Purch. Invoice Subform Ext." extends "Purch. Invoice Subform"
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