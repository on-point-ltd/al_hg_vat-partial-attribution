page 71800 "Infor Link"
{
    PageType = List;
    SourceTable = "Infor Link";
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;                  
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = All;              
                }
                field(Brand; Brand)
                {
                    ApplicationArea = All;              
                }
                field(Department; Department)
                {
                    ApplicationArea = All;              
                }
                field("Infor Department"; "Infor Department")
                {
                    ApplicationArea = All;              
                }
                field("Infor Nominal"; "Infor Nominal")
                {
                    ApplicationArea = All;              
                }
            }
        }
    }
}