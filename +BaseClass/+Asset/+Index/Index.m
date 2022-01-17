% Index����
% v1.3.0.20220113.beta
%       �״����
classdef Index < BaseClass.Asset.Asset
    % ����Asset����
    properties (Constant)
        product EnumType.Product = EnumType.Product.Index;
    end
    
    methods
        % ���캯��
        function obj = Index(symb, snm, inv, sz)
            % INDEX ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
        end

        % �޲�����
        function RepairData(obj, tm_ax_std)
            switch obj.interval
                case {EnumType.Interval.min1, EnumType.Interval.min5}
                    % �������
                    [~, loc] = intersect(tm_ax_std(:, 1), obj.md(:, 1));
                    md_new = tm_ax_std;
                    md_new(loc, 2 : size(obj.md, 2)) = obj.md(:, 2 : end);

                    % ����nan
                    md_new(isnan(md_new)) = 0;

                    % ��������
                    % ����ǰ������
                    loc_start = find(md_new(:, 7) ~= 0, 1, 'first');
                    md_new(1 : loc_start, 7) = md_new(loc_start, 4);

                    % ����������
                    loc_end = find(md_new(:, 1) <= obj.expire, 1, 'last');
                    for i = loc_start + 1 : loc_end
                        if (md_new(i, 7) == 0)
                            md_new(i, 4 : 7) = md_new(i - 1, 7);
                        end
                    end
                    obj.md = md_new;

                case EnumType.Interval.day
                    error("123");

                otherwise
                    error('Unexpected "interval" for market data repairing, please check.');
            end
        end
    end
end
