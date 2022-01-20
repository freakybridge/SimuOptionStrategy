% 510050 期权类
% v1.3.0.20220113.beta
%       1.加入成员类型约束
%       2.类成员重构
% v1.2.0.20220105.beta
%       首次添加
classdef (Sealed) SSE_510050 < BaseClass.Asset.Option.ETF 
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SSE;
        variety char = '510050';
        tradetimetable double = [[930, 1130]; [1300, 1500]];        
        tick_size double = 0.0001;
        date_ini char = '2015-02-09';
    end
        
    % 父类Option属性
    properties (Constant)
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.European;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
    end
    properties
        underlying = BaseClass.Asset.ETF.Instance.SSE_510050('5m');
    end    
    
    % 构造函数
    methods
        function obj = SSE_510050(varargin)
            obj = obj@BaseClass.Asset.Option.ETF(varargin{:});
        end
    end
    
end

