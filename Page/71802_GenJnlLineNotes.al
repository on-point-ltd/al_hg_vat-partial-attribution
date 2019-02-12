page 71802 "Gen. Journal Line Note"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Gen. Jnl. Line Note";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Bal. Account Type"; "Bal. Account Type")
                {
                    ApplicationArea = All;
                }
                field("Bal. Account No."; "Bal. Account No.")
                {
                    ApplicationArea = All;
                }
                field("Blocked VAT";"Blocked VAT")
                {
                    ApplicationArea = All;
                }
                field("Is Error";"Is Error")
                {
                    ApplicationArea = All;
                }
                field("Error Message";"Error Message")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("clearLines")
            {
                ApplicationArea = All;
                Caption = 'Remove Existing';
                
                trigger OnAction()
                begin
                    deleteall();
                end;
            }
            action("setErr")
            {
                ApplicationArea = All;
                Caption = 'Set Lines with Err.';

                trigger OnAction()
                begin
                    if FindSet() then
                        repeat
                            "Is Error" := true;
                            "Error Message" := 'Err Set Manually.';
                            Modify();
                        until Next() = 0;
                end;
            }
        }
    }
}