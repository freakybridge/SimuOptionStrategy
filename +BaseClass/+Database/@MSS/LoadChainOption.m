% Microsoft Sql Server / LoadChainOption
% v1.3.0.20220113.beta
%       �״μ���
function instru = LoadChainOption(obj, var, exc)
try
    % ���� / ����
    db = obj.db_instru;
    tb = obj.GetTableName(EnumType.Product.Option, var, EnumType.Exchange.ToEnum(exc));

    % ����
    sql = sprintf("SELECT [SYMBOL], [SEC_NAME], [EXCHANGE], [VARIETY], [UD_SYMBOL], [UD_PRODUCT], [UD_EXCHANGE], [CALL_OR_PUT], [STRIKE_TYPE], [STRIKE], [SIZE], [TICK_SIZE], [DLMONTH], [START_TRADE_DATE], [END_TRADE_DATE], [SETTLE_MODE], [LAST_UPDATE_DATE] FROM [%s].[dbo].[%s]  ORDER BY [SYMBOL]", ...
        db, tb);
    conn = obj.SelectConn(db);
    value = fetch(conn, sql);

catch
    warning("Fetching option chain ""%s"" failure, please check ...\r", tb);
    value = [];
end
instru = value;
end