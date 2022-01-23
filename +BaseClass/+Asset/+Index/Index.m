% Index基类
% v1.3.0.20220113.beta
%       首次添加
classdef Index < BaseClass.Asset.Asset
    % 父类Asset属性
    properties (Constant)
        product EnumType.Product = EnumType.Product.Index;
    end
    
    methods
        % 构造函数
        function obj = Index(varargin)
            % INDEX 构造此类的实例
            %   此处显示详细说明
            [symb, snm, inv, sz] = BaseClass.Asset.Index.Index.CheckArgument(varargin{:});        
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
        end

        % 修补行情
        function RepairData(obj, tm_ax_std)
            % 构建新行情
            % 行情对齐
            [~, loc] = intersect(tm_ax_std(:, 1), obj.md(:, 1));
            md_new = tm_ax_std;
            md_new(loc, 2 : size(obj.md, 2)) = obj.md(:, 2 : end);

            % 消除nan
            md_new(isnan(md_new)) = 0;

            % 定位填充点
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

            % 补足行情
            % 补足前端行情
            loc_start = find(md_new(:, col_close) ~= 0, 1, 'first');
            md_new(1 : loc_start, col_close) = md_new(loc_start, col_open);

            % 补足后端行情
            loc_end = size(md_new, 1);
            for i = loc_start + 1 : loc_end
                if (md_new(i, col_close) == 0)
                    md_new(i, col_price) = md_new(i - 1, col_close);
                end
            end
            obj.md = md_new;
        end
    end

    methods (Static)
        % 检查输入
        function [symb, snm, inv, sz] = CheckArgument(varargin)
            if (nargin ~= 4)
                error('Intialization arguments error, need input "interval", please check');
            end
            
            [symb, snm, inv, sz] = varargin{:};
             if (~isa(symb, 'char') && ~isa(symb, 'string'))
                error('"Symbol" arugument error, please check');
             end
            
            if (~isa(snm, 'char') && ~isa(snm, 'string'))
                error('"Security name" arugument error, please check');
            end
            
            if (~isa(inv, 'EnumType.Interval'))
                error('"Interva"l arugument error, please check');
            end
            
            if (~isa(sz, 'double'))
                error('"Size" arugument error, please check');
            end     
        end
    end
end
