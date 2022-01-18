% 从csv读取行情
% v1.3.0.20220113.beta
%       Csv操作独立
% v1.2.0.20220105.beta
%       首次添加
function LoadMdViaCsv(obj, asset, dir_csv)
obj.er.LoadMarketData(asset, dir_csv);
end