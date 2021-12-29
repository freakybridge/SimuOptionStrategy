classdef Wind < BaseClass.DataSourceApi
    %WIND �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    properties (Access = private)
        api;
    end
    properties (Hidden)        
        exchanges;
    end
    
    methods
        % ���캯��
        function obj = Wind()
            %WIND ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.DataSourceApi();
            obj.api = windmatlab;
            obj.exchanges = containers.Map;
            obj.exchanges('sse') = 'SH';
            obj.exchanges('szse') = 'SZ';            
            disp('DataSource Wind Ready.');
        end
        
        % ��ȡ��Ȩ��������
        function md = FetchOptionMinData(obj, symb, exc, ts_s, ts_e, inv)
            exc = obj.exchanges(lower(exc));
            [md, code, ~, dt, errorid, ~] = obj.api.wsi([symb, '.', exc], 'open,high,low,close,amt,volume', ...
                datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), sprintf('BarSize=%i',  inv));
            
            if (errorid ~= 0)
                warning('Fetching option %s market data error, id %i, msg %s, please check.', code{:}, errorid, md{:});
                md = nan;
                return;
            end
            md = [dt, md];
        end
    end
    
    methods (Static)        
        % ��ȡapi����ʱ��
        function ret = FetchApiDateLimit()
            ret = 3 * 365;
        end
    end
end

