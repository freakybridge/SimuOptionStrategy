% ETF��Ȩ����
% v1.2.0.20220105.beta
%       �״����
classdef ETF < BaseClass.Asset.Option.Option
    properties (Constant)
        ud_product = EnumType.Product.Etf;
    end    
    properties (Abstract, Constant)
        divlst;
    end
    
    methods
        function obj = ETF(symb, exc, var, sz, inv, snm, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Option.Option(symb, exc, var, sz, inv, snm, cop, k, ldt, edt);
        end
    end    
end