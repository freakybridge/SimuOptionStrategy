% Option基类
% v1.3.0.20220113.beta
%       1.加入成员类型约束
%       2.修改成员结构
% v1.2.0.20220105.beta
%       首次添加
classdef Option < BaseClass.Asset.Asset
    % 父类Asset属性
    properties (Constant)
        product EnumType.Product = EnumType.Product.Option;
    end
    
    % 新增属性
    properties
        call_or_put EnumType.CallOrPut;
        strike double;
    end
    properties (Hidden)
        expire double;
        listed double;
    end
    properties (Dependent)
        dlmonth double;
    end
    properties (Abstract, Constant)
        strike_type EnumType.OptionStrikeType;
        settle_mode EnumType.OptionSettleMode;
    end
    properties (Abstract)
        underlying;
    end
    
    methods
        % 初始化
        function obj = Option(symb, snm, inv, sz, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
            
            obj.call_or_put = EnumType.CallOrPut.ToEnum(cop);
            obj.strike = k;
            obj.listed = datenum(ldt);
            obj.expire = datenum(edt);
            obj.underlying.interval = obj.interval;
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
        
        % 获取品种起点时点
        function ret = GetDateInit(obj)
            ret = datestr(obj.date_ini);
        end
        
        % 获取挂牌时点
        function ret = GetDateListed(obj)
            ret = datestr(obj.listed);
        end
        
        % 获取到期时点
        function ret = GetDateExpire(obj)
            ret = datestr(obj.expire);
        end
        
        % 获取标的信息
        function ret = GetUnderSymbol(obj)
            ret = obj.underlying.symbol;
        end
        function ret = GetUnderProduct(obj)
            ret = EnumType.Product.ToString(obj.underlying.product);
        end
        function ret = GetUnderExchange(obj)
            ret = EnumType.Exchange.ToString(obj.underlying.exchange);
        end
    end
    
    
    methods (Static)
        % 反射器
        function obj = Selector(symb, exc, var, sz, inv, snm, cop, k, ldt, edt)
            mark = upper(sprintf("%s-%s", var, exc));
            switch mark
                case "159919-SZSE"
                    obj = BaseClass.Asset.Option.Instance.SSE_159919(symb, snm, inv, sz, cop, k, ldt, edt);
                    
                case "510050-SSE"
                    obj = BaseClass.Asset.Option.Instance.SSE_510050(symb, snm, inv, sz, cop, k, ldt, edt);
                    
                case "510300-SSE"
                    obj = BaseClass.Asset.Option.Instance.SSE_510300(symb, snm, inv, sz, cop, k, ldt, edt);
                    
                otherwise
                    error("Unsupported option class, please check.");
            end
        end
    end
    
end