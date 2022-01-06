classdef Product < EnumType.BaseEnum
    enumeration
        Index;
        Etf;
        Future;
        Option;
        Stock;
    end        
    
    methods (Static)
        function ret = ToString(in_)
            ret = upper(in_.string);
        end
        function ret = ToEnum(in_)
            switch upper(in_)
                case {"INDEX"}
                    ret = EnumType.Product.Index;
                case {"ETF"}
                    ret = EnumType.Product.Etf;
                case {"FUTURE"}
                    ret = EnumType.Product.Future;
                case {"OPTION"}
                    ret = EnumType.Product.Option;
                case {"STOCK"}
                    ret = EnumType.Product.Stock;
                otherwise
                    error("Unexpected Option, Please Check !");
            end
        end
    end
end