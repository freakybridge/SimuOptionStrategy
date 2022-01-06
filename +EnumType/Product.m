classdef Product < EnumType.BaseEnum
    enumeration
        Index;
        Etf;
        Future;
        Option;
        Stock;
    end        
    
    methods (Static)
        function ret = ToString(in_)
            ret = upper(in_.string);
        end
    end
end