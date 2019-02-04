tableextension 71804 "Gen. Journal Line Ext." extends "Gen. Journal Line"
{
    fields
    {
        field(71800; "VAT Partial Attribution"; Option)
        {
            OptionMembers = "Full Attribution","Partial Attribution",Blocked;
            trigger OnValidate()
            begin
                if "VAT Partial Attribution" = "VAT Partial Attribution"::"Partial Attribution" then begin
                    if ("Account Type" <> "Account Type"::"G/L Account") and ("Account Type" <> "Account Type"::"Fixed Asset") then
                        Error('The %1 field can only be %2 when %3 is set as %4 or %5',FieldCaption("VAT Partial Attribution"),"VAT Partial Attribution"::"Partial Attribution",
                            FieldCaption("Account Type"),"Account Type"::"G/L Account", "Account Type"::"Fixed Asset");   
                end;
            end;
        }
        field(71801; "VAT Partial Attribution Entry"; Boolean)
        {            
        }
        modify("Account No."){
            trigger OnBeforeValidate()
            begin
                "VAT Partial Attribution" := "VAT Partial Attribution"::"Full Attribution";    
            end;
        }
    } 
}