tableextension 71800 "G/L Account Ext." extends "G/L Account"
{
    fields
    {
        field(71800; "VAT Partial Attribution"; Option)
        {
            OptionMembers = "Full Attribution","Partial Attribution",Blocked;
        }
    }
}