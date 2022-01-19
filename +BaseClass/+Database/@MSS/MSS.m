% Microsoft Sql Server类
% v1.3.0.20220113.beta
%       1.加入成员类型约束
%       2.重构方法
% v1.2.0.20220105.beta
%       首次添加
classdef MSS < BaseClass.Database.Database
    % MSS 此处显示有关此类的摘要
    % Microsoft Sql Server    
    properties (Constant)
        name char = 'Mss';
    end
    
    methods
        % 构造函数
        function obj = MSS(user, pwd)
            obj = obj@BaseClass.Database.Database(user, pwd, 'master');
            obj.driver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';
            obj.url = obj.ConfirmUrl();
            obj.Connect(obj.db_default);
        end
    end


    % 内部方法
    methods (Access = private, Hidden)
        % 确定url
        function ret = ConfirmUrl(~)
            [~, result] = dos('ipconfig');
            [~, loc(1)] = regexp(result, 'IPv4 地址 . . . . . . . . . . . . : ');
            loc(2) = regexp(result, '子网掩码  . . . . . . . . . . . . : ');
            ip = result(loc(1) + 1 : loc(2) - 1);
            ip(isspace(ip)) = [];
            ret = sprintf("jdbc:sqlserver://%s:1433;;databaseName=", ip);
        end

        % 关闭
        function obj = Off(obj)
            close(obj.conn);
            if ~isopen(obj.conn)
                disp(['Database ', obj.name, ' log off success. ']);
            else
                disp(['Database ', obj.name, ' log off failure. ']);
                error(cThis.Conn.Message);
            end
        end

        % 连接数据库 / 获取端口 / 检查数据库 / 创建数据库
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
        end

        % 检查表
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
        
        % 结果输出
        function CreateTbResDisp(~, ret, db, tb, msg)
            if (ret)
                fprintf("Table [%s]@[%s] created success.\r", tb, db);
            else
                error("Table [%s]@[%s]created failure. Msg: %s\r", tb, db, msg);
            end
        end
    end
    
    % 抽象方法实现
    methods (Hidden)
        % 保存期权 / 期货合约列表
        ret = SaveChainOption(obj, var, exc, instrus);
        ret = SaveChainFuture(obj, var, exc, instrus);

        % 获取期权 / 期货合约列表
        instru = LoadChainOption(obj, var, exc);
        instru = LoadChainFuture(obj, var, exc);
        
        % 建表
        ret = CreateTableInstru(obj, product);
        ret = CreateTableBarMin(obj, asset);
        ret = CreateTableBarDayEtf(obj, asset);
        ret = CreateTableBarDayFuture(obj, asset);
        ret = CreateTableBarDayIndex(obj, asset);
        ret = CreateTableBarDayOption(obj, asset);
        
        
        % 保存K线行情
        ret = SaveBarMin(obj, asset);
        ret = SaveBarDayEtf(obj, asset);
        ret = SaveBarDayFuture(obj, asset);
        ret = SaveBarDayIndex(obj, asset);
        ret = SaveBarDayOption(obj, asset);

        % 读取K线行情
        LoadBarMin(obj, asset);
        LoadBarDayEtf(obj, asset);
        LoadBarDayFuture(obj, asset);
        LoadBarDayIndex(obj, asset);
        LoadBarDayOption(obj, asset);
                
        % 读取 全部数据库 / 当前库所有表
        ret = FetchAllDbs(obj);
        ret = FetchAllTables(obj, db);
    end
end

