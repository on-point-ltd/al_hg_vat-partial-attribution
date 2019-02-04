tableextension 71808 "Purch. Cr. Memo Line Ext." extends "Purch. Cr. Memo Line"
{
    fields
    {
        field(71800; "VAT Partial Attribution"; Option)
        {
            OptionMembers = "Full Attribution","Partial Attribution",Blocked;
        }
    }
}