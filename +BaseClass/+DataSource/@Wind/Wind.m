% 数据源端口 WindApi
% v1.2.0.20220105.beta
%       首次添加
classdef Wind < BaseClass.DataSource.DataSource
    properties (Access = private)
        api;
    end
    properties (Hidden)        
        exchanges;
    end
    
    methods
        % 构造函数
        function obj = Wind()
            %WIND 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.DataSource.DataSource();
            obj.api = windmatlab;
            obj.exchanges = containers.Map;
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SSE)) = 'SH';
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SZSE)) = 'SZ';       
            disp('DataSource Wind Ready.');
        end
        
        % 获取期权分钟数据
        function md = FetchOptionMinData(obj, opt, ts_s, ts_e, inv)
            % 确定是否数据超限
            if (datenum(opt.GetDateListed()) < now - obj.FetchApiDateLimit())
                md = [];
                return;
            end
            
            % 下载
            exc = obj.exchanges(EnumType.Exchange.ToString(opt.exchange));
            [md, code, ~, dt, errorid, ~] = obj.api.wsi([opt.symbol, '.', exc], 'open,high,low,close,amt,volume,oi', ...
                datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), sprintf('BarSize=%i',  inv));
            
            if (errorid ~= 0)
                warning('Fetching option %s market data error, id %i, msg %s, please check.', code{:}, errorid, md{:});
                md = [];
                return;
            end
            md = [dt, md];
        end
        
        % 获取期权合约列表
        function instrus = FetchOptionChain(obj, var, exc_ud, exc_opt, instru_local, date_s, date_e)
            exc_ud = obj.exchanges(EnumType.Exchange.ToString(exc_ud));
            exc_opt = lower(EnumType.Exchange.ToString(exc_opt));
            str = sprintf('startdate=%s;enddate=%s;exchange=%s;windcode=%s.%s;status=all;field=wind_code,sec_name,call_or_put,exercise_price,contract_unit,listed_date,expire_date', ...
                date_s, date_e, exc_opt, var, exc_ud);
            [instrus, ~, fields, ~, errid, ~] = obj.api.wset('optioncontractbasicinfo', str);
% startdate=2022-01-11;enddate=2022-01-11;exchange=sse;windcode=510050.SH;status=all;field=wind_code,sec_name,call_or_put,exercise_price,contract_unit,listed_date,expire_date
% startdate=2021-01-11;enddate=2022-01-11;exchange=sse;windcode=510300.SH;status=all;field=wind_code,sec_name,call_or_put,exercise_price,contract_unit,listed_date,expire_date
right_str = 'startdate=2022-01-11;enddate=2022-01-11;exchange=sse;windcode=510050.SH;status=all;field=wind_code,sec_name,call_or_put,exercise_price,contract_unit,listed_date,expire_date';
obj.api.wset('optioncontractbasicinfo', right_str)

        end
    end
    
    methods (Static)        
        % 获取api流量时限
        function ret = FetchApiDateLimit()
            ret = 3 * 365;
        end
    end
end

