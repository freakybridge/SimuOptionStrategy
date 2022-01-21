% JM FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) DCE_JM < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.DCE;
        variety char = 'JM';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 0.5;
        date_ini char = '2013/03/22';
    end
    
    % ���캯��
    methods
        function obj = DCE_JM(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end