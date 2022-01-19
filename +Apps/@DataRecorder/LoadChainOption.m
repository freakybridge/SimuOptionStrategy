% ��Excel��ȡ��Ȩ�б�
% v1.2.0.20220105.beta
%       �״����
function instrus = LoadChainOption(~, var, exc, dir_)

% Ԥ����
file = fullfile(dir_, 'instruments-option.xlsx');
if (~exist(file, 'file'))
    warning("Can't find ""%s"", please check.", file);
    instrus = [];
    return;
end
try
    exc = EnumType.Exchange.ToEnum(exc);
    sheet = sprintf("%s-%s", var, EnumType.Exchange.ToString(exc));
    [~, ~, instrus] = xlsread(file, sheet);
catch
    warning("Excel %s reading error, please check.", file);
    instrus = [];
    return;
end

% ����
instrus = cell2table(instrus(2 : end, :), 'VariableNames', instrus(1, :));
instrus = UnifyInstruFmt(EnumType.Product.Option, instrus);
 
end

% ͳһ��Լ���ʽ
function ret = UnifyInstruFmt(pdt, instrus)

switch pdt
    case EnumType.Product.Option
        ret = cell(size(instrus));
        for i = 1 : size(instrus, 1)
            this = instrus(i, :);
            ret{i, 1} = Utility.ToString(this.SYMBOL);
            ret{i, 2} = this.SEC_NAME;
            ret{i, 3} = this.EXCHANGE{:};
            ret{i, 4} = Utility.ToString(this.VARIETY);
            ret{i, 5} = Utility.ToString(this.UD_SYMBOL);
            ret{i, 6} = this.UD_PRODUCT{:};
            ret{i, 7} = this.UD_EXCHANGE{:};
            ret{i, 8} = this.CALL_OR_PUT{:};
            ret{i, 9} = this.STRIKE_TYPE{:};
            ret{i, 10} = this.STRIKE;
            ret{i, 11} = this.SIZE;
            ret{i, 12} = this.TICK_SIZE;
            ret{i, 13} = this.DLMONTH;
            ret{i, 14} = datestr(this.START_TRADE_DATE, 'yyyy-mm-dd HH:MM');
            ret{i, 15} = datestr(this.END_TRADE_DATE, 'yyyy-mm-dd HH:MM');
            ret{i, 16} = this.SETTLE_MODE{:};
            ret{i, 17} = datestr(this.LAST_UPDATE_DATE, 'yyyy-mm-dd HH:MM');
        end
        ret = cell2table(ret, 'VariableNames', instrus.Properties.VariableNames);
        return;
        
    otherwise
        error("Unexpected ""product"" for transmission, pleas check.");
        
end
end