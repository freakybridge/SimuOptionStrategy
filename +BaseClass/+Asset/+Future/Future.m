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
        % 构造函数
        function obj = Future(varargin)      
            [symb, snm, inv, sz, ltdt, epdt, mgn, fety, f] = BaseClass.Asset.Future.Future.CheckArgument(varargin{:});          
            obj = obj@BaseClass.Asset.Asset(symb, snm, inv, sz);
            obj.listed = ltdt;
            obj.expire = epdt;
            obj.ratio_margin = mgn;
            obj.fee_ty = fety;
            obj.fee = f;
        end
        
        % 交割月
        function ret = get.dlmonth(obj)
            ret = str2double(datestr(obj.expire, 'yymm'));
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
            loc_end = find(md_new(:, 1) <= obj.expire, 1, 'last');
            for i = loc_start + 1 : loc_end
                if (md_new(i, col_close) == 0)
                    md_new(i, col_price) = md_new(i - 1, col_close);
                end
            end
            obj.md = md_new;
        end
        
        % 获取挂牌时点
        function ret = GetDateListed(obj)
            ret = datestr(obj.listed);
        end
        
        % 获取到期时点
        function ret = GetDateExpire(obj)
            ret = datestr(obj.expire);
        end
    end

    methods (Static)
        % 检查输入
        function [symb, snm, inv, sz, ltdt, epdt, mgn, fety, f] = CheckArgument(varargin)            
            if (nargin ~= 9)
                error('Intialization arguments error, need input "symbol/sec_name/interval/unit/date listed/date expired/margin ratio/fee type/ fee", please check');
            end
            
            [symb, snm, inv, sz, ltdt, epdt, mgn, fety, f] = varargin{:};
            if (~isa(symb, 'char') && ~isa(symb, 'string'))
                error('"Symbol" arugument error, please check');
            end
            
            if (~isa(snm, 'char') && ~isa(snm, 'string'))
                error('"Security name" arugument error, please check');
            end
            
            if (~isa(inv, 'EnumType.Interval'))
                error('"Interval" arugument error, please check');
            end
            
            if (~isa(sz, 'double'))
                error('"Size" arugument error, please check');
            end
                        
            if(~isa(ltdt, 'char') && ~isa(ltdt, 'string'))
                error('"Listed date" arugument error, please check');
            end   
            ltdt = datenum(ltdt);
            
            if (~isa(epdt, 'char') && ~isa(epdt, 'string'))
                error('"Expire date" arugument error, please check');
            end       
            epdt = datenum(epdt);

            if (~isa(mgn, 'double'))
                error('"Margin ratio" arugument error, please check');
            end
            if (~isa(fety, 'double'))
                error('"Fee type" arugument error, please check');
            end
            if (~isa(f, 'double'))
                error('"Fee" arugument error, please check');
            end
        end
    end
end