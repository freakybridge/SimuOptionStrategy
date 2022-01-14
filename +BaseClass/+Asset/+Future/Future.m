% Future����
% v1.3.0.20220113.beta
%       �״����
classdef Future < BaseClass.Asset.Asset
    % ����Asset����
    properties (Constant)
        product EnumType.Product = EnumType.Product.Future;
    end    
    
    % ��������
    properties (Hidden)        
        expire double;
    end
    properties
        ratio_margin double;
        fee_ty double;
        fee double;
    end
    properties (Dependent)
        dlmonth double;
    end        
    
    methods
        % ���캯��
        function obj = Future(symb, snm, inv, sz, epdt, mgn, fety, f)
            % Future ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
            obj.expire = epdt;
            obj.ratio_margin = mgn;
            obj.fee_ty = fety;
            obj.fee = f;
        end
        
        % ������
        function ret = get.dlmonth(obj)
            ret = str2double(datestr(obj.expire, 'yymm'));
        end
    end
end