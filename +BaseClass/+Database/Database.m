% 数据库基类
% v1.3.0.20220113.beta
%       1.加入成员类型约束
%       2.重构方法
% v1.2.0.20220105.beta
%       首次添加
classdef Database < handle
    properties (Access = protected)
        user char;
        password char;
        driver char;
        url char;
        conns containers.Map;
        tables containers.Map;
        db_default char;
        db_instru char = 'INSTRUMENTS';
        db_calendar char = 'CALENDAR';
        tb_calendar char = 'Calendar';
        tb_overviews char = 'Overviews';
        
        map_save_func containers.Map;
        map_load_func containers.Map;        
    end
    properties (Abstract, Constant)
        name char;
    end

    methods
        % 端口初始化
        function obj = Database(user, pwd, db_def)
            % 属性初始化
            obj.user = user;
            obj.password = pwd;
            obj.db_default = db_def;
            obj.conns = containers.Map();
            obj.tables = containers.Map();            
            obj.AttachFuncHandle();            
        end
             
        % 保存行情
        function ret = SaveMarketData(obj, asset, md)
            if (isempty(md))
                fprintf(2, 'Saving [%s.%s]''s %s quetos to [%s] failure, data empty, please check !\r', asset.symbol, Utility.ToString(asset.exchange), Utility.ToString(asset.interval), obj.name);
                ret = false;
                return;
            end
            fprintf('Saving [%s.%s]''s %s quetos to [%s], please wait ...\r', asset.symbol, Utility.ToString(asset.exchange), Utility.ToString(asset.interval), obj.name);
            product = Utility.ToString(asset.product);
            interval = Utility.ToString(asset.interval);
            func = obj.map_save_func(product);
            func = func(interval);
            ret = func(asset, md);
        end

        % 读取行情
        function md = LoadMarketData(obj, asset)
            fprintf('Loading [%s.%s]''s %s quetos from [%s], please wait ...\r', asset.symbol, Utility.ToString(asset.exchange), Utility.ToString(asset.interval), obj.name);
            product =Utility.ToString(asset.product);
            interval = Utility.ToString(asset.interval);
            func = obj.map_load_func(product);
            func = func(interval);
            md = func(asset);
        end

        % 保存合约表
        function ret = SaveChain(obj, pdt, var, exc, instrus)
            if (isempty(instrus))
                fprintf(2, 'Saving [%s-%s-%s]''s instruments to [%s] failure, data empty, please check !\r', Utility.ToString(pdt), var, Utility.ToString(exc), obj.name);
                ret = false;
                return;
            end
            fprintf('Saving [%s-%s-%s]''s instruments to [%s], please wait ...\r', Utility.ToString(pdt), var, Utility.ToString(exc), obj.name);
            switch  pdt
                case EnumType.Product.Future
                    ret = obj.SaveChainFuture(var, exc, instrus);
                case EnumType.Product.Option
                    ret = obj.SaveChainOption(var, exc, instrus);
                otherwise
                    error('Unexpected "product" for instruments save to database, please check.')
            end
        end

        % 读取合约表
        function instrus = LoadChain(obj, pdt, var, exc)
            fprintf('Loading [%s-%s-%s]''s instruments from [%s], please wait ...\r', Utility.ToString(pdt), var, Utility.ToString(exc), obj.name);
            switch  pdt
                case EnumType.Product.Future
                    instrus = obj.LoadChainFuture(var, exc);
                case EnumType.Product.Option
                    instrus = obj.LoadChainOption(var, exc);
                otherwise
                    error('Unexpected "product" for instruments load from database, please check.')
            end
        end
        
        % 保存交易日历
        ret = SaveCalendar(obj, cal);
        
        % 载入交易日历
        cal = LoadCalendar(obj);
    end
    methods (Abstract)
        views = LoadOverviews(obj, asset);
    end
    
    
    methods (Hidden)
        function AttachFuncHandle(obj)
            % 整理 Save
            import EnumType.Product;
            import EnumType.Interval;
            
            ETF = containers.Map();
            ETF(Utility.ToString(Interval.min1)) = @obj.SaveBarMin;
            ETF(Utility.ToString(Interval.min5)) = @obj.SaveBarMin;
            ETF(Utility.ToString(Interval.day))= @obj.SaveBarDayEtf;
            
            FUT = containers.Map();
            FUT(Utility.ToString(Interval.min1)) = @obj.SaveBarMin;
            FUT(Utility.ToString(Interval.min5)) = @obj.SaveBarMin;
            FUT(Utility.ToString(Interval.day))= @obj.SaveBarDayFuture;
            
            IDX = containers.Map();
            IDX(Utility.ToString(Interval.min1)) = @obj.SaveBarMin;
            IDX(Utility.ToString(Interval.min5)) = @obj.SaveBarMin;
            IDX(Utility.ToString(Interval.day))= @obj.SaveBarDayIndex;
            
            OPT = containers.Map();
            OPT(Utility.ToString(Interval.min1)) = @obj.SaveBarMin;
            OPT(Utility.ToString(Interval.min5)) = @obj.SaveBarMin;
            OPT(Utility.ToString(Interval.day))= @obj.SaveBarDayOption;
            
            obj.map_save_func(Utility.ToString(Product.ETF)) = ETF;
            obj.map_save_func(Utility.ToString(Product.Future)) = FUT;
            obj.map_save_func(Utility.ToString(Product.Index)) = IDX;
            obj.map_save_func(Utility.ToString(Product.Option)) = OPT;
            
            % 整理 Load
            ETF = containers.Map();
            ETF(Interval.ToString(Interval.min1)) = @obj.LoadBarMin;
            ETF(Interval.ToString(Interval.min5)) = @obj.LoadBarMin;
            ETF(Interval.ToString(Interval.day))= @obj.LoadBarDayEtf;
            
            FUT = containers.Map();
            FUT(Utility.ToString(Interval.min1)) = @obj.LoadBarMin;
            FUT(Utility.ToString(Interval.min5)) = @obj.LoadBarMin;
            FUT(Utility.ToString(Interval.day))= @obj.LoadBarDayFuture;
            
            IDX = containers.Map();
            IDX(Utility.ToString(Interval.min1)) = @obj.LoadBarMin;
            IDX(Utility.ToString(Interval.min5)) = @obj.LoadBarMin;
            IDX(Utility.ToString(Interval.day))= @obj.LoadBarDayIndex;
            
            OPT = containers.Map();
            OPT(Utility.ToString(Interval.min1)) = @obj.LoadBarMin;
            OPT(Utility.ToString(Interval.min5)) = @obj.LoadBarMin;
            OPT(Utility.ToString(Interval.day))= @obj.LoadBarDayOption;
            
            obj.map_load_func(Utility.ToString(Product.ETF)) = ETF;
            obj.map_load_func(Utility.ToString(Product.Future)) = FUT;
            obj.map_load_func(Utility.ToString(Product.Index)) = IDX;
            obj.map_load_func(Utility.ToString(Product.Option)) = OPT;
            
        end
    end


    methods (Abstract, Hidden)
        % 保存期权 / 期货合约列表
        ret = SaveChainOption(obj, var, exc, instrus);
        ret = SaveChainFuture(obj, var, exc, instrus);

        % 获取期权 / 期货合约列表
        instru = LoadChainOption(obj, var, exc);
        instru = LoadChainFuture(obj, var, exc); 
        
        % 保存K线行情
        ret = SaveBarMin(obj, asset, md);
        ret = SaveBarDayEtf(obj, asset, md);
        ret = SaveBarDayFuture(obj, asset, md);
        ret = SaveBarDayIndex(obj, asset, md);
        ret = SaveBarDayOption(obj, asset, md);

        % 读取K线行情
        md = LoadBarMin(obj, asset);
        md = LoadBarDayEtf(obj, asset);
        md = LoadBarDayFuture(obj, asset);
        md = LoadBarDayIndex(obj, asset);
        md = LoadBarDayOption(obj, asset);
        
        % 读取 全部数据库 / 当前库所有表 / 获取原始数据
        ret = FetchAllDbs(obj);
        ret = FetchAllTables(obj, db);
        ret = FetchRawData(obj, db, tb);
        
        % Create Overviews / Overviews Trigger
        CreateTableOverviews(obj, conn, db);
        CreateTriggerOverviews(obj, conn, tb);

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

        % 获取库名 / 获取表名 / 表索引
        function ret = GetDbName(asset)
            % 预处理
            inv = Utility.ToString(asset.interval);
            product = Utility.ToString(asset.product);
            variety = asset.variety;
            exchange = Utility.ToString(asset.exchange);

            % 分类命名
            switch asset.product
                case EnumType.Product.ETF
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
                exchange = Utility.ToString(ast.exchange);

                % 分类命名
                switch ast.product
                    case EnumType.Product.ETF
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
                ret = sprintf("%s-%s-%s", Utility.ToString(pdt), var, Utility.ToString(exc));

            else
                error("Unexpected input arguments, please check!");
            end
        end
        function ret = TableIndex(db, tb)
            ret = sprintf("id_%s_%s", db, tb);
        end
        
    end
end