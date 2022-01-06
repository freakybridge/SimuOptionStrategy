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
                    ret = "1D";
            end
            ret = upper(ret);
        end
        function ret = ToEnum(in_)
            switch upper(in_)
                case {"1M", "M1", "1MIN", "MIN1", "1-MIN", "MIN-1", "1-M", "M-1"}
                    ret = EnumType.Interval.min1;
                case {"5M", "M5", "5MIN", "MIN5", "5-MIN", "MIN-5", "5-M", "M-5"}
                    ret = EnumType.Interval.min5;
                case {"1D", "D1", "1DAY", "DAY1", "1-DAY", "DAY-1", "1-D", "D-1"}
                    ret = EnumType.Interval.day;
                otherwise
                    error("Unexpected Interval, Please Check !");
            end
        end
    end
end