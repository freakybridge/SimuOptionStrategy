% CFFEX_IO 期权类
% v1.3.0.20220113.beta
%       1.首次添加
classdef (Sealed) CFFEX_IO < BaseClass.Asset.Option.Index
        
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CFFEX;
        variety char = 'IO';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.2;
        date_ini char = '2019-12-23';
    end
    
    % 父类Option属性
    properties (Constant)
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.European;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Cash;
    end
    
    % 构造函数
    methods
        function obj = CFFEX_IO(varargin)
            obj = obj@BaseClass.Asset.Option.Index('000300', EnumType.Exchange.SSE, varargin{:});
        end
    end
    
end
