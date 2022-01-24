% 从Excel读取期权列表
% v1.2.0.20220105.beta
%       首次添加
function instrus = LoadChainOption(~, var, exc, dir_)

% 预处理
dir_ = fullfile(dir_, 'INSTRUMENTS');
file = fullfile(dir_, sprintf('%s.xlsx', BaseClass.Database.Database.GetTableName(EnumType.Product.Option, var, exc)));
if (~exist(file, 'file'))
    warning("Can't find ""%s"", please check.", file);
    instrus = [];
    return;
end
try
    instrus = readtable(file);
catch
    warning("Excel %s reading error, please check.", file);
    instrus = [];
    return;
end

% 整理
instrus = UnifyInstruFmt(EnumType.Product.Option, instrus);
 
end

% 统一合约表格式
function ret = UnifyInstruFmt(pdt, ins)

switch pdt
    case EnumType.Product.Option
        ret = cell(size(ins));
        ret(:, 1) = cellfun(@(x) {Utility.ToString(x)}, ins.SYMBOL);
        ret(:, 2) = ins.SEC_NAME;
        ret(:, 3) = ins.EXCHANGE;
        ret(:, 4) = cellfun(@(x) {Utility.ToString(x)}, ins.VARIETY);
        ret(:, 5) = cellfun(@(x) {Utility.ToString(x)}, ins.UD_SYMBOL);
        ret(:, 6) = ins.UD_PRODUCT;
        ret(:, 7) = ins.UD_EXCHANGE;
        ret(:, 8) = ins.CALL_OR_PUT;
        ret(:, 9) = ins.STRIKE_TYPE;
        ret(:, 10) = num2cell(ins.STRIKE);
        ret(:, 11) = num2cell(ins.SIZE);
        ret(:, 12) = num2cell(ins.TICK_SIZE);
        ret(:, 13) = num2cell(ins.DLMONTH);
        ret(:, 14) = cellfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, ins.START_TRADE_DATE);
        ret(:, 15) = cellfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, ins.END_TRADE_DATE);
        ret(:, 16) = ins.SETTLE_MODE;
        ret(:, 17) = cellfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, ins.LAST_UPDATE_DATE);
        ret = cell2table(ret, 'VariableNames', ins.Properties.VariableNames);
        return;
              
    otherwise
        error("Unexpected ""product"" for transformation, pleas check.");
        
end
end