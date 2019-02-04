pageextension 71813 "VAT Posting Setup Ext." extends "VAT Posting Setup"
{
    layout
    {
        addafter("VAT Clause Code")
        {
            field("Blocked VAT Acc.";"Blocked VAT Acc.")
            {
                ApplicationArea = All;
            }
        }
    }
}