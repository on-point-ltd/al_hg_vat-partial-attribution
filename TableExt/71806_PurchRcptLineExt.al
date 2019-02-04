tableextension 71806 "Purch. Rcpt. Line Ext." extends "Purch. Rcpt. Line"
{
    fields
    {
        field(71800; "VAT Partial Attribution"; Option)
        {
            OptionMembers = "Full Attribution","Partial Attribution",Blocked;
        }
    }
}