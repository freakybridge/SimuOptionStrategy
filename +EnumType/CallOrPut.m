classdef CallOrPut < EnumType.BaseEnum
    enumeration
        Call;
        Put;
        NonOption;
    end        
    
    methods (Static)
        function ret = ToString(in_)
            ret = upper(in_.char);
        end
        function ret = ToEnum(in_)
            switch upper(in_)
                case {'C', 'CALL'}
                    ret = EnumType.CallOrPut.Call;
                case {'P', 'PUT'}
                    ret = EnumType.CallOrPut.Put;
                otherwise
                    ret = EnumType.CallOrPut.NonOption;
            end
        end
    end
end