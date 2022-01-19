% v1.2.0.20220105.beta
%       Ê×´ÎÌí¼Ó
classdef DatabaseSupported < EnumType.BaseEnum
    enumeration
        Mss;
        Postgres;
    end        
    
    methods (Static, Hidden)
        function ret = ToString(in_)
            ret = upper(in_.char);
        end
        function ret = ToEnum(in_)
            switch upper(in_)
                case {'MSS'}
                    ret = EnumType.DatabaseSupported.Mss;
                case {'POSTGRES'}
                    ret = EnumType.DatabaseSupported.Postgres;
                otherwise
                    error('Unsupported "database", please check.');
            end
        end
    end
end