table 71800 "Infor Link"
{    
    fields
    {
        field(71800;"Entry No."; Integer)
        {
            AutoIncrement = true;            
        }
        field(71801; "G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(71802; Brand; Code[20])
        {
            TableRelation = "Dimension Value".Code where ("Dimension Code" = filter('BRAND'));  
        }
        field(71803; Department; Code[20])
        {
            TableRelation = "Dimension Value".Code where ("Dimension Code" = filter('DEPARTMENT'));
        }
        field(71804; "Infor Department"; Integer)
        {
        }
        field(71805; "Infor Nominal"; Integer)
        {
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK; "G/L Account No.",Department,Brand)
        {      
        }
    }
}