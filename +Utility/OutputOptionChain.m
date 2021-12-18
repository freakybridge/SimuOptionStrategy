% 将期权链输出至目标文件
function OutputOptionChain(pth_tar, db_user, db_pwd)
% 读取已有期权链
chain_1 = FetchOptionChain('option_510050_sh', db_user, db_pwd);
chain_2 = FetchOptionChain('option_510300_sh', db_user, db_pwd);
chain = [chain_1; chain_2];

% 整理
header = {'SYMBOL', 'UNDERLYING', 'EXPIRE', 'CALL_OR_PUT', 'STRIKE', 'UNIT',  'LISTED_DATE'};
output = [{chain.code}', {chain.underlying}', {chain.expire_date}', {chain.call_or_put}', {chain.exercise_price}', {chain.contract_unit_ini}', {chain.listed_date}'];
for i = 1 : size(output, 1)
    this = output(i, :);
    this{1} = this{1}(1 : strfind(this{1}, '.') - 1);
    
    switch lower(this{2})
        case '510050.sh'
            val = '50etf';
        case '510300.sh'
            val = '300etf';
        otherwise
            error('Unrecognised underlying');
    end
    this{2} = val;
    
    switch this{4}
        case 1
            val = 'c';
        case -1
            val = 'p';
        otherwise
            error('Unrecognised option direction');
    end
    this{4} = val;
    
    tmp = this{3};
    tmp = datestr(datenum(num2str(tmp), 'yyyymmdd') + 15/24, 'yyyy-mm-dd HH:MM');
    this{3} = tmp;    
    
    tmp = this{7};
    tmp = datestr(datenum(num2str(tmp), 'yyyymmdd') + 0/24, 'yyyy-mm-dd HH:MM');
    this{7} = tmp;
    output(i, :) = this;
end
output = [header; output];

% 检查路径
if (~isfolder(pth_tar))
    error('target path error, please check !');
end

xlswrite(fullfile(pth_tar, 'movelist.xlsx'), output, 'instrument');

% % 删除已有sheet
% path_ = pth_tar;
% file_ = 'movelist.xlsx';
% sheet_ = 'instrument';
% objExcel = actxserver('Excel.Application');
% objExcel.Workbooks.Open(fullfile(path_, file_)); % Full path is necessary!
% 
% try
%      objExcel.ActiveWorkbook.Worksheets.Item(sheet_).Delete;
% catch
%     error('Excel Server launch failure');
% end
% % Save, close and clean up.
% objExcel.ActiveWorkbook.Save;
% objExcel.ActiveWorkbook.Close;
% objExcel.Quit;
% objExcel.delete;


end



function chain = FetchOptionChain(db_nm, db_user, db_pwd)
% 获取api
api = BaseClass.DatabaseApi(db_nm, db_user, db_pwd);

% 下载option chain，此部分无修改
sql_string = ['SELECT * FROM ', db_nm, '.[dbo].[CodeList] ORDER BY wind_code'];
setdbprefs('DataReturnFormat', 'CellArray');
chain = table2cell(fetch(api.conn, sql_string));
chain(:, end) = [];
api.Off();

% 数字化所有日期
switch lower(db_nm)
    case {'option_510050_sh', ...
            'option_510300_sh', ...
            'option_159919_sz', ...
            'option_io_cfe'}
        chain(:, 1) = chain(:, 15);
        chain(:, [9, 15]) = [];
    otherwise
end
col = [9, 10, 11, 12];
for i = 1 : length(col)
    chain(:, col(i)) = num2cell(str2double(cellstr(datestr(chain(:, col(i)), 'yyyymmdd'))));
end

% struct化
fields = lower({ ...
    'wind_code', ...
    'sec_name', ...
    'option_mark_code', ...
    'option_type', ...
    'call_or_put', ...
    'exercise_mode', ...
    'exercise_price', ...
    'contract_unit_ini', ...
    'listed_date', ...
    'expire_date', ...
    'exercise_date', ...
    'settle_date', ...
    'settle_mode', ...
    'db', ...
    });
chain = cell2struct(chain, fields, 2);

% 写入字段 limit_month
temp = num2cell(floor([chain.expire_date] / 100));
[chain.limit_month] = temp{:};

% 数字化期权类型字段
loc_call = strcmpi({chain.call_or_put}, '认购');
loc_put = strcmpi({chain.call_or_put}, '认沽');
[chain(loc_call).call_or_put] = deal(1);
[chain(loc_put).call_or_put] = deal(-1);

% 删除无意义字段(db) / 修改字段(wind_code, sec_name, option_mark_code)
chain = rmfield(chain, 'db');
[chain.code] = chain.wind_code;
chain = rmfield(chain, 'wind_code');
[chain.comment] = chain.sec_name;
chain = rmfield(chain, 'sec_name');
[chain.underlying] = chain.option_mark_code;
chain = rmfield(chain, 'option_mark_code');
end