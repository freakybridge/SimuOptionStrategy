% Excel��д��
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
classdef ExcelReader
    properties (Access = protected)        
        map_save_func containers.Map;
        map_load_func containers.Map;        
    end

    methods
        % ��ʼ��
        function obj = ExcelReader()
            obj.AttachFuncHandle();            
        end
             
        % �����Լ�б�
        function ret = SaveChain(obj, pdt, var, exc, instrus, dir_)
            switch pdt
                case EnumType.Product.Option
                    ret = obj.SaveChainOption(var, exc, instrus, dir_);
                case EnumType.Product.Future
                    ret = obj.SaveChainFuture(var, exc, instrus, dir_);
                otherwise
                    error('Unexpected "product" for instruments saving, please check.')
            end                    
        end
             
        % ��ȡ��Լ�б�
        function instru = LoadChain(obj, pdt, var, exc, dir_)
            switch pdt
                case EnumType.Product.Option
                    instru = obj.LoadChainOption(var, exc, dir_);
                case EnumType.Product.Future
                    instru = obj.LoadChainFuture(var, exc, dir_);
                otherwise
                    error('Unexpected "product" for instruments loading, please check.')
            end                    
        end
        
        % ��������
        function ret = SaveMarketData(obj, asset)
            product = EnumType.Product.ToString(asset.product);
            interval = EnumType.Interval.ToString(asset.interval);
            func = obj.map_save_func(product);
            func = func(interval);
            ret = func(asset);
        end

        % ��ȡ����
        function LoadMarketData(obj, asset)
            product = EnumType.Product.ToString(asset.product);
            interval = EnumType.Interval.ToString(asset.interval);
            func = obj.map_load_func(product);
            func = func(interval);
            func(asset);
        end
    end
    
    
    methods (Hidden)
        % ճ�����
        function AttachFuncHandle(obj)
            % ���� Save
            import EnumType.Product;
            import EnumType.Interval;
            
            ETF = containers.Map();
            ETF(Interval.ToString(Interval.min1)) = @obj.SaveBarMin;
            ETF(Interval.ToString(Interval.min5)) = @obj.SaveBarMin;
            ETF(Interval.ToString(Interval.day))= @obj.SaveBarDayEtf;
            
            FUT = containers.Map();
            FUT(Interval.ToString(Interval.min1)) = @obj.SaveBarMin;
            FUT(Interval.ToString(Interval.min5)) = @obj.SaveBarMin;
            FUT(Interval.ToString(Interval.day))= @obj.SaveBarDayFuture;
            
            IDX = containers.Map();
            IDX(Interval.ToString(Interval.min1)) = @obj.SaveBarMin;
            IDX(Interval.ToString(Interval.min5)) = @obj.SaveBarMin;
            IDX(Interval.ToString(Interval.day))= @obj.SaveBarDayIndex;
            
            OPT = containers.Map();
            OPT(Interval.ToString(Interval.min1)) = @obj.SaveBarMin;
            OPT(Interval.ToString(Interval.min5)) = @obj.SaveBarMin;
            OPT(Interval.ToString(Interval.day))= @obj.SaveBarDayOption;
            
            obj.map_save_func(Product.ToString(Product.Etf)) = ETF;
            obj.map_save_func(Product.ToString(Product.Future)) = FUT;
            obj.map_save_func(Product.ToString(Product.Index)) = IDX;
            obj.map_save_func(Product.ToString(Product.Option)) = OPT;
            
            % ���� Load
            ETF = containers.Map();
            ETF(Interval.ToString(Interval.min1)) = @obj.LoadBarMin;
            ETF(Interval.ToString(Interval.min5)) = @obj.LoadBarMin;
            ETF(Interval.ToString(Interval.day))= @obj.LoadBarDayEtf;
            
            FUT = containers.Map();
            FUT(Interval.ToString(Interval.min1)) = @obj.LoadBarMin;
            FUT(Interval.ToString(Interval.min5)) = @obj.LoadBarMin;
            FUT(Interval.ToString(Interval.day))= @obj.LoadBarDayFuture;
            
            IDX = containers.Map();
            IDX(Interval.ToString(Interval.min1)) = @obj.LoadBarMin;
            IDX(Interval.ToString(Interval.min5)) = @obj.LoadBarMin;
            IDX(Interval.ToString(Interval.day))= @obj.LoadBarDayIndex;
            
            OPT = containers.Map();
            OPT(Interval.ToString(Interval.min1)) = @obj.LoadBarMin;
            OPT(Interval.ToString(Interval.min5)) = @obj.LoadBarMin;
            OPT(Interval.ToString(Interval.day))= @obj.LoadBarDayOption;
            
            obj.map_load_func(Product.ToString(Product.Etf)) = ETF;
            obj.map_load_func(Product.ToString(Product.Future)) = FUT;
            obj.map_load_func(Product.ToString(Product.Index)) = IDX;
            obj.map_load_func(Product.ToString(Product.Option)) = OPT;
            
        end
        
        % ������Ȩ / �ڻ���Լ�б�
        ret = SaveChainOption(obj, var, exc, instrus, dir_);
        ret = SaveChainFuture(obj, var, exc, instrus, dir_);

        % ��ȡ��Ȩ / �ڻ���Լ�б�
        instru = LoadChainOption(obj, var, exc, dir_);
        instru = LoadChainFuture(obj, var, exc, dir_);
        
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
    end
end