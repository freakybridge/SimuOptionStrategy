% ���ݶ˿�API
classdef DatabaseApi < handle    
    properties (Hidden)
        user;
        password;
        driver; 
        url;
        name;
    end
    properties
        conn;
    end
    
    methods
        % �˿ڳ�ʼ��
        function obj = DatabaseApi(name, user, pwd)
            obj.name = name;
            obj.user = user;
            obj.password = pwd;
            obj.driver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';
            obj.url = obj.ConfirmUrl();
            
            obj.On();
        end
        
        % ��
        function obj = On(obj)
            cConn = database(obj.name, obj.user, obj.password, obj.driver, [obj.url, obj.name]);
            if isopen(cConn)
                disp(['Database ', obj.name, ' log on success. ']);
                obj.conn = cConn;
            else
                disp(['Database ', obj.name, ' log on failure. ']);
                error(cConn.Message);
            end
        end
        
        % �ر�
        function obj = Off(obj)
            close(obj.conn);
            if ~isopen(obj.conn)
                disp(['Database ', obj.name, ' log off success. ']);
            else
                disp(['Database ', obj.name, ' log off failure. ']);
                error(cThis.Conn.Message);
            end
        end
    end
    
    methods (Access = private, Hidden, Static)
        % ȷ��url
        function ret = ConfirmUrl()
            [~, result] = dos('ipconfig');
            [~, loc(1)] = regexp(result, 'IPv4 ��ַ . . . . . . . . . . . . : ');
            loc(2) = regexp(result, '��������  . . . . . . . . . . . . : ');
            ip = result(loc(1) + 1 : loc(2) - 1);
            ip(isspace(ip)) = [];
            ret = ['jdbc:sqlserver://', ip, ':1433;;databaseName='];
        end
    end
end