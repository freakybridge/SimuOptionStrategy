% Option����
% v1.2.0.20220105.beta
%       �״�����
classdef Option < BaseClass.Asset.Asset
    properties (Constant)
        product = EnumType.Product.Option;
    end
    
    properties
        call_or_put;
        strike;
    end
    properties (Hidden)
        expire;
        listed;
    end
    properties (Dependent)
        dlmonth;
    end
    
    properties (Abstract, Constant)
        ud_product;
        ud_symbol;
        ud_exchange;
        strike_type;
        settle_mode;
    end    
    
    methods
        % ��ʼ��
        function obj = Option(symb, exc, var, sz, inv, cop, k, edt, ldt)
            obj = obj@BaseClass.Asset.Asset(symb, exc, var, sz, inv);
            
            obj.call_or_put = EnumType.CallOrPut.ToEnum(cop);
            obj.strike = k;
            obj.listed = datenum(ldt);
            obj.expire = datenum(edt);               
        end
        
        % ������
        function ret = get.dlmonth(obj)
            ret = str2double(datestr(obj.expire, 'yymm'));
        end
                
        % ��Լȫ��
        function ret = GetFullSymbol(obj)
            cop = EnumType.CallOrPut.ToString(obj.call_or_put);
            ret = [obj.symbol, '-',  num2str(obj.dlmonth), '-', lower(cop{1}(1)), '-', num2str(obj.strike, '%.03f')];
        end
                
        % ��ȡ����ʱ��
        function ret = GetDateListed(obj)
            ret = datestr(obj.listed);
        end
        
        % ��ȡ����ʱ��
        function ret = GetDateExpire(obj)
            ret = datestr(obj.expire);
        end
        
    end
    
end