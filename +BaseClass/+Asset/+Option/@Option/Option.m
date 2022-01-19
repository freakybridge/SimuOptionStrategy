% Option����
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
%       2.�޸ĳ�Ա�ṹ
% v1.2.0.20220105.beta
%       �״����
classdef Option < BaseClass.Asset.Asset
    % ����Asset����
    properties (Constant)
        product EnumType.Product = EnumType.Product.Option;
    end
    
    % ��������
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
        % ��ʼ��
        function obj = Option(symb, snm, inv, sz, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
            
            obj.call_or_put = EnumType.CallOrPut.ToEnum(cop);
            obj.strike = k;
            obj.listed = datenum(ldt);
            obj.expire = datenum(edt);
            obj.underlying.interval = obj.interval;
        end
        
        % ������
        function ret = get.dlmonth(obj)
            ret = str2double(datestr(obj.expire, 'yymm'));
        end
        
        % ��ȡƷ�����ʱ��
        function ret = GetDateInit(obj)
            ret = datestr(obj.date_ini);
        end
        
        % ��ȡ����ʱ��
        function ret = GetDateListed(obj)
            ret = datestr(obj.listed);
        end
        
        % ��ȡ����ʱ��
        function ret = GetDateExpire(obj)
            ret = datestr(obj.expire);
        end
        
        % ��ȡ�����Ϣ
        function ret = GetUnderSymbol(obj)
            ret = obj.underlying.symbol;
        end
        function ret = GetUnderProduct(obj)
            ret = EnumType.Product.ToString(obj.underlying.product);
        end
        function ret = GetUnderExchange(obj)
            ret = EnumType.Exchange.ToString(obj.underlying.exchange);
        end

        % �޲�����
        function RepairData(obj, tm_ax_std)
            % ����������
            % �������
            [~, loc] = intersect(tm_ax_std(:, 1), obj.md(:, 1));
            md_new = tm_ax_std;
            md_new(loc, 2 : size(obj.md, 2)) = obj.md(:, 2 : end);

            % ����nan
            md_new(isnan(md_new)) = 0;

            % ��λ����
            switch obj.interval
                case {EnumType.Interval.min1, EnumType.Interval.min5}
                    col_close = 7;
                    col_open = 4;
                    col_price = 4 : 7;

                case EnumType.Interval.day
                    col_close = 7;
                    col_open = 4;
                    col_price = 4 : 7;

                otherwise
                    error('Unexpected "interval" for market data repairing, please check.');
            end

            % ��������
            % ����ǰ������
            loc_start = find(md_new(:, col_close) ~= 0, 1, 'first');
            md_new(1 : loc_start, col_close) = md_new(loc_start, col_open);

            % ����������
            loc_end = find(md_new(:, 1) <= obj.expire, 1, 'last');
            for i = loc_start + 1 : loc_end
                if (md_new(i, col_close) == 0)
                    md_new(i, col_price) = md_new(i - 1, col_close);
                end
            end
            obj.md = md_new;
        end
    end
    
    
    methods (Static)
        % ������
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