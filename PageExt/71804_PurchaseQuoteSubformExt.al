pageextension 71804 "Purchase quote Subform Ext." extends "Purchase Quote Subform"
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