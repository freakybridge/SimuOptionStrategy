% ETF��Ȩ����
% v1.3.0.20220113.beta
%       �����Ա����Լ��
% v1.2.0.20220105.beta
%       �״����
classdef ETF < BaseClass.Asset.Option.Option
    properties (Constant)
        ud_product EnumType.Product = EnumType.Product.Etf;
    end    
    properties (Abstract, Constant)
        divlst cell;
    end
    
    methods
        function obj = ETF(symb, exc, var, sz, inv, snm, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Option.Option(symb, exc, var, sz, inv, snm, cop, k, ldt, edt);
        end
    end    
end