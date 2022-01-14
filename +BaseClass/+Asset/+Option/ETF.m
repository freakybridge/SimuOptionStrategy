% ETF期权基类
% v1.3.0.20220113.beta
%       1.加入成员类型约束
%       2.类成员重构
% v1.2.0.20220105.beta
%       首次添加
classdef ETF < BaseClass.Asset.Option.Option
    methods
        function obj = ETF(symb, snm, inv, sz, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Option.Option(symb, snm, inv, sz, cop, k, ldt, edt);
        end
    end    
end