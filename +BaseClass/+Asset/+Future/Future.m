% Future基类
% v1.3.0.20220113.beta
%       首次添加
classdef Future < BaseClass.Asset.Asset
    % 父类Asset属性
    properties (Constant)
        product EnumType.Product = EnumType.Product.Future;
    end    
    
    % 新增属性
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
        % 构造函数
        function obj = Future(symb, snm, inv, sz, epdt, mgn, fety, f)
            % Future 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
            obj.expire = epdt;
            obj.ratio_margin = mgn;
            obj.fee_ty = fety;
            obj.fee = f;
        end
        
        % 交割月
        function ret = get.dlmonth(obj)
            ret = str2double(datestr(obj.expire, 'yymm'));
        end
    end
end