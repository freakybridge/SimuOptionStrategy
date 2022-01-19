classdef OptionStrikeType < EnumType.BaseEnum
    enumeration
        American;
        Asian;
        European;
    end        
    
    methods (Static)
        function ret = ToString(in_)
            ret = upper(in_.char);
        end
        function ret = ToEnum(in_)
            switch lower(in_)
                case {'amercican'}
                    ret = EnumType.OptionStrikeType.American;
                case {'asian'}
                    ret = EnumType.OptionStrikeType.Asian;
                case {'european'}
                    ret = EnumType.OptionStrikeType.European;
                otherwise
                    error('Unsupported option "StrikeType", please check.');
            end
        end
    end
end