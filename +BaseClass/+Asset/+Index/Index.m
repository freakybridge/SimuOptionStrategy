% Index����
% v1.3.0.20220113.beta
%       �״����
classdef Index < BaseClass.Asset.Asset
    properties (Constant)
        product EnumType.Product = EnumType.Product.Index;
    end
    
    methods
        function obj = Index(symb, snm, inv, sz)
            %INDEX ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
        end
    end
end
