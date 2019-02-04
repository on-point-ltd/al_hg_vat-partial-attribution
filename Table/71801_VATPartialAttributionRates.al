table 71801 "VAT Partial Attribution Rates"
{
    fields
    {
        field(71800; Year; Date)
        {
            TableRelation = "Accounting Period"."Starting Date" where ("New Fiscal Year" = filter(true));         
        }
        field(71801; "Provisional Rate"; Decimal)
        {  
        }
        field(71802; "Actual Rate"; Decimal)
        {  
        }
    }
    
    keys
    {
        key(PK; Year)
        {
            Clustered = true;
        }
    }
}