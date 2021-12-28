% 分解XCX OPTION DATA
function SplitXcxData(root_, pth_hm)
% 预处理
symb_dat_map = containers.Map;

% 路径配置
dir_raw = fullfile(root_, 'raw');
dir_buffer = fullfile(root_, 'buffer');
dir_final = fullfile(root_, 'final');

% 读取所有所有原始文件
LoadExcelRawData(dir_raw, dir_buffer);
file_dat_buffer = LoadBuffer(dir_buffer);

% 信息按代码存入缓存
symbols = unique(file_dat_buffer(:, 1));
for i = 1 : length(symbols)
    key = symbols(i);
    fprintf('Extracting option %i data, %i/%i, please wait ...\r', key, i, length(symbols));    
    
    loc = file_dat_buffer(:, 1) == key;
    tmp_dat = file_dat_buffer(loc, 2 : end);
    tmp_dat = tmp_dat(:, [1 : 5, 7, 6, 8]);
    
    key = num2str(key);
    if (symb_dat_map.isKey(key))
        symb_dat_map(key) = [symb_dat_map(key); tmp_dat];
    else
        symb_dat_map(key) = tmp_dat;
    end
    
    file_dat_buffer(loc, :) = [];
end

% 读取合约信息
instrus = Utility.ReadSheet(pth_hm, 'instrument');

% 按合约代码输出
symbols = symb_dat_map.keys();
for i = 1 : length(symbols)
    info = instrus(ismember(instrus(:, 1), symbols{i}), :);
    opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, pth_hm); 
    md = symb_dat_map(symbols{i});
    
    % 输出
    opt.MergeMarketData(md);
    opt.NewBarMarketData(5);
    opt.OutputMarketData(dir_final);
    fprintf('%s data saved, progress %i/%i, please wait ...\n', opt.symbol, i, length(symbols));
end

end

function LoadExcelRawData(dir_raw, dir_bf)
% 读取所有所有原始文件
files = dir(dir_raw);
files = files(~[files.isdir]);
Utility.CheckDirectory(dir_bf);

% 读取所有文件
for i = 1 : length(files)
    this_file = files(i);
    fprintf('Scanning file %s, %i/%i, please wait ...\r', this_file.name, i, length(files));
    [~, ~, dat] = xlsread(fullfile(this_file.folder, this_file.name));
    dat(1, :) = [];
    dat = dat(:, [1, 2, 4 : 9, 12]);
    
    symbols = cellfun(@(x) sscanf(x, 'OP%d'), dat(:, 1));
    timestamp = datenum(dat(:, 2));
    dat = [symbols, timestamp, cell2mat(dat(:, 3 : end))];
    save(fullfile(dir_bf, sprintf('%i.mat', i)), 'dat');
    clear dat;
end
end

function ret = LoadBuffer(dir_bf)
files= dir(dir_bf);
files = files(~[files.isdir]);
ret = [];

for i = 1 : length(files)
    this_file = files(i);
    tmp = load(fullfile(this_file.folder, this_file.name));
    ret = [ret; tmp.dat];
end
end
