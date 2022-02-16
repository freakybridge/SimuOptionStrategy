% Microsoft Sql Server��
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
%       2.�ع�����
% v1.2.0.20220105.beta
%       �״����
classdef MSS < BaseClass.Database.Database
    % MSS �˴���ʾ�йش����ժҪ
    % Microsoft Sql Server    
    properties (Constant)
        name char = 'Mss';
    end
    properties (Constant)
        lmt_insert int64 = 1000;
    end
    
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
                fprintf('Database [%s] log off success.\r', obj.name);
            else
                fprintf('Database [%s] log off failure.\r', obj.name);
                error(cThis.Conn.Message);
            end
        end

        % �������ݿ� / ��ȡ�˿� / ������ݿ� / �������ݿ�
        function Connect(obj, db)
            %  connect
            conn = database(db, obj.user, obj.password, obj.driver, sprintf('%s%s', obj.url, db));
            if isopen(conn)
                fprintf("Database [%s] log on success.\r", db);
            else
                fprintf("Database [%s] log on failure.\r", db);
                warning(conn.Message);
                return;
            end
            obj.conns(db) = conn;

            % tables buffer
            obj.tables(db) = obj.FetchAllTables(db);
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
            obj.CreateTableOverviews(db);
        end

        % ����
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
        
        % ������
        function CreateTbResDisp(~, ret, db, tb, msg)
            if (ret)
                fprintf("Table [%s]@[%s] created success.\r", tb, db);
            else
                error("Table [%s]@[%s]created failure. Msg: %s\r", tb, db, msg);
            end
        end
    end
    
    % ���󷽷�ʵ��
    methods
        % fetch sample asset overviews
        function views = LoadOverviews(obj, para)
            % generate db;
            if (isa(para, 'char') || isa(para, 'string'))
                db = char(para);
            elseif ismember('BaseClass.Asset.Asset', superclasses(para))
                db = obj.GetDbName(para);
            else
                error('Input error, please check.');
            end

            % fetch
            try
                tb = obj.tb_overviews;
                conn = obj.SelectConn(db);
                sql = sprintf("SELECT [TABLENAME],[TS_START],[TS_END],[COUNTS] FROM [%s].[dbo].[%s] ORDER BY [TABLENAME]", db, tb);
                views = fetch(conn, sql);
            catch
                views = table(categorical([]), [], [], [], 'VariableNames', {'TABLENAME', 'TS_START', 'TS_END', 'COUNTS'});
            end
        end
    end
    methods (Hidden)
        % ������Ȩ / �ڻ���Լ�б�
        ret = SaveChainOption(obj, var, exc, instrus);
        ret = SaveChainFuture(obj, var, exc, instrus);

        % ��ȡ��Ȩ / �ڻ���Լ�б�
        instru = LoadChainOption(obj, var, exc);
        instru = LoadChainFuture(obj, var, exc);              
        
        % ����K������
        ret = SaveBarMin(obj, asset, md);
        ret = SaveBarDayEtf(obj, asset, md);
        ret = SaveBarDayFuture(obj, asset, md);
        ret = SaveBarDayIndex(obj, asset, md);
        ret = SaveBarDayOption(obj, asset, md);

        % ��ȡK������
        md = LoadBarMin(obj, asset);
        md = LoadBarDayEtf(obj, asset);
        md = LoadBarDayFuture(obj, asset);
        md = LoadBarDayIndex(obj, asset);
        md = LoadBarDayOption(obj, asset);
                
        % ��ȡ ȫ�����ݿ� / ��ǰ�����б� / ��ȡԭʼ����
        ret = FetchAllDbs(obj);
        ret = FetchAllTables(obj, db);
        ret = FetchRawData(obj, db, tb);

        % Create Overviews
        function ret = CreateTableOverviews(obj, db)
             % no need to create
            if (strcmpi(db, obj.db_default) || strcmpi(db, obj.db_instru))
                ret = false;
                return;
            end

            % create
            conn = obj.SelectConn(db);
            tb = obj.tb_overviews;
            sql = sprintf("CREATE TABLE [%s](" ...
                + "[TABLENAME] [varchar](128) NOT NULL PRIMARY KEY, " ...
                + "[TS_START] [datetime] NULL, " ...
                + "[TS_END] [datetime] NULL, " ...
                + "[COUNTS] [int] NULL " ...
                + ")ON [PRIMARY];" ...
                + "CREATE INDEX [%s] ON [%s] ([SYMBOL] ASC);" ...
                , tb, obj.TableIndex(db, tb), tb);
            res = exec(conn, sql);

            if (~isempty(res.Cursor))
                ret = true;
            else
                ret = false;
            end
            obj.CreateTbResDisp(ret, db, tb, res.Message);
        end

        % Overviews Trigger
        function ret = CreateTriggerOverviews(obj, db, tb)
            conn = obj.SelectConn(db);
            tb_ov = obj.tb_overviews;
            tb_ins = tb;
            sql = sprintf("CREATE TRIGGER [dbo].[TriggerOverview_%s] ON [%s] FOR UPDATE, INSERT, DELETE " ...
                + " AS" ...
                + " BEGIN" ...
                + "     DECLARE @s datetime;" ...
                + "     DECLARE @e datetime;" ...
                + "     DECLARE @cnt int;" ...
                + "     SELECT @s = MIN(TIMESTAMP), @e = MAX(TIMESTAMP), @cnt = COUNT(*) FROM [%s];" ...
                + "     DELETE FROM [%s] WHERE [TABLENAME] = '%s';" ...
                + "     INSERT [%s] ([TABLENAME], [TS_START], [TS_END], [COUNTS]) VALUES ('%s', @s, @e, @cnt);" ...
                + " END", ...
                tb_ins, tb_ins, ...
                tb_ins, ...
                tb_ov, tb_ins, ...
                tb_ov, tb_ins ...
                );
            res = exec(conn, sql);

            if (~isempty(res.Cursor))
                ret = true;
            else
                ret = false;
            end
        end
        
    end
end

