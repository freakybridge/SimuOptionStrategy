% Index基类
% v1.3.0.20220113.beta
%       首次添加
classdef Index < BaseClass.Asset.Asset
    properties (Constant)
        product EnumType.Product = EnumType.Product.Index;
    end
    
    methods
        function obj = Index(symb, snm, inv, sz)
            %INDEX 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
        end
    end
end
