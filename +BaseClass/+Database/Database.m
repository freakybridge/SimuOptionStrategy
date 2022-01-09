% 数据库基类
% v1.2.0.20220105.beta
%       首次添加
classdef Database < handle    
    properties (Access = protected)
        user;
        password;
        driver; 
        url;
        conns;
        tables;
        db_default;
    end
        
    methods
        % 端口初始化
        function obj = Database(user, pwd, db_dft)
            obj.user = user;
            obj.password = pwd;
            obj.db_default = db_dft;
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
        ret = SaveOptionChain(obj, instru);
        
        % 获取期权链
        instru = LoadOptionChain(obj, opt);
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
    end
end