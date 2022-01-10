classdef OptionStrikeType < EnumType.BaseEnum
    enumeration
        American;
        Asian;
        European;
    end        
    
    methods (Static)
        function ret = ToString(in_)
            ret = upper(in_.string);
        end
        function ret = ToEnum(in_)
            switch lower(in_)
                case {"amercican"}
                    ret = EnumType.StrikeType.American;
                case {"asian"}
                    ret = EnumType.StrikeType.Asian;
                case {"european"}
                    ret = EnumType.StrikeType.European;
                otherwise
                    error("Unsupported option ""StrikeType"", please check.");
            end
        end
    end
end