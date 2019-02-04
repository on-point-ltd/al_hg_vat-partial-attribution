pageextension 71806 "General Ledger Setup Ext." extends "General Ledger Setup"
{
    layout
    {
        addafter(Reporting)
        {
            group("Infor Setups")
            {
                field("Company Acronym"; "Company Acronym")
                {
                    ApplicationArea = All;
                }
                field("Account Type Acronym"; "Account Type Acronym")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        addafter("VAT Report Setup")
        {
            action(VatPartAttrRates)
            {
                ApplicationArea = All;
                Caption = 'VAT Partial Attr. Rates';
                Image = VATPostingSetup;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                RunObject = page "VAT Partial Attribution Rates";
            }
        }
    }
}