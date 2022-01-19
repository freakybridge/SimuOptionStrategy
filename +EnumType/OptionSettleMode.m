classdef OptionSettleMode < EnumType.BaseEnum
    enumeration
        Cash;
        Physical;
    end        
    
    methods (Static, Hidden)
        function ret = ToString(in_)
            ret = upper(in_.char);
        end
        function ret = ToEnum(in_)
            switch lower(in_)
                case {'cash'}
                    ret = EnumType.OptionSettleMode.Cash;
                case {'physical'}
                    ret = EnumType.OptionSettleMode.Physical;
                otherwise
                    error('Unsupported option "SettleMode", please check.');
            end
        end
    end
end