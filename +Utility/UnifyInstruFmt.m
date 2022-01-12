% 统一合约表格式
% v1.2.0.20220105.beta
%       首次添加
function ret = UnifyInstruFmt(pdt, instrus)

switch pdt
    case EnumType.Product.Option
        ret = cell(size(instrus));
        for i = 1 : size(instrus, 1)
            this = instrus(i, :);
            ret{i, 1} = Utility.Trans2Str(this.SYMBOL);
            ret{i, 2} = this.SEC_NAME;
            ret{i, 3} = this.EXCHANGE{:};
            ret{i, 4} = Utility.Trans2Str(this.VARIETY);
            ret{i, 5} = Utility.Trans2Str(this.UD_SYMBOL);
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
