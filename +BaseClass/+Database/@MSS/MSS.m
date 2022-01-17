% Microsoft Sql Server��
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
%       2.�ع�����
% v1.2.0.20220105.beta
%       �״����
classdef MSS < BaseClass.Database.Database
    % MSS �˴���ʾ�йش����ժҪ
    % Microsoft Sql Server
    methods
        % ���캯��
        function obj = MSS(user, pwd)
            obj = obj@BaseClass.Database.Database(user, pwd, 'master');
            obj.driver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';
            obj.url = obj.ConfirmUrl();
            obj.Connect(obj.db_default);
        end
    end


    % �ڲ�����
    methods (Access = private, Hidden)
        % ȷ��url
        function ret = ConfirmUrl(~)
            [~, result] = dos('ipconfig');
            [~, loc(1)] = regexp(result, 'IPv4 ��ַ . . . . . . . . . . . . : ');
            loc(2) = regexp(result, '��������  . . . . . . . . . . . . : ');
            ip = result(loc(1) + 1 : loc(2) - 1);
            ip(isspace(ip)) = [];
            ret = sprintf("jdbc:sqlserver://%s:1433;;databaseName=", ip);
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

        % �������ݿ� / ��ȡ�˿� / ������ݿ� / �������ݿ�
        function Connect(obj, db)
            %  connect
            conn = database(db, obj.user, obj.password, obj.driver, sprintf('%s%s', obj.url, db));
            if isopen(conn)
                fprintf("Database ""%s"" log on success.\r", db);
            else
                fprintf("Database ""%s"" log on failure.\r", db);
                warning(conn.Message);
                return;
            end
            obj.conns(db) = conn;

            % tables buffer
            sql = 'SELECT NAME FROM SYSOBJECTS WHERE XTYPE=''U'' ORDER BY NAME';
            obj.tables(db) = table2cell(fetch(conn, sql));
        end
        function conn = SelectConn(obj, db)
            if (~CheckDatabase(obj, db))
                CreateDatabase(obj, SelectConn(obj, obj.db_default), db);
            end
            conn = obj.conns.at(db);
        end
        function ret = CheckDatabase(obj, db)
            if (obj.conns.isKey(db))
                ret = true;
            else
                ret = false;
            end
        end
        function ret = CreateDatabase(obj, conn, db)
            sql = sprintf("CREATE DATABASE ""%s""", db);
            res = exec(conn, sql);
            if (~isempty(res.Cursor))
                Connect(obj, db);
                ret = true;
            else
                ret = false;
                error("Create database %s error, msg: %, please check!", db, res.Message);
            end
        end

        % ���� / ������
        function ret = CheckTable(obj, db, tb)
            if (obj.tables.isKey(db))
                tmp = obj.tables.at(db);
                for i = 1 : length(tmp)
                    if (tmp{i} == tb)
                        ret = true;
                        return;
                    end
                end
                ret = false;
            else
                ret = false;
            end
        end
        ret = CreateTable(obj, conn, db, tb,  varargin);

    end
end

