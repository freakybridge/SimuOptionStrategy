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
    
    methods (Abstract, Static)
        % 获取api流量时限
        ret = FetchApiDateLimit();
    end
end

