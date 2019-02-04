tableextension 71802 "Puchase Line Ext." extends "Purchase Line"
{

    fields
    {
        field(71800; "VAT Partial Attribution"; Option)
        {
            OptionMembers = "Full Attribution","Partial Attribution",Blocked;
            trigger OnValidate()
            begin
                if (Type <> Type::"G/L Account") and (Type <> Type::"Fixed Asset") then
                    Error('%1 can only be changed when %2 is set as %3 or %4', FieldCaption("VAT Partial Attribution"),FieldCaption(Type),Type::"Fixed Asset",Type::"G/L Account");
            end;
        }   
        
        modify("No."){
            trigger OnBeforeValidate()
            var 
                GLAcc : Record "G/L Account";
            begin
                "VAT Partial Attribution" := "VAT Partial Attribution"::"Full Attribution";   
                GLAcc.Get("No.");
                case Type of
                    Type::"G/L Account": "VAT Partial Attribution" := GLAcc."VAT Partial Attribution";     
                end;    
            end;
        }
    }            
}