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
            [md, code, fields, times, errorid, reqid] = obj.api.wsi([symb, '.', exc], 'open,high,low,close,amt,volume,oi', ...
                datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), sprintf('BarSize=%i',  inv));
            
%         [w_wsi_data,w_wsi_codes,w_wsi_fields,w_wsi_times,w_wsi_errorid,w_wsi_reqid]=w.wsi('10003769.SH','open,high,low,close,amt,volume,oi','2021-12-24 09:30:00','2021-12-24 15:00:00','BarSize=5')
            md = 2;
        end
    end
end

