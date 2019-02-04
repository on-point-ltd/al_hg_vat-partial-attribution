page 71801 "VAT Partial Attribution Rates"
{
    PageType = List;
    SourceTable = "VAT Partial Attribution Rates";
    
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Year; Year)
                {
                    ApplicationArea = All;
                }
                field("Provisional Rate"; "Provisional Rate")
                {
                    ApplicationArea = All;
                }
                field("Actual Rate"; "Actual Rate")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}