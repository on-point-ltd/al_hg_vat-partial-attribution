pageextension 71800 "G/L Account Card Ext." extends "G/L Account Card"
{
    layout
    {
        addafter("Default Deferral Template Code") 
        {
            field("VAT Partial Attribution"; "VAT Partial Attribution")
            {
                ApplicationArea = all;                            
            }
        }
    }
}