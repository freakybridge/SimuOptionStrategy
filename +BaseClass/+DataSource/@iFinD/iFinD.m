% ����Դ�˿� iFinDApi
% v1.2.0.20220105.beta
%       �״����
classdef iFinD < BaseClass.DataSource.DataSource
    properties (Access = private)
        user;
        password;
        api;
    end
    properties (Hidden)        
        exchanges;
    end
    
    methods
        % ���캯��
        function obj = iFinD(ur, pwd)
            % iFinD ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.DataSource.DataSource();
            obj.user = ur;
            obj.password = pwd;
            THS_iFinDLogin(ur, pwd);
            
            obj.exchanges = containers.Map;
            obj.exchanges('sse') = 'SH';
            obj.exchanges('szse') = 'SZ';            
            disp('DataSource iFinD Ready.');
        end
        
        % ��ȡ��Ȩ��������
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
        % ��ȡapi����ʱ��
        function ret = FetchApiDateLimit()
            ret = 1 * 365;
        end
    end
end

