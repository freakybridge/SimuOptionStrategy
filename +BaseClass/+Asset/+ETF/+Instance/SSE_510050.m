% 510050 ETF类
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) SSE_510050 < BaseClass.Asset.ETF.ETF
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SSE;
        variety char = '510050';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.001;
        date_ini char = '2004/12/30';
    end
    
    % 父类ETF属性
    properties (Constant)
        divlst cell = [ ...
            {'2016/11/29'}, {0.053}; ...
            {'2017/11/28'}, {0.054}; ...
            {'2018/12/03'}, {0.049}; ...
            {'2019/12/02'}, {0.047}; ...
            {'2020/11/30'}, {0.051}; ...
            {'2021/11/29'}, {0.041}; ...
            ];
    end
    
    % 构造函数
    methods
        function obj = SSE_510050(varargin)
            obj = obj@BaseClass.Asset.ETF.ETF('510050', '华夏上证50ETF', varargin{:}, 100);
        end
    end
    
end

