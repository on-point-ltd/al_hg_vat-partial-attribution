pageextension 71802 "Purchase Order Subform Ext." extends "Purchase Order Subform"
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