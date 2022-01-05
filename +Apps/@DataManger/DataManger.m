classdef DataManger
    % FORMATTRANSFER 此处显示有关此类的摘要
    %   此处显示详细说明
    
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

