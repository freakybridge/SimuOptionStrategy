classdef DataManger
    % FORMATTRANSFER �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        Property1
    end
    
    methods
        function obj = DataManger()
        end
        
    end
    
    methods (Static)
        ret = TransferTaobaoExcel(dir_hm, dir_tb, dir_sav);        
        
        ret = Database2MarketData();
        ret = DataSource2MarketData();
        md = Csv2MarketData(dir_in, opt);
        
        ret = MarketData2Csv(dir_out, opt, md);
        ret = MarketData2Database(md, user, password);
    end
end

