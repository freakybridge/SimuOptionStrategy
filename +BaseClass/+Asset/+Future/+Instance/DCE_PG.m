% PG FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) DCE_PG < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.DCE;
        variety char = 'PG';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 1;
        date_ini char = '2020-03-30';
    end
    
    % ���캯��
    methods
        function obj = DCE_PG(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end