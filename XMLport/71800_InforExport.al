xmlport 71800 "Infor Export"
{
    Direction = Export;
    Format = VariableText;
    TableSeparator = '<NewLine>';
    schema
    {
        textelement(Root)
        {
            tableelement(GLEntry; "G/L Entry")
            {
                textattribute(CompName)
                {  
                }
                textattribute(AccountType)
                {  
                }
                textattribute(DateMonth)
                {  
                }
                textattribute(Department)
                {  
                }
                textattribute(Constant)
                {  
                }
                textattribute(Nominal)
                {  
                }
                textattribute(Description)
                {  
                }
                textattribute(MonthlyMovement)
                {  
                }
                trigger OnPreXmlItem()
                begin
                    GLSetup.Get;
                    GLEntry.SetRange("Posting Date", StartDate, EndDate);        
                end; 
                trigger OnAfterGetRecord()
                begin
                    NetChange := 0;
                    if (GLAcc <> GLEntry."G/L Account No.") or (DeptDim <> GLEntry."Global Dimension 1 Code") then begin
                        Clear(GLEntry2);
                        GLEntry2.SetCurrentKey("G/L Account No.", "Global Dimension 1 Code", "Global Dimension 2 Code");
                        GLEntry2.CopyFilters(GLEntry);    
                        GLEntry2.SETRANGE("G/L Account No.", GLEntry."G/L Account No.");
                        GLEntry2.SETRANGE("Global Dimension 1 Code", GLEntry."Global Dimension 1 Code");
                        IF GLEntry2.FINDSET THEN
                            REPEAT
                            NetChange += GLEntry2.Amount;
                            UNTIL GLEntry2.NEXT = 0;

                        CLEAR(InforLink);
                        InforLink.SETRANGE("G/L Account No.", GLEntry."G/L Account No.");
                        InforLink.SETRANGE(Department, GLEntry."Global Dimension 1 Code");
                        IF NOT InforLink.FINDFIRST THEN
                            ERROR(Text001, InforLink.TABLECAPTION, InforLink.FIELDCAPTION("G/L Account No."), GLEntry."G/L Account No.", 
                            InforLink.FIELDCAPTION(Department), GLEntry."Global Dimension 1 Code");

                        CompName := GLSetup."Company Acronym";
                        AccountType := GLSetup."Account Type Acronym";
                        DateMonth := FORMAT(GLEntry."Posting Date", 0, 6);
                        DateMonth := COPYSTR(DateMonth, 3, 2) + '_' + COPYSTR(DateMonth, 1, 2);
                        Department := FORMAT(InforLink."Infor Department");
                        Constant := FORMAT(0);
                        Nominal := FORMAT(InforLink."Infor Nominal");
                        Description := GLSetup."Default Description";
                        MonthlyMovement := FORMAT(NetChange);
                        END ELSE
                        currXMLport.SKIP; 

                        GLAcc := GLEntry."G/L Account No.";
                        DeptDim := GLEntry."Global Dimension 1 Code";
                end;   
            }
        }
    }
    
    requestpage
    {
        layout
        {
            area(content)
            {
                group("Filter by Month")
                {
                    field("Starting Date";StartDate)
                    {    
                        trigger OnValidate()
                        begin
                            StartDate := CalcDate('<-CM>',StartDate);
                            EndDate := CalcDate('<CM>',StartDate);
                        end;                   
                    }
                    field("Ending Date";EndDate)
                    {        
                        trigger OnValidate()
                        begin
                            EndDate := CalcDate('<CM>',EndDate);
                            StartDate := CalcDate('<-CM>',EndDate);
                        end;          
                    }
                }
            }
        }
    }
    
    var
        GLEntry2: Record "G/L Entry";
        GLSetup: Record "General Ledger Setup";
        InforLink: Record "Infor Link";
        NetChange: Decimal;
        GLAcc: Code[20];
        DeptDim: Code[20];
        StartDate: Date;
        EndDate: Date;
        Text001: Label '%1 record with %2 %3 and %4 %5 does not exist'; 
}