tableextension 71801 "G/L Entry Ext." extends "G/L Entry"
{
    fields
    {
        field(71800; "VAT Partial Attribution"; Option)
        {
            OptionMembers = "Full Attribution","Partial Attribution",Blocked;
        }
        field(71801; "VAT Partial Attr. Prov. Rate"; Decimal)
        {
        }
        field(71802; "VAT Partial Attribution Entry"; Boolean)
        {
        }
    }
}    