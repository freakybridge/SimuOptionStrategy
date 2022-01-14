% ETF基类
% v1.3.0.20220113.beta
%       首次添加
classdef ETF < BaseClass.Asset.Asset
    % 父类Asset属性
    properties (Constant)
        product EnumType.Product = EnumType.Product.Etf;
    end    
    
    % 新增属性
    properties (Abstract, Constant)
        divlst cell;
    end
    
    methods
        function obj = ETF(symb, snm, inv, sz)
            % ETF 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
        end
    end
end