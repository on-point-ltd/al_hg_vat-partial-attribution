tableextension 71807 "Purch. Inv. Line Ext." extends "Purch. Inv. Line"
{
    fields
    {
        field(71800; "VAT Partial Attribution"; Option)
        {
            OptionMembers = "Full Attribution","Partial Attribution",Blocked;
        }
    }
}