% Excel��д��
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
classdef DataRecorder
    properties (Access = protected)
        name char = 'DataRecorder';
    end
    
    methods
        % ��ʼ��
        function obj = DataRecorder()
            fprintf('App [%s] ready.\r', obj.name);
        end
        
        % �����Լ�б�
        function ret = SaveChain(obj, pdt, var, exc, instrus, dir_)
            fprintf('Saving [%s-%s-%s]''s instruments to [%s], please wait ...\r', Utility.ToString(pdt), var, Utility.ToString(exc), obj.name);
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
            fprintf('Loading [%s-%s-%s]''s instruments from [%s], please wait ...\r', Utility.ToString(pdt), var, Utility.ToString(exc), obj.name);
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
            fprintf('Saving [%s.%s]''s %s quetos to [%s], please wait ...\r', asset.symbol, Utility.ToString(asset.exchange), Utility.ToString(asset.interval), obj.name);
            switch asset.interval
                case {EnumType.Interval.min1, EnumType.Interval.min5}
                    ret = obj.SaveBar(asset, dir_, 'datetime,open,high,low,last,turnover,volume,oi', '%s,%.4f,%.4f,%.4f,%.4f,%i,%i,%i');
                    
                case {EnumType.Interval.day}
                    switch asset.product
                        case EnumType.Product.ETF
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
        function md = LoadMarketData(obj, asset, dir_)
            fprintf('Loading [%s.%s]''s %s quetos from [%s], please wait ...\r', asset.symbol, Utility.ToString(asset.exchange), Utility.ToString(asset.interval), obj.name);
            md = obj.LoadBar(asset, dir_);
        end
        
        % ���潻������
        function ret = SaveCalendar(~, cal, dir_)
            dir_ = fullfile(dir_, 'CALENDAR');
            Utility.CheckDirectory(dir_);
            
            % ��������ļ���
            filename = fullfile(dir_, "Calendar.csv");
            
            % ���б�ͷ / ���ݸ�ʽ
            header = 'DATETIME,TRADING,WORKING,WEEKDAY,DATENUM,LAST_UPDATE_DATE\r';
            dat_fmt = '%i,%i,%i,%i,%i,%f\r';
            
            % д���ͷ / д������
            id = fopen(filename, 'w');
            fprintf(id, header);
            for i = 1 : size(cal, 1)
                fprintf(id, dat_fmt, cal(i, :));
            end
            fclose(id);
            ret = true;
        end
        
        % ��ȡ��������
        function cal = LoadCalendar(~, dir_)            
            % Ԥ����
            % �������Ŀ¼ / ��������ļ���
            dir_ = fullfile(dir_, 'CALENDAR');
            filename = fullfile(dir_, 'Calendar.csv');
            
            % ����ļ� / ��ȡ
            if (~exist(filename, 'file'))
                warning('Please check csv file "%s", can''t find it.', filename);
                cal = zeros(0, 6);
            else
                cal = table2array(readtable(filename));
            end
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