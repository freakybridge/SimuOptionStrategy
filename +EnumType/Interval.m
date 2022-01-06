classdef Interval < EnumType.BaseEnum
    enumeration
        min1;
        min5;
        day;
    end        
    
    
    methods (Static)
        function ret = ToString(in_)
            switch in_
                case EnumType.Interval.min1
                    ret = "1MIN";
                case EnumType.Interval.min5
                    ret = "5MIN";
                case EnumType.Interval.day
                    ret = "1DAY";
            end
            ret = upper(ret);
        end
    end
end