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
        % ���캯��
        function obj = ETF(symb, snm, inv, sz)
            % ETF ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
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
                    col_close = 9;
                    col_open = 6;
                    col_price = 6 : 9;

                otherwise
                    error('Unexpected "interval" for market data repairing, please check.');
            end

            % ��������
            % ����ǰ������
            loc_start = find(md_new(:, col_close) ~= 0, 1, 'first');
            md_new(1 : loc_start, col_close) = md_new(loc_start, col_open);

            % ����������
            loc_end = size(md_new, 1);
            for i = loc_start + 1 : loc_end
                if (md_new(i, col_close) == 0)
                    md_new(i, col_price) = md_new(i - 1, col_close);
                end
            end
            obj.md = md_new;
        end
    end
end