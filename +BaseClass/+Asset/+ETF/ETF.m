% ETF����
% v1.3.0.20220113.beta
%       �״����
classdef ETF < BaseClass.Asset.Asset
    % ����Asset����
    properties (Constant)
        product EnumType.Product = EnumType.Product.Etf;
    end    
    
    % ��������
    properties (Abstract, Constant)
        divlst cell;
    end
    
    methods
        function obj = ETF(symb, snm, inv, sz)
            % ETF ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
        end
    end
end