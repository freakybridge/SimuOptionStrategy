classdef DataSourceApi
    %DATASOURCEAPI 此处显示有关此类的摘要
    %   此处显示详细说明
    properties (Abstract)
        exchanges;
    end
        
    methods
        function obj = DataSourceApi()
            %DATASOURCEAPI 构造此类的实例
            %   此处显示详细说明
        end
    end
    
    
    methods (Abstract)
        % 获取期权分钟数据
        md = FetchOptionMinData(obj, symb, exc, ts_s, ts_e, inv);
    end
% [data,errorcode,time,indicators,thscode,errmsg,dataVol,datatype,perf]=THS_HF('10003769.SH','open;high;low;close;amount;volume;openInterest','Fill:Previous,Interval:5','2021-12-24 09:15:00','2021-12-24 15:15:00','format:table')    end
end

