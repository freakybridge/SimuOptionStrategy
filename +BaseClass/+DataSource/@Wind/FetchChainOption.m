% Wind ��ȡ��Ȩ��Լ�б�
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, ins] = FetchChainOption(obj, opt_s, ins_local)
% ��ȡ��������յ�
[date_s, date_e] = obj.GetChainUpdateSE(opt_s, ins_local);

% ����
exc_ud = obj.exchanges(opt_s.GetUnderExchange());
exc_opt = lower(Utility.ToString(opt_s.exchange));
str = sprintf('startdate=%s;enddate=%s;exchange=%s;windcode=%s.%s;status=all;field=wind_code,sec_name,call_or_put,exercise_price,contract_unit,listed_date,expire_date', ...
    date_s, date_e, exc_opt, opt_s.variety, exc_ud);
[ins, ~, ~, ~, obj.err.code, ~] = obj.api.wset('optioncontractbasicinfo', str);

% �������
if (obj.err.code)
    obj.err.msg = ins{:};
    obj.DispErr('Fetching option chain failure');
    ins = ins_local;
    is_err = true;
    
else
    if isa(ins, 'cell')
        % �����º�Լ���ϲ����غ�Լ
        % ��������Ϣ
        ins(strcmpi(ins(:, 3), '�Ϲ�'), 3) = deal({'Call'});
        ins(strcmpi(ins(:, 3), '�Ϲ�'), 3) = deal({'Put'});
        ins(:, 6) = cellstr(datestr(Utility.DatetimeOffset(datenum(ins(:, 6)), opt_s.tradetimetable(1)), 'yyyy-mm-dd HH:MM'));
        ins(:, 7) = cellstr(datestr(Utility.DatetimeOffset(datenum(ins(:, 7)), opt_s.tradetimetable(end)), 'yyyy-mm-dd HH:MM'));
        ins(:, 8) = num2cell(str2double(cellstr(datestr(ins(:, 7), 'yyyymm'))));
        
        % ��ȫ��Ϣ
        exc = upper(Utility.ToString(opt_s.exchange));
        var = char(opt_s.variety);
        ud_symb = char(opt_s.GetUnderSymbol());
        ud_product = upper(char(opt_s.GetUnderProduct()));
        ud_exc = upper(char(opt_s.GetUnderExchange()));
        striketype = Utility.InitCapital(Utility.ToString(opt_s.strike_type));
        ticksz = opt_s.tick_size;
        sttmode = Utility.InitCapital(Utility.ToString(opt_s.settle_mode));
        upd_time = datestr(now(), 'yyyy-mm-dd HH:MM');
        info = {exc, var, ud_symb, ud_product, ud_exc,  striketype, ticksz, sttmode, upd_time};
        info = repmat(info, size(ins, 1), 1);
        
        ins = [ins(:, 1 : 2), info(:, 1 : 5), ins(:, 3), info(:, 6), ins(:, 4 : 5), info(:, 7), ins(:, [8, 6, 7]), info(:, 8 : 9)];
        ins = cell2table(ins, 'VariableNames', {'SYMBOL','SEC_NAME','EXCHANGE','VARIETY','UD_SYMBOL','UD_PRODUCT','UD_EXCHANGE','CALL_OR_PUT','STRIKE_TYPE','STRIKE','SIZE','TICK_SIZE','DLMONTH','START_TRADE_DATE','END_TRADE_DATE','SETTLE_MODE','LAST_UPDATE_DATE'});
        
        % �ϲ�
        if (~isempty(ins_local))
            [~, loc] = intersect(ins_local(:, 1), ins(:, 1));
            ins_local(loc, :) = [];
            ins = [ins_local; ins];
        end
        ins = sortrows(ins, 1);
        
    else
        % �����º�Լ
        ins = ins_local;
    end
    is_err = false;
end
end
