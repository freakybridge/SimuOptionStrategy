classdef iFinD < BaseClass.DataSourceApi
    % iFinD 此处显示有关此类的摘要
    %   此处显示详细说明
    properties (Access = private)
        user;
        password;
        api;
    end
    properties (Hidden)        
        exchanges;
    end
    
    methods
        % 构造函数
        function obj = iFinD(ur, pwd)
            % iFinD 构造此类的实例
            %   此处显示详细说明
            obj = obj@BaseClass.DataSourceApi();
            obj.user = ur;
            obj.password = pwd;
            THS_iFinDLogin(ur, pwd);
            
            obj.exchanges = containers.Map;
            obj.exchanges('sse') = 'SH';
            obj.exchanges('szse') = 'SZ';            
            disp('DataSource iFinD Ready.');
        end
        
        % 获取期权分钟数据
        function md = FetchOptionMinData(obj, symb, exc, ts_s, ts_e, inv)
            exc = obj.exchanges(lower(exc));
            
             [md, errorid, dt, ~,~, ~, ~, ~] = THS_HF([symb, '.', exc],'open;high;low;close;amount;volume',...
                 sprintf('Fill:Previous,Interval:%i',  inv), ...
                 datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), ...
                 datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), ...
                 'format:matrix');
                        
            if (errorid ~= 0)
                warning('Fetching option %s market data error, id %i, please check.', symb, errorid);
                md = nan;
                return;
            end
            md = [datenum(dt), md];

        end
    end
    
    methods (Static)        
        % 获取api流量时限
        function ret = FetchApiDateLimit()
            ret = 1 * 365;
        end
    end
end

