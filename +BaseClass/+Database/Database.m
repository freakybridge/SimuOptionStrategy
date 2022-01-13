% 数据库基类
% v1.3.0.20220113.beta
%       加入成员类型约束
% v1.2.0.20220105.beta
%       首次添加
classdef Database < handle    
    properties (Access = protected)
        user@char;
        password@char;
        driver@char; 
        url@char;
        conns@containers.Map;
        tables@containers.Map;
        db_default@char;
        db_instru@char;
    end
        
    methods
        % 端口初始化
        function obj = Database(user, pwd, db_dft)
            obj.user = user;
            obj.password = pwd;
            obj.db_default = db_dft;
            obj.db_instru = "INSTRUMENTS";
            obj.conns = containers.Map();
            obj.tables = containers.Map();
        end
        
        % 保存行情
        function ret = SaveMarketData(obj, ast)
            switch ast.product
                case EnumType.Product.Option
                    switch ast.interval
                        case {EnumType.Interval.min1, EnumType.Interval.min5, EnumType.Interval.day}
                            ret = SaveBar(obj, ast);
                        otherwise
                            error("Unsupported ""interval"" for market data saving, please check.");
                    end                            
                            
                    
                otherwise
                    error("Unsupported ""product"" for market data saving, please check.");
            end
        end
        
        % 读取行情
        function LoadMarketData(obj, ast)
            switch ast.product
                case EnumType.Product.Option
                    switch ast.interval
                        case {EnumType.Interval.min1, EnumType.Interval.min5, EnumType.Interval.day}
                            obj.LoadBar(ast);
                        otherwise
                            error("Unsupported ""interval"" for market data loading, please check.");
                    end      
                    
                otherwise
                    error("Unsupported ""product"" for market data saving, please check.");
            end
        end
    end
    
    methods (Abstract)
        % 保存期权链
        ret = SaveOptionChain(obj, var, exc, instrus);
        
        % 获取期权链
        instru = LoadOptionChain(obj, var, exc);
    end
    methods (Abstract, Hidden)
        % 保存K线行情
        ret = SaveBar(obj, opt);
        
        % 读取K线行情
        LoadBar(obj, opt);      
    end
    
    methods (Static)
        % 反射器
        function obj = Selector(driver, user, pwd)
            switch EnumType.DatabaseSupported.ToEnum(driver)
                case EnumType.DatabaseSupported.Mss
                    obj = BaseClass.Database.MSS(user, pwd);
                    
                otherwise
                    error("Unsupported database driver, please check.");
            end            
        end
        
        % 获取库名 / 获取表名
        function ret = GetDbName(ast)
            % 预处理
            inv = EnumType.Interval.ToString(ast.interval);
            product = EnumType.Product.ToString(ast.product);
            variety = ast.variety;
            exchange = EnumType.Exchange.ToString(ast.exchange);
            
            % 分类命名
            switch ast.product
                case EnumType.Product.Etf
                    ret = sprintf("%s-%s", inv, product);
                    
                case EnumType.Product.Future
                    ret = sprintf("%s-%s-%s-%s", inv, product, variety, exchange);
                    
                case EnumType.Product.Index
                    ret = sprintf("%s-%s", inv, product);
                    
                case EnumType.Product.Option
                    ret = sprintf("%s-%s-%s-%s", inv, product, variety, exchange);
                    
                otherwise
                    error("Unexpected product for name database, please check !");
            end
            ret = upper(ret);
        end
        function ret = GetTableName(varargin)
            % 多态处理
            if (nargin() == 1 && ismember('BaseClass.Asset.Asset', superclasses(varargin{1})))
                % 行情表名
                % 预处理
                ast = varargin{1};
                symbol = ast.symbol;
                exchange = EnumType.Exchange.ToString(ast.exchange);
                
                % 分类命名
                switch ast.product
                    case EnumType.Product.Etf
                        ret = sprintf("%s_%s", symbol, exchange);
                        
                    case EnumType.Product.Future
                        ret = symbol;
                        
                    case EnumType.Product.Index
                        ret = sprintf("%s_%s", symbol, exchange);
                        
                    case EnumType.Product.Option
                        ret = symbol;
                        
                    otherwise
                        error("Unexpected product for name table, please check !");
                end
                ret = upper(ret);
                
            elseif (nargin() == 3 && isa(varargin{1}, 'EnumType.Product') && (isa(varargin{2}, 'string') || isa(varargin{2}, 'char')) && isa(varargin{3}, 'EnumType.Exchange'))
                % 合约表名
                pdt = varargin{1};
                var = varargin{2};
                exc = varargin{3};
                ret = sprintf("%s-%s-%s", EnumType.Product.ToString(pdt), var, EnumType.Exchange.ToString(exc));
                
            else
                error("Unexpected input arguments, please check!");
            end
        end
        
    end
end