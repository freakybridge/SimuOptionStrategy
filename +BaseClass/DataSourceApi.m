classdef DataSourceApi
    %DATASOURCEAPI �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    properties (Abstract)
        exchanges;
    end
        
    methods
        function obj = DataSourceApi()
            %DATASOURCEAPI ��������ʵ��
            %   �˴���ʾ��ϸ˵��
        end
    end
    
    
    methods (Abstract)
        % ��ȡ��Ȩ��������
        md = FetchOptionMinData(obj, symb, exc, ts_s, ts_e, inv);
    end
% [data,errorcode,time,indicators,thscode,errmsg,dataVol,datatype,perf]=THS_HF('10003769.SH','open;high;low;close;amount;volume;openInterest','Fill:Previous,Interval:5','2021-12-24 09:15:00','2021-12-24 15:15:00','format:table')    end
end

