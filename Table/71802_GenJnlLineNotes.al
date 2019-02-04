table 71802 "Gen. Jnl. Line Note"
{
    fields
    {
        field(5; "Line No."; Integer) { }
        field(10; "Posting Date"; Date) { }
        field(15; "Document Type"; Option)
        {
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(20; "Document No."; code[20]) { }
        field(25; "Account No."; Code[20]) { }
        field(30; "Description"; text[50]) { }
        field(35; Amount; Decimal) { }
        field(40; "Bal. Account Type"; Option)
        {
            OptionMembers = "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner",Employee;
        }
        field(45; "Bal. Account No."; code[20]) { }
        field(50; "FA Posting Type"; Option)
        {
            OptionMembers = " ","Acquisition Cost",Depreciation,"Write-Down",Appreciation,"Custom 1","Custom 2",Disposal,Maintenance;
        }
        field(55; "Depreciation Book Code"; Code[20]) { }
        field(60; "Gen. Posting Type"; Option)
        {
            OptionMembers = " ",Purchase,Sale,Settlement;
        }
        field(65; "Gen. Bus. Posting Group"; Code[20]) { }
        field(70; "Gen. Prod. Posting Group"; Code[20]) { }
        field(75; "VAT Bus. Posting Group"; Code[20]) { }
        field(80; "VAT Prod. Posting Group"; Code[20]) { }
        field(85; "Shortcut Dimension 1 Code"; Code[20]) { }
        field(90; "Shortcut Dimension 2 Code"; Code[20]) { }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }
}