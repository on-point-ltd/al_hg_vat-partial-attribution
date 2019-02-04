tableextension 71810 "Purchases & Payables Set. Ext." extends "Purchases & Payables Setup"
{
    fields
    {
        field(71800; "VAT Partial Attribution Active"; Boolean)
        {
        }
        field(71801; "VAT Partial Attribution VPPG"; Code[10])
        {
            TableRelation = "VAT Product Posting Group";
        }
        field(71802; "Adj. VAT Partial Attrib. VPPG"; Code[10])
        {
            TableRelation = "VAT Product Posting Group";
        }
        field(71803; "Adj. VAT Blocked VPPG"; Code[10])
        {
            TableRelation = "VAT Product Posting Group";
        }
    }
}