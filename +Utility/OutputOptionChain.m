% 将期权链输出至目标文件
function OutputOptionChain(pth_tar, db_user, db_pwd)
% 读取已有期权链
chain_1 = BaseClass.DatabaseApi.FetchOptionChain('option_510050_sh', db_user, db_pwd);
chain_2 = BaseClass.DatabaseApi.FetchOptionChain('option_510300_sh', db_user, db_pwd);
chain = [chain_1; chain_2];
[chain.exchange] = deal('SSE');

% 整理
header = {'SYMBOL', 'EXCHANGE', 'UNDERLYING', 'EXPIRE', 'CALL_OR_PUT', 'STRIKE', 'UNIT',  'LISTED_DATE'};
output = [{chain.code}', {chain.exchange}', {chain.underlying}', {chain.expire_date}', {chain.call_or_put}', {chain.exercise_price}', {chain.contract_unit_ini}', {chain.listed_date}'];
for i = 1 : size(output, 1)
    this = output(i, :);
    this{1} = this{1}(1 : strfind(this{1}, '.') - 1);
    
    switch lower(this{3})
        case '510050.sh'
            val = '50etf';
        case '510300.sh'
            val = '300etf';
        otherwise
            error('Unrecognised underlying');
    end
    this{3} = val;
    
    switch this{5}
        case 1
            val = 'c';
        case -1
            val = 'p';
        otherwise
            error('Unrecognised option direction');
    end
    this{5} = val;
    
    tmp = this{4};
    tmp = datestr(datenum(num2str(tmp), 'yyyymmdd') + 15/24, 'yyyy-mm-dd HH:MM');
    this{4} = tmp;    
    
    tmp = this{8};
    tmp = datestr(datenum(num2str(tmp), 'yyyymmdd') + 0/24, 'yyyy-mm-dd HH:MM');
    this{8} = tmp;
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


