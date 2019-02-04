pageextension 71811 "Purchases & Payables Setup Ext" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Allow Document Deletion Before")
        {
            field("VAT Partial Attribution Active"; "VAT Partial Attribution Active")
            {
                ApplicationArea = All;
            }
            field("VAT Partial Attribution VPPG"; "VAT Partial Attribution VPPG")
            {
                ApplicationArea = All;
            }
            field("Adj. VAT Partial Attrib. VPPG"; "Adj. VAT Partial Attrib. VPPG")
            {
                ApplicationArea = All;
            }
            field("Adj. VAT Blocked VPPG"; "Adj. VAT Blocked VPPG")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addafter("Incoming Documents Setup")
        {
            action("VAT Partial Attribution Rates")
            {
                ApplicationArea = All;
                Image = VATPostingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "VAT Partial Attribution Rates";
            }
            // **** for testing only **** //
            // action("Set VAT Partial")
            // {
            //     ApplicationArea = All;
            //     Image = Setup;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     trigger OnAction()
            //     var
            //         PurchSetup: Record "Purchases & Payables Setup";
            //         VatPartRates: Record "VAT Partial Attribution Rates";
            //     begin
            //         PurchSetup.Get();
            //         PurchSetup."VAT Partial Attribution Active" := true;
            //         PurchSetup."VAT Partial Attribution VPPG" := 'PARTIALPRO';
            //         PurchSetup."Adj. VAT Partial Attrib. VPPG" := 'PARTIALACT';
            //         PurchSetup.Modify();

            //         VatPartRates.Init();
            //         VatPartRates.Year := 20180101D;
            //         VatPartRates."Actual Rate" := 50;
            //         VatPartRates."Provisional Rate" := 30;
            //         if VatPartRates.Insert() then;
            //         VatPartRates.Init();
            //         VatPartRates.Year := 20190101D;
            //         VatPartRates."Actual Rate" := 50;
            //         VatPartRates."Provisional Rate" := 30;
            //         if VatPartRates.Insert() then;

            //     end;
            // }
            // action("Show Gen. Jnl Line Notes")
            // {
            //     ApplicationArea = All;
            //     Image = Action;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     trigger OnAction()
            //     begin
            //         page.run(page::"Gen. Journal Line Note");
            //     end;
            // }
        }
    }
}
