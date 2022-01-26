% Microsoft Sql Server / SaveChainOption
% v1.3.0.20220113.beta
%       首次加入
function ret = SaveChainOption(obj, var, exc, instrus)
% 预处理
if (isempty(instrus))
    ret = false;
    return;
end
db = obj.db_instru;
conn = obj.SelectConn(db);

% 检查表
tb = obj.GetTableName(EnumType.Product.Option, var, EnumType.Exchange.ToEnum(exc));
if (~obj.CheckTable(db, tb))
    CreateTable(obj, conn, db, tb);
end

% 整理入库合约
instrus = table2cell(instrus);
tbs = repmat({tb}, size(instrus, 1), 1);
instrus = [tbs, instrus(:, 1), tbs, instrus(:, 2 : end), instrus(:, 1), tbs, instrus]';

% 准备sql
sql = " IF EXISTS (SELECT * FROM [%s] WHERE [SYMBOL] = '%s') UPDATE [%s] SET [SEC_NAME] = '%s', [EXCHANGE] = '%s', [VARIETY] = '%s', [UD_SYMBOL] = '%s', [UD_PRODUCT] = '%s', [UD_EXCHANGE] = '%s', [CALL_OR_PUT] = '%s', [STRIKE_TYPE] = '%s', [STRIKE] = %f, [SIZE] = %f, [TICK_SIZE] = %f, [DLMONTH] = %i, [START_TRADE_DATE] = '%s', [END_TRADE_DATE] = '%s', [SETTLE_MODE] = '%s', [LAST_UPDATE_DATE] = '%s' WHERE [SYMBOL] = '%s' ELSE INSERT [%s]([SYMBOL], [SEC_NAME], [EXCHANGE], [VARIETY], [UD_SYMBOL], [UD_PRODUCT], [UD_EXCHANGE], [CALL_OR_PUT], [STRIKE_TYPE], [STRIKE], [SIZE], [TICK_SIZE], [DLMONTH], [START_TRADE_DATE], [END_TRADE_DATE], [SETTLE_MODE], [LAST_UPDATE_DATE]) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', %f, %f, %f, %i, '%s', '%s', '%s', '%s')";
sql = repmat(sql, 1, size(instrus, 2));
sql = [sql{:}];
sql = sprintf(sql, instrus{:});

% 入库
exec(conn, sql);
ret = true;

end


% 建表合约表
function ret = CreateTable(obj, conn, db, tb)
sql = sprintf("CREATE TABLE [%s](" ...
    + "[SYMBOL] [varchar](128) NOT NULL PRIMARY KEY, " ...
    + "[SEC_NAME] [varchar](128) NULL, " ...
    + "[EXCHANGE] [varchar](128) NULL, " ...
    + "[VARIETY] [varchar](128) NULL, " ...
    + "[UD_SYMBOL] [varchar](128) NULL, " ...
    + "[UD_PRODUCT] [varchar](128) NULL, " ...
    + "[UD_EXCHANGE] [varchar](128) NULL, " ...
    + "[CALL_OR_PUT] [varchar](128) NULL, " ...
    + "[STRIKE_TYPE] [varchar](128) NULL, " ...
    + "[STRIKE] [numeric](18, 4) NULL, " ...
    + "[SIZE] [numeric](18, 4) NULL, " ...
    + "[TICK_SIZE] [numeric](18, 4) NULL, " ...
    + "[DLMONTH] [integer] NULL, " ...
    + "[START_TRADE_DATE] [datetime] NULL, " ...
    + "[END_TRADE_DATE] [datetime] NULL, " ...
    + "[SETTLE_MODE] [varchar](128) NULL, " ...
    + "[LAST_UPDATE_DATE] [datetime] NULL" ...    
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