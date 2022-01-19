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
        listed double;
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
        function obj = Future(symb, snm, inv, sz, ltdt, epdt, mgn, fety, f)
            % Future ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
            obj.listed = ltdt;
            obj.expire = epdt;
            obj.ratio_margin = mgn;
            obj.fee_ty = fety;
            obj.fee = f;
        end
        
        % ������
        function ret = get.dlmonth(obj)
            ret = str2double(datestr(obj.expire, 'yymm'));
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