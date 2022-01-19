classdef Exchange < EnumType.BaseEnum
    enumeration
        CFFEX;
        CZCE;
        DCE;
        INE;
        SHFE;
        SSE;
        SZSE;
    end        
        
    methods (Static)
        function ret = ToString(in_)
            ret = upper(in_.char);
        end
        function ret = ToEnum(in_)
            switch upper(in_)
                case {'CFFEX', 'CFE'}
                    ret = EnumType.Exchange.CFFEX;
                case {'CZCE', 'CZC'}
                    ret = EnumType.Exchange.CZCE;
                case 'DCE'
                    ret = EnumType.Exchange.DCE;
                case 'INE'
                    ret = EnumType.Exchange.INE;
                case {'SHF', 'SHFE'}
                    ret = EnumType.Exchange.SHFE;
                case {'SSE', 'SH'}
                    ret = EnumType.Exchange.SSE;
                case {'SZSE', 'SZ'}
                    ret = EnumType.Exchange.SZSE;
                otherwise
                    error('Unexpected "exchange", please check !');
            end
        end
    end
end