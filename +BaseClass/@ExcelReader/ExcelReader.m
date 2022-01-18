% Excel��д��
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
classdef ExcelReader
    properties (Access = protected)
    end
    
    methods
        % ��ʼ��
        function obj = ExcelReader()
            disp('[Excel Reader] ready.');
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
        function ret = SaveMarketData(obj, asset, dir_)
            switch asset.interval
                case {EnumType.Interval.min1, EnumType.Interval.min5}
                    ret = obj.SaveBar(asset, dir_, 'datetime,open,high,low,last,turnover,volume,oi', '%s,%.4f,%.4f,%.4f,%.4f,%i,%i,%i');
                    
                case {EnumType.Interval.day}
                    switch asset.product
                        case EnumType.Product.Etf
                            ret = obj.SaveBar(asset, dir_, 'datetime,nav, nav_adj, open,high,low,last,turnover,volume', '%s,%.5f,%.5f,%.4f,%.4f,%.4f,%.4f,%i,%i');
                            
                        case EnumType.Product.Future
                            ret = obj.SaveBar(asset, dir_, 'datetime,open,high,low,last,turnover,volume,oi,presettle,settle,st_stock', '%s,%.4f,%.4f,%.4f,%.4f,%i,%i,%i,%.4f,%.4f,%i');
                            
                        case EnumType.Product.Index
                            ret = obj.SaveBar(asset, dir_, 'datetime,open,high,low,last,turnover,volume', '%s,%.4f,%.4f,%.4f,%.4f,%i,%i');
                            
                        case EnumType.Product.Option
                            ret = obj.SaveBar(asset, dir_, 'datetime,open,high,low,last,turnover,volume,oi,presettle,settle,remain_n, remain_t', '%s,%.4f,%.4f,%.4f,%.4f,%i,%i,%i,%.4f,%.4f,%i,%i');
                            
                        otherwise
                            error('Unexpected "product" for market data csv saving, please check');
                    end
                    
                otherwise
                    error('Unexpected "interval" for market data csv saving, please check');
            end
        end
        
        % ��ȡ����
        function LoadMarketData(obj, asset, dir_)
            obj.LoadBar(asset, dir_);
        end
    end
    
    
    methods (Hidden)
        
        % ������Ȩ / �ڻ���Լ�б�
        ret = SaveChainOption(obj, var, exc, instrus, dir_);
        ret = SaveChainFuture(obj, var, exc, instrus, dir_);
        
        % ��ȡ��Ȩ / �ڻ���Լ�б�
        instru = LoadChainOption(obj, var, exc, dir_);
        instru = LoadChainFuture(obj, var, exc, dir_);
        
        % ����K������
        ret = SaveBar(obj, asset, dir_, header, dat_fmt);
        
        % ��ȡK������
        LoadBar(obj, asset, dir_);
    end
end