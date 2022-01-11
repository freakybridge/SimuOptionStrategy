% Option基类
% v1.2.0.20220105.beta
%       首次添加
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
        % 初始化
        function obj = Option(symb, exc, var, sz, inv, snm, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Asset(symb, exc, var, sz, inv, snm);
            
            obj.call_or_put = EnumType.CallOrPut.ToEnum(cop);
            obj.strike = k;
            obj.listed = datenum(ldt);
            obj.expire = datenum(edt);               
        end
        
        % 交割月
        function ret = get.dlmonth(obj)
            ret = str2double(datestr(obj.expire, 'yymm'));
        end
                
%         % 合约全名
%         function ret = GetFullSymbol(obj)
%             cop = EnumType.CallOrPut.ToString(obj.call_or_put);
%             ret = [obj.symbol, '-',  num2str(obj.dlmonth), '-', lower(cop{1}(1)), '-', num2str(obj.strike, '%.03f')];
%         end
                
        % 获取挂牌时点
        function ret = GetDateListed(obj)
            ret = datestr(obj.listed);
        end
        
        % 获取到期时点
        function ret = GetDateExpire(obj)
            ret = datestr(obj.expire);
        end
        
    end
    
end