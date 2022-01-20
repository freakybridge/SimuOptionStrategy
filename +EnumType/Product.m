classdef Product < EnumType.BaseEnum
    enumeration
        ETF;
        Future;
        Index;
        Option;
        Stock;
    end        
    
    methods (Static, Hidden)
        function ret = ToString(in_)
            ret = in_.char;
        end
        function ret = ToEnum(in_)
            switch upper(in_)
                case {'ETF'}
                    ret = EnumType.Product.ETF;
                case {'FUTURE'}
                    ret = EnumType.Product.Future;
                case {'INDEX'}
                    ret = EnumType.Product.Index;
                case {'OPTION'}
                    ret = EnumType.Product.Option;
                case {'STOCK'}
                    ret = EnumType.Product.Stock;
                otherwise
                    error('Unexpected "product", please check !');
            end
        end
    end
end