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
    end
end