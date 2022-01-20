% ���ݿ����
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
%       2.�ع�����
% v1.2.0.20220105.beta
%       �״����
classdef Database < handle
    properties (Access = protected)
        user char;
        password char;
        driver char;
        url char;
        conns containers.Map;
        tables containers.Map;
        db_default char;
        db_instru char;
        
        map_save_func containers.Map;
        map_load_func containers.Map;        
    end
    properties (Abstract, Constant)
        name char;
    end

    methods
        % �˿ڳ�ʼ��
        function obj = Database(user, pwd, db_dft)
            % ���Գ�ʼ��
            obj.user = user;
            obj.password = pwd;
            obj.db_default = db_dft;
            obj.db_instru = "INSTRUMENTS";
            obj.conns = containers.Map();
            obj.tables = containers.Map();            
            obj.AttachFuncHandle();            
        end
             
        % ��������
        function ret = SaveMarketData(obj, asset)
            fprintf('Saving [%s.%s]''s %s quetos to [%s], please wait ...\r', asset.symbol, Utility.ToString(asset.exchange), Utility.ToString(asset.interval), obj.name);
            product = Utility.ToString(asset.product);
            interval = Utility.ToString(asset.interval);
            func = obj.map_save_func(product);
            func = func(interval);
            ret = func(asset);
        end

        % ��ȡ����
        function LoadMarketData(obj, asset)
            fprintf('Loading [%s.%s]''s %s quetos from [%s], please wait ...\r', asset.symbol, Utility.ToString(asset.exchange), Utility.ToString(asset.interval), obj.name);
            product =Utility.ToString(asset.product);
            interval = Utility.ToString(asset.interval);
            func = obj.map_load_func(product);
            func = func(interval);
            func(asset);
        end

        % �����Լ��
        function ret = SaveChain(obj, pdt, var, exc, instrus)
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

        % ��ȡ��Լ��
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
    end
    
    
    methods (Hidden)
        function AttachFuncHandle(obj)
            % ���� Save
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
            
            % ���� Load
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
        % ������Ȩ / �ڻ���Լ�б�
        ret = SaveChainOption(obj, var, exc, instrus);
        ret = SaveChainFuture(obj, var, exc, instrus);

        % ��ȡ��Ȩ / �ڻ���Լ�б�
        instru = LoadChainOption(obj, var, exc);
        instru = LoadChainFuture(obj, var, exc); 
        
        % ����K������
        ret = SaveBarMin(obj, asset);
        ret = SaveBarDayEtf(obj, asset);
        ret = SaveBarDayFuture(obj, asset);
        ret = SaveBarDayIndex(obj, asset);
        ret = SaveBarDayOption(obj, asset);

        % ��ȡK������
        LoadBarMin(obj, asset);
        LoadBarDayEtf(obj, asset);
        LoadBarDayFuture(obj, asset);
        LoadBarDayIndex(obj, asset);
        LoadBarDayOption(obj, asset);
        
        % ��ȡ ȫ�����ݿ� / ��ǰ�����б� / ��ȡԭʼ����
        ret = FetchAllDbs(obj);
        ret = FetchAllTables(obj, db);
        ret = FetchRawData(obj, db, tb);
        
    end

    methods (Static)
        % ������
        function obj = Selector(driver, user, pwd)
            switch EnumType.DatabaseSupported.ToEnum(driver)
                case EnumType.DatabaseSupported.Mss
                    obj = BaseClass.Database.MSS(user, pwd);

                otherwise
                    error("Unsupported database driver, please check.");
            end
        end

        % ��ȡ���� / ��ȡ���� / ������
        function ret = GetDbName(asset)
            % Ԥ����
            inv = Utility.ToString(asset.interval);
            product = Utility.ToString(asset.product);
            variety = asset.variety;
            exchange = Utility.ToString(asset.exchange);

            % ��������
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
            % ��̬����
            if (nargin() == 1 && ismember('BaseClass.Asset.Asset', superclasses(varargin{1})))
                % �������
                % Ԥ����
                ast = varargin{1};
                symbol = ast.symbol;
                exchange = Utility.ToString(ast.exchange);

                % ��������
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
                % ��Լ����
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