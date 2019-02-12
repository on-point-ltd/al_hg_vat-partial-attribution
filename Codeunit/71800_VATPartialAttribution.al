codeunit 71800 "VAT Partial Attribution"
{
    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPreparePurchase', '', true, true)]
    procedure ModifyInvPostBufferPreparePurchase(var InvoicePostBuffer: Record "Invoice Post. Buffer"; var PurchaseLine: Record "Purchase Line")
    begin
        with InvoicePostBuffer do begin
            if (Type = Type::"G/L Account") or (Type = Type::"Fixed Asset") then
                "VAT Partial Attribution" := PurchaseLine."VAT Partial Attribution"
            else "VAT Partial Attribution" := "VAT Partial Attribution"::"Full Attribution";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromInvPostBuffer', '', true, true)]
    procedure ModifyCopyGenJnlLineFromInvPostBuffer(InvoicePostBuffer: Record "Invoice Post. Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Partial Attribution" := InvoicePostBuffer."VAT Partial Attribution";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetGLAccount', '', true, true)]
    procedure ModifyAccountNoOnValidateGetGLAccount(var GenJournalLine: Record "Gen. Journal Line"; var GLAccount: Record "G/L Account")
    begin
        GenJournalLine."VAT Partial Attribution" := GLAccount."VAT Partial Attribution";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDocDropShipment', '', true, true)]
    procedure PostVatPartAttrFromPI()
    begin
        // dbgInfo();
        PostVatPartial();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterPostGenJnlLine', '', true, true)]
    procedure PostVatPartAttrFromJnl()
    begin
        // dbgInfo();
        PostVatPartial();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnBeforeThrowError', '', true, true)]
    procedure PostPreviewPartAttr()
    begin
        //dbgInfo();
        PostVatPartial();
    end;

    procedure dbgInfo()
    var
        GenJnlLineNote: Record "Gen. Jnl. Line Note";
        txtBuilder: TextBuilder;
    begin
        txtBuilder.Clear();
        txtBuilder.Append('dbg:\');
        if GenJnlLineNote.FindSet() then
            repeat
                txtBuilder.Append(StrSubstNo('Line No.: %1, ', GenJnlLineNote."Line No."));
                txtBuilder.Append(StrSubstNo('Document Type: %1, ', GenJnlLineNote."Document Type"));
                txtBuilder.Append(StrSubstNo('Document No.: %1, ', GenJnlLineNote."Document No."));
                txtBuilder.Append(StrSubstNo('Amount: %1\', GenJnlLineNote.Amount));
            until GenJnlLineNote.next = 0
        else 
            txtBuilder.Append('no ''Gen. Jnl. Line Note'' found');
        message(txtBuilder.ToText());
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertVATEntry', '', true, true)]
    procedure InsertPartialAttributionVATEntry(GenJnlLine: Record "Gen. Journal Line"; VATEntry: Record "VAT Entry")
    begin
        VATEntry."VAT Partial Attribution Entry" := GenJnlLine."VAT Partial Attribution Entry";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', true, true)]
    procedure InitGlPartialAtributionEntry(GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    begin
        GLEntry."VAT Partial Attribution Entry" := GenJournalLine."VAT Partial Attribution Entry";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGLEntryBuffer', '', true, true)]
    procedure InsertGlPartialAttributionEntryBuffer(var GenJournalLine: Record "Gen. Journal Line"; var TempGLEntryBuf: Record "G/L Entry");
    begin
        if not GenJournalLine."VAT Partial Attribution Entry" then
            HandleVATPartialAttribution(GenJournalLine, TempGLEntryBuf);
    end;

    local procedure HandleVATPartialAttribution(GenJnlLine: Record "Gen. Journal Line"; VAR GLEntry: Record "G/L Entry")
    var
        VATPartialAttrRates: Record "VAT Partial Attribution Rates";
        PurchPaySetup: Record "Purchases & Payables Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        AccPeriod: Record "Accounting Period";
        GenJnlLineNote: Record "Gen. Jnl. Line Note";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        LineNo: Integer;
    begin
        PurchPaySetup.GET;
        if PurchPaySetup."VAT Partial Attribution Active" /*AND NOT VatPartialReady()*/ then begin

            if (GenJnlLine."VAT Partial Attribution" = GenJnlLine."VAT Partial Attribution"::"Partial Attribution") then begin
                if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") OR (GenJnlLine."Account Type" =
                    GenJnlLine."Account Type"::"Fixed Asset") then begin
                    if (GenJnlLine."VAT Calculation Type" = GenJnlLine."VAT Calculation Type"::"Normal VAT")
                        OR (GenJnlLine."VAT Calculation Type" = GenJnlLine."VAT Calculation Type"::"Reverse Charge VAT") then begin
                        if GLEntry."VAT Amount" <> 0 then begin
                            PurchPaySetup.TESTFIELD("VAT Partial Attribution VPPG");
                            CLEAR(AccPeriod);
                            AccPeriod.SETRANGE("New Fiscal Year", TRUE);
                            AccPeriod.SETFILTER("Starting Date", '<=%1', GenJnlLine."Posting Date");
                            if AccPeriod.FINDLAST then begin
                                CLEAR(VATPartialAttrRates);
                                VATPartialAttrRates.SETRANGE(Year, AccPeriod."Starting Date");
                                if VATPartialAttrRates.FINDFIRST then begin
                                    if GenJnlLineNote.FindLast() then
                                        LineNo := GenJnlLineNote."Line No." + 10000
                                    else
                                        LineNo := 10000;
                                    GLEntry."VAT Partial Attribution" := GenJnlLine."VAT Partial Attribution";
                                    GLEntry."VAT Partial Attr. Prov. Rate" := VATPartialAttrRates."Provisional Rate";
                                    GenJnlLineNote.Init();
                                    GenJnlLineNote."Line No." := LineNo;
                                    GenJnlLineNote."Posting Date" := GenJnlLine."Posting Date";
                                    GenJnlLineNote."Document Type" := GenJnlLine."Document Type";
                                    GenJnlLineNote."Document No." := GenJnlLine."Document No.";
                                    Clear(VATPostingSetup);
                                    if NOT VATPostingSetup.GET(GenJnlLine."VAT Bus. Posting Group", PurchPaySetup."VAT Partial Attribution VPPG") then
                                        ERROR(Text002, VATPostingSetup.TABLECAPTION, VATPostingSetup.FIELDCAPTION("VAT Bus. Posting Group"),
                                            GenJnlLine."VAT Bus. Posting Group", VATPostingSetup.FIELDCAPTION("VAT Prod. Posting Group"), PurchPaySetup."VAT Partial Attribution VPPG");
                                    GenJnlLineNote."Account No." := VATPostingSetup."Purchase VAT Account";
                                    GenJnlLineNote.Description := STRSUBSTNO(Text003, VATPartialAttrRates."Provisional Rate");
                                    GenJnlLineNote.Amount := -ROUND((GLEntry."VAT Amount" * ((100 - VATPartialAttrRates."Provisional Rate") / 100)), 0.01);
                                    GenJnlLineNote."Bal. Account Type" := GenJnlLine."Account Type";
                                    GenJnlLineNote."Bal. Account No." := GenJnlLine."Account No.";
                                    GenJnlLineNote."FA Posting Type" := GenJnlLine."FA Posting Type";
                                    GenJnlLineNote."Depreciation Book Code" := GenJnlLine."Depreciation Book Code";
                                    GenJnlLineNote."Gen. Posting Type" := GenJnlLine."Gen. Posting Type";
                                    GenJnlLineNote."Gen. Bus. Posting Group" := GenJnlLine."Gen. Bus. Posting Group";
                                    GenJnlLineNote."Gen. Prod. Posting Group" := GenJnlLine."Gen. Prod. Posting Group";
                                    GenJnlLineNote."VAT Bus. Posting Group" := GenJnlLine."VAT Bus. Posting Group";
                                    GenJnlLineNote."VAT Prod. Posting Group" := PurchPaySetup."VAT Partial Attribution VPPG";
                                    GenJnlLineNote."Shortcut Dimension 1 Code" := GenJnlLine."Shortcut Dimension 1 Code";
                                    GenJnlLineNote."Shortcut Dimension 2 Code" := GenJnlLine."Shortcut Dimension 2 Code";
                                    GenJnlLineNote.Insert();
                                end else
                                    ERROR(Text001, VATPartialAttrRates.TABLECAPTION, GenJnlLine.FIELDCAPTION("Posting Date"), GenJnlLine."Posting Date");
                            end else
                                ERROR(Text004, GenJnlLine.FIELDCAPTION("Posting Date"), GenJnlLine."Posting Date");
                        end;
                    end;
                end;
            end;
            if GenJnlLine."VAT Partial Attribution" = GenJnlLine."VAT Partial Attribution"::Blocked then begin
                if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") OR (GenJnlLine."Account Type" =
                    GenJnlLine."Account Type"::"Fixed Asset") then begin
                    if (GenJnlLine."VAT Calculation Type" = GenJnlLine."VAT Calculation Type"::"Normal VAT")
                        OR (GenJnlLine."VAT Calculation Type" = GenJnlLine."VAT Calculation Type"::"Reverse Charge VAT") then begin
                        if GLEntry."VAT Amount" <> 0 then begin

                            // PostBlockedVAT := FALSE;
                            GLEntry."VAT Partial Attribution" := GenJnlLine."VAT Partial Attribution";
                            // CLEAR(Blocked1GenJnlLine);
                            GenJnlLineNote.Init();
                            GenJnlLineNote.Validate("Posting Date", GenJnlLine."Posting Date");
                            GenJnlLineNote.VALIDATE("Document Type", GenJnlLine."Document Type");
                            GenJnlLineNote.VALIDATE("Document No.", GenJnlLine."Document No.");
                            //Blocked1GenJnlLine."VAT Calculation Type" := Blocked1GenJnlLine."VAT Calculation Type"::

                            CLEAR(VATPostingSetup);
                            IF NOT VATPostingSetup.GET(GenJnlLine."VAT Bus. Posting Group", PurchPaySetup."Adj. VAT Blocked VPPG") THEN  //GenJnlLine."VAT Prod. Posting Group"
                                ERROR(Text50001, VATPostingSetup.TABLECAPTION, VATPostingSetup.FIELDCAPTION("VAT Bus. Posting Group"), 
                                GenJnlLine."VAT Bus. Posting Group", VATPostingSetup.FIELDCAPTION("VAT Prod. Posting Group"), PurchPaySetup."VAT Partial Attribution VPPG");

                            GenJnlLineNote.VALIDATE("Account No.", GetBalAccNo(GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group", VATPostingSetup."Purchase VAT Account")); //VATPostingSetup."Purchase VAT Account"

                            GenJnlLineNote.VALIDATE(Description, Text50004);
                            GenJnlLineNote.VALIDATE(Amount, -GLEntry."VAT Amount");
                            //Blocked1GenJnlLine.VALIDATE("VAT Amount", GLEntry."VAT Amount");

                            GenJnlLineNote.VALIDATE("Gen. Posting Type", GenJnlLine."Gen. Posting Type");
                            //Blocked1GenJnlLine.VALIDATE("Bal. Gen. Posting Type", GenJnlLine."Bal. Gen. Posting Type");
                            GenJnlLineNote.VALIDATE("Gen. Bus. Posting Group", GenJnlLine."Gen. Bus. Posting Group");
                            GenJnlLineNote.VALIDATE("Gen. Prod. Posting Group", GenJnlLine."Gen. Prod. Posting Group");

                            GenJnlLineNote.VALIDATE("Bal. Account Type", GenJnlLine."Account Type");
                            GenJnlLineNote."Bal. Account No." := GenJnlLine."Account No.";
                            //Blocked1GenJnlLine.VALIDATE("VAT Calculation Type", Blocked1GenJnlLine."VAT Calculation Type"::"Full VAT");
                            //Blocked1GenJnlLine.VALIDATE("Bal. VAT Calculation Type", Blocked1GenJnlLine."Bal. VAT Calculation Type"::"Normal VAT");

                            GenJnlLineNote.VALIDATE("FA Posting Type", GenJnlLine."FA Posting Type");
                            GenJnlLineNote.VALIDATE("Depreciation Book Code", GenJnlLine."Depreciation Book Code");
                            GenJnlLineNote.VALIDATE("VAT Bus. Posting Group", GenJnlLine."VAT Bus. Posting Group");
                            GenJnlLineNote.VALIDATE("VAT Prod. Posting Group", PurchPaySetup."Adj. VAT Blocked VPPG"); //GenJnlLine."VAT Prod. Posting Group"

                            GenJnlLineNote.VALIDATE("Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 1 Code");
                            GenJnlLineNote.VALIDATE("Shortcut Dimension 2 Code", GenJnlLine."Shortcut Dimension 2 Code");

                            GenJnlLineNote."Blocked VAT" := true;

                            GenJnlLineNote.Insert();

                        end;
                    end;
                end;
            end;
        end;
    end;

    local procedure GetBalAccNo(VatBus: Code[20]; VatProd: Code[20]; VatAccNo: Code[20]) BalAccNo: Code[20]
    var
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        if VatPostingSetup.get(VatBus,VatProd) then
            // exit(VatPostingSetup."Purchase VAT Account")
            exit(VatAccNo)
        else
            exit(VatAccNo);
    end;

    local procedure CheckGLAccDimError(GenJnlLine: Record "Gen. Journal Line"; GLAccNo: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
        TableID: array [10] of integer;
        AccNo: array [10] of Code[20];
    begin

        IF (GenJnlLine.Amount = 0) AND (GenJnlLine."Amount (LCY)" = 0) THEN
            EXIT;

        TableID[1] := DATABASE::"G/L Account";
        AccNo[1] := GLAccNo;
        IF DimMgt.CheckDimValuePosting(TableID,AccNo,GenJnlLine."Dimension Set ID") THEN
            EXIT;

        IF GenJnlLine."Line No." <> 0 THEN
            ERROR(
                DimensionUsedErr,
                GenJnlLine.TABLECAPTION,GenJnlLine."Journal Template Name",
                GenJnlLine."Journal Batch Name",GenJnlLine."Line No.",
                DimMgt.GetDimValuePostingErr);

        ERROR(DimMgt.GetDimValuePostingErr);        
    end;

    local procedure PostVatPartial()
    var
        GenJnlLineNote: Record "Gen. Jnl. Line Note";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        GenJnlLineNote.SetRange("Is Error", false);
        if GenJnlLineNote.FindSet() then begin
            repeat
                GenJnlLine.init;
                GenJnlLine.Validate("Posting Date", GenJnlLineNote."Posting Date");
                GenJnlLine.Validate("Document Type", GenJnlLineNote."Document Type");
                GenJnlLine.Validate("Document No.", GenJnlLineNote."Document No.");
                GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Account No.", GenJnlLineNote."Account No.");
                GenJnlLine.validate(Description, GenJnlLineNote.Description);
                GenJnlLine.Validate(Amount, GenJnlLineNote.Amount);
                GenJnlLine."VAT Partial Attribution" := GenJnlLine."VAT Partial Attribution"::"Full Attribution";
                GenJnlLine."VAT Partial Attribution Entry" := true;
                GenJnlLine.Validate("Bal. Account Type", GenJnlLineNote."Bal. Account Type");
                GenJnlLine."Bal. Account No." := GenJnlLineNote."Bal. Account No.";
                GenJnlLine.Validate("FA Posting Type", GenJnlLineNote."FA Posting Type");
                GenJnlLine.Validate("Depreciation Book Code", GenJnlLineNote."Depreciation Book Code");
                GenJnlLine.Validate("Gen. Posting Type", GenJnlLineNote."Gen. Posting Type");
                GenJnlLine.Validate("Gen. Bus. Posting Group", GenJnlLineNote."Gen. Bus. Posting Group");
                GenJnlLine.Validate("Gen. Prod. Posting Group", GenJnlLineNote."Gen. Prod. Posting Group");
                GenJnlLine.Validate("VAT Bus. Posting Group", GenJnlLineNote."VAT Bus. Posting Group");
                GenJnlLine.Validate("VAT Prod. Posting Group", GenJnlLineNote."VAT Prod. Posting Group");
                GenJnlLine.Validate("Shortcut Dimension 1 Code", GenJnlLineNote."Shortcut Dimension 1 Code");
                GenJnlLine.Validate("Shortcut Dimension 2 Code", GenJnlLineNote."Shortcut Dimension 2 Code");
                GenJnlLine."System-Created Entry" := true;

                if GenJnlPostLine.RunWithCheck(GenJnlLine) > 0 then
                    GenJnlLineNote.Delete()
                else begin
                    GenJnlLineNote."Is Error" := true;
                    GenJnlLineNote."Error Message" := 'Error On Posting VAT Partial.';
                    GenJnlLineNote.Modify();
                end;
            until GenJnlLineNote.next = 0;
        end;
    end;

    local procedure VatPartialReady() VatPartialIsReady: boolean
    var
        GenJnlLineNote: Record "Gen. Jnl. Line Note";
    begin
        exit(not GenJnlLineNote.IsEmpty());
    end;

    var
        Text001: Label 'The %1 with %2 %3 was not found.';
        Text002: Label 'Error: %1 with %2 %3 and %4 %5 does not exist';
        Text003: Label 'VAT Partial Attribution - %1%';
        Text004: Label 'Error: %1 %2 is not within one of the available Accounting Periods';
        Text50001: Label 'Error: %1 with %2 %3 and %4 %5 does not exist';       
        Text50004: Label 'Extra Blocked VAT Entry';
        DimensionUsedErr: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5.';


//-------------------------------------------------------------------------------------------------
//---> DEBUG Tools
//-------------------------------------------------------------------------------------------------
    local procedure dbg_GJL(GJL: Record "Gen. Journal Line"; OrdNo: Integer)
    var
        tb: TextBuilder;
    begin
        tb.Clear();
        tb.Append(StrSubstNo('dbg_GJL (%1):\', OrdNo));
        tb.Append(StrSubstNo('Document: [%1] [%2]\', GJL."Document Type", GJL."Document No."));
        tb.Append(StrSubstNo('VAT Partial Attr: [%1]\', GJL."VAT Partial Attribution"));
        tb.Append((StrSubstNo('Amount: [%1]\', GJL.Amount)));
        tb.Append(StrSubstNo('Description: [%1]\', GJL.Description));
        Message(tb.ToText());
    end;

    local procedure dbg_GLE(GLE: Record "G/L Entry"; OrdNo: Integer)
    var
        tb: TextBuilder;
    begin
        tb.Clear();
        tb.Append(StrSubstNo('dbg_GLE (%1):\', OrdNo));
        tb.Append(StrSubstNo('Entry No.: [%1]\', GLE."Entry No."));
        tb.Append(StrSubstNo('Amount / VAT Amount: [%1] / [%2]\', GLE.Amount, GLE."VAT Amount"));
        tb.Append(StrSubstNo('VAT Partial Attribution: [%1]\', GLE."VAT Partial Attribution"));
        tb.Append(StrSubstNo('Description : [%1]\', GLE.Description));
        Message(tb.ToText());
    end;
    
}