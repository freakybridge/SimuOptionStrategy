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
        function obj = Option(symb, snm, inv, sz, cop, k, ldt, edt, ud)
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
            obj.call_or_put = cop;
            obj.strike = k;
            obj.listed = ldt;
            obj.expire = edt;
            obj.underlying = ud;
        end

        % ������
        function ret = get.dlmonth(obj)
            ret = str2double(datestr(obj.expire, 'yymm'));
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
            ret = Utility.ToString(obj.underlying.product);
        end
        function ret = GetUnderExchange(obj)
            ret = Utility.ToString(obj.underlying.exchange);
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
        % sample
        function option = Sample(var, exc, inv, info)
            pdt = EnumType.Product.Option;
            switch var
                case {'159919', '510050', '510300'}
                    if (~isempty(info))
                        option = BaseClass.Asset.Asset.Selector(pdt, var, exc, ...
                            info.SYMBOL{:}, ...
                            info.SEC_NAME{:}, ...
                            inv, ...
                            info.SIZE, ...
                            EnumType.CallOrPut.ToEnum(info.CALL_OR_PUT{:}), ...
                            info.STRIKE, ...
                            info.START_TRADE_DATE{:}, ...
                            info.END_TRADE_DATE{:}...
                            );
                    else
                        option = BaseClass.Asset.Asset.Selector(pdt, var, exc, ...
                            'sample', ...
                            'sample', ...
                            inv, ...
                            10000, ...
                            EnumType.CallOrPut.Call, ...
                            888, ...
                            datestr(now()), ...
                            datestr(now())...
                            );
                    end

                otherwise
                    error('Unsupported variety for option sample, please check !');
            end
        end
    end

end