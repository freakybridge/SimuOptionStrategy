% ETF期权基类
% v1.2.0.20220105.beta
%       首次添加
classdef ETF < BaseClass.Asset.Option.Option
    properties (Constant)
        ud_product = EnumType.Product.Etf;
    end    
    properties (Abstract, Constant)
        divlst;
    end
    
    methods
        function obj = ETF(symb, exc, var, sz, inv, snm, cop, k, edt, ldt)
            obj = obj@BaseClass.Asset.Option.Option(symb, exc, var, sz, inv, snm, cop, k, edt, ldt);
        end
    end    
end