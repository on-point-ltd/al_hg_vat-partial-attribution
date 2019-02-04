report 71800 "Adjust VAT Partial Attribution"
{
    ProcessingOnly = true;
    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.") order(ascending) where("Direct Posting" = filter(true));
            RequestFilterFields = "No.";
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemTableView = sorting("G/L Account No.","Posting Date") order(ascending) where("VAT Partial Attribution" = filter("Partial Attribution"));
                DataItemLink = "G/L Account No." = field("No.");
                RequestFilterFields = "Posting Date";
                trigger OnAfterGetRecord()
                begin
                    if VATBusPostingGrp <> "G/L Entry"."VAT Bus. Posting Group" then begin
                        Clear(VATPostingSetup);
                        if not VATPostingSetup.Get("G/L Entry"."VAT Bus. Posting Group", PurchPaySetup."VAT Partial Attribution VPPG") then
                            Error(Text007, VATPostingSetup.TableCaption, VATPostingSetup.FieldCaption("VAT Bus. Posting Group"), "G/L Entry"."VAT Bus. Posting Group", 
                            VATPostingSetup.FieldCaption("VAT Prod. Posting Group"), PurchPaySetup."VAT Partial Attribution VPPG");
                        VATBusPostingGrp := "G/L Entry"."VAT Bus. Posting Group";
                    end;  

                    Clear(AccPeriod);
                    AccPeriod.SetRange("New Fiscal Year", true);
                    AccPeriod.SETFILTER("Starting Date", '<=%1', "Posting Date");
                    if AccPeriod.FindLast then begin
                        Clear(VATPartialAttrRates);
                        VATPartialAttrRates.SetRange(Year, AccPeriod."Starting Date");
                        if VATPartialAttrRates.FindFirst then begin
                            if "VAT Partial Attr. Prov. Rate" <> VATPartialAttrRates."Actual Rate" then begin
                                Clear(GenJnlLine2);
                                GenJnlLine2.Init;
                                GenJnlLine2.Validate("Journal Template Name", GenJnlLine."Journal Template Name");
                                GenJnlLine2.Validate("Journal Batch Name", GenJnlLine."Journal Batch Name");
                                GenJnlLine2.Validate("Line No.", LineNo);
                                GenJnlLine2.Validate("Posting Date", PostingDate);
                                GenJnlLine2.Validate("Account Type", GenJnlLine2."Account Type"::"G/L Account");
                                GenJnlLine2.Validate("Account No.", VATPostingSetup."Purchase VAT Account");
                                GenJnlLine2.Validate("Document No.", "Document No.");
                                GenJnlLine2.Validate(Description, Text005);
                                PercDiff := Abs(VATPartialAttrRates."Actual Rate" - "VAT Partial Attr. Prov. Rate");
                                if VATPartialAttrRates."Actual Rate" > "VAT Partial Attr. Prov. Rate" then
                                    GenJnlLine2.Validate(Amount, Round((PercDiff/100) * "VAT Amount", 0.01))
                                else
                                    GenJnlLine2.Validate(Amount, -(Round((PercDiff/100) * "VAT Amount", 0.01)));
                                GenJnlLine2.Validate("Bal. Account Type", GenJnlLine2."Bal. Account Type"::"G/L Account");
                                if "Source Type" = "Source Type"::"Fixed Asset" then
                                    GenJnlLine2.Validate("Bal. Account No.", FAGLExpenseAcc)
                                else
                                    GenJnlLine2.Validate("Bal. Account No.", "G/L Account No.");
                                GenJnlLine2."VAT Partial Attribution" := GenJnlLine2."VAT Partial Attribution"::"Full Attribution";
                                GenJnlLine2."VAT Partial Attribution Entry" := true;
                                GenJnlLine2.Validate("Gen. Posting Type", "Gen. Posting Type");
                                GenJnlLine2.Validate("Gen. Bus. Posting Group", "Gen. Bus. Posting Group");
                                GenJnlLine2.Validate("Gen. Prod. Posting Group", "Gen. Prod. Posting Group");
                                GenJnlLine2.Validate("VAT Bus. Posting Group", "VAT Bus. Posting Group");
                                GenJnlLine2.Validate("VAT Prod. Posting Group", PurchPaySetup."Adj. VAT Partial Attrib. VPPG");
                                GenJnlLine2.Validate("Shortcut Dimension 1 Code", DimValCode1);
                                GenJnlLine2.Validate("Shortcut Dimension 2 Code", DimValCode2);
                                GenJnlLine2.Insert;
                                LineNo += 10000;
                            end else
                                CurrReport.Skip;
                        end else
                            Error(Text008, VATPartialAttrRates.TableCaption, FieldCaption("Posting Date"), "Posting Date");
                    end else
                        Error(Text009, FieldCaption("Posting Date"), "Posting Date");
                end;
            }
        }
    }
    
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Control)
                {
                    field("Gen. Journal Template"; GenJnlLine."Journal Template Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the general journal template that is used by the bach name';
                        ShowMandatory = true;
                        TableRelation = "Gen. Journal Template";
                        trigger OnValidate()
                        begin
                            GenJnlLine."Journal Batch Name" := '';
                        end;
                    }
                    field("Gen. Journal Batch"; GenJnlLine."Journal Batch Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the general journal template that is used by the batch job.';
                        ShowMandatory = true;
                        TableRelation = "Gen. Journal Template";
                        Lookup = true;
                        trigger OnValidate()
                        begin
                            if GenJnlLine."Journal Batch Name" <> '' then begin
                                GenJnlLine.TestField("Journal Template Name");
                                GenJnlBatch.Get(GenJnlLine."Journal Template Name",GenJnlLine."Journal Batch Name");
                            end;
                        end;
                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            GenJnlLine.TestField("Journal Template Name");
                            GenJnlTemplate.Get(GenJnlLine."Journal Template Name");
                            GenJnlBatch.FilterGroup(2);
                            GenJnlBatch.SetRange("Journal Template Name",GenJnlLine."Journal Template Name");
                            GenJnlBatch.FilterGroup(0);
                            GenJnlBatch."Journal Template Name" := GenJnlLine."Journal Template Name";
                            GenJnlBatch.Name := GenJnlLine."Journal Batch Name";
                            IF Page.RunModal(0,GenJnlBatch) = Action::LookupOK then begin
                                Text := GenJnlBatch.Name;
                                Exit(true);
                            end;    
                        end;
                    }
                    field("Posting Date"; PostingDate)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("FA G/L Expense Account"; FAGLExpenseAcc)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        TableRelation = "G/L Account";
                    }
                    field(Department; DimValCode1)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        TableRelation = "Dimension Value".Code where ("Dimension Code" = filter('DEPARTMENT'));
                    }
                    field(Brand; DimValCode2)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        TableRelation = "Dimension Value".Code where ("Dimension Code" = filter('BRAND'));
                    }
                }
            }
        }
    }
    
    trigger OnPreReport()
    begin
        if PostingDate = 0D then
            Error(Text001);
        
        if FAGLExpenseAcc = '' then
            Error(Text002);

        if GenJnlLine."Journal Template Name" = '' then
            Error(Text003);

        if GenJnlLine."Journal Batch Name" = '' then
            Error(Text004);   

        Clear(GenJnlLine2);
        GenJnlLine2.SetRange("Journal Template Name",GenJnlLine."Journal Template Name");
        GenJnlLine2.SetRange("Journal Batch Name",GenJnlLine."Journal Batch Name");
        if GenJnlLine2.FindLast then
            LineNo += 10000
        else
            LineNo := 0;   

        PurchPaySetup.Get;
        PurchPaySetup.TestField("Adj. VAT Partial Attrib. VPPG");
    end;

    trigger OnPostReport()
    begin
        Message(Text006);
    end;

    var
    GenJnlLine: Record "Gen. Journal Line";
    GenJnlLine2: Record "Gen. Journal Line";
    GenJnlBatch: Record "Gen. Journal Batch";
    GenJnlTemplate: Record "Gen. Journal Template";
    PurchPaySetup: Record "Purchases & Payables Setup";
    AccPeriod: Record "Accounting Period";
    VATPostingSetup: Record "VAT Posting Setup";
    VATPartialAttrRates: Record "VAT Partial Attribution Rates";
    FAGLExpenseAcc: Code[20];
    PostingDate: Date;
    DimValCode1: Code[20];
    DimValCode2:Code[20];
    LineNo: Integer;
    PercDiff: Decimal;
    VATBusPostingGrp: Code[10];
    Text001: Label 'Posting Date cannot be null';
    Text002: Label 'FA G/L Expense Account cannot be null';
    Text003: Label 'Journal Template Name cannot be null';
    Text004: Label 'Journal Batch Name cannot be null';
    Text005: Label 'VAT Partial Attribution Adjustment';
    Text006: Label 'Process executed successfully';
    Text007: Label 'Error: %1 with %2 %3 and %4 %5 does not exist';
    Text008: Label 'The %1 with %2 %3 was not found.';
    Text009: Label 'Error: %1 %2 is not within one of the available Accounting Periods';
}