% v1.2.0.20220105.beta
%       Ê×´ÎÌí¼Ó
classdef DataSourceSupported < EnumType.BaseEnum
    enumeration
        iFinD;
        JoinQuant;
        Tushare;
        Wind;
    end        
    
    methods (Static, Hidden)
        function ret = ToString(in_)
            ret = upper(in_.char);
        end
        function ret = ToEnum(in_)
            switch upper(in_)
                case {'IFIND'}
                    ret = EnumType.DataSourceSupported.iFinD;
                case {'JOINQUANT'}
                    ret = EnumType.DataSourceSupported.JoinQuant;
                case {'WIND'}
                    ret = EnumType.DataSourceSupported.Wind;
                case {'TUSHARE'}
                    ret = EnumType.DataSourceSupported.Tushare;
                otherwise
                    error('Unsupported "datasource" please check.');
            end
        end
    end
end