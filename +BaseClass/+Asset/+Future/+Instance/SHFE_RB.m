% RB FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) SHFE_RB < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SHFE;
        variety char = 'RB';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 1;
        date_ini char = '2009/03/27';
    end
    
    % ���캯��
    methods
        function obj = SHFE_RB(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end