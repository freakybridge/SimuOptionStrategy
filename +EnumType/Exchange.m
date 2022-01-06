classdef Exchange < EnumType.BaseEnum
    enumeration
        CFFEX;
        CZCE;
        DCE;
        INE;
        SSE;
        SZSE;
    end        
        
    methods (Static)
        function ret = ToString(in_)
            ret = upper(in_.string);
        end
        function ret = ToEnum(in_)
            switch upper(in_)
                case {"CFFEX", "CFE"}
                    ret = EnumType.Exchange.CFFEX;
                case {"CZCE", "CZC"}
                    ret = EnumType.Exchange.CZCE;
                case "DCE"
                    ret = EnumType.Exchange.DCE;
                case "INE"
                    ret = EnumType.Exchange.INE;
                case {"SSE", "SH"}
                    ret = EnumType.Exchange.SSE;
                case {"SZSE", "SZ"}
                    ret = EnumType.Exchange.SZSE;
                otherwise
                    error("Unexpected Exchange, Please Check !");
            end
        end
    end
end