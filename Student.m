classdef Student
   properties(Access=public)
      Cheated          %是否会插队：初始决定
      ChangeThreshold  %改变阈值：初始决定
      QuitThreshold    %退出阈值：初始决定
      RegretCost       %后悔成本：初始决定
      ObserveTime      %观察时间：初始决定
      Tolerance        %容忍度：初始决定
      Nextcheated      %下一轮是否插队
      NextTolerance    %下一轮容忍度
      
      %排在哪个队：进入食堂时决定，之后可能由changeLine更改
      Line             
      %前面排了多少人：getinQueue时决定，
      %之后可能由changeLine或someonequeue或someoneLeave更改
      Personbeforeline 
      %何时进入食堂：循环时随机生成
      EnterTime        
      %预计排队结束时间：getinQueue时决定，
      %之后可能由someonequeue或changeLine或someoneLeave更改
      PredictTime  
      %在某一窗口接受服务的时间，依窗口服务率的指数分布：
      %getinQueue时决定，changeLine更改    
      ServiceTime      
      %真实排队结束时间：getinQueue时决定，
      %之后可能由someonequeue或changeLine或someoneLeave更改
      RealTime         
       
      %是否已超出容忍度界限：由someonequeue更改
      Getangry
      %被插队次数：由someonequeue更改
      Bequeued        
      %是否进行了队伍变更：由changeLine更改
      Changed          
      %不满意度，排完队之后决定：
      %是总排队时间和总被插队次数的函数，由getSatisfaction更改
      UnSatisfaction   
      %是否已经离开：在排完队或放弃排队时更改
      Leaved
      %是否已经放弃排队：在放弃排队时更改
      Quited
   end
   
   
   methods
        function obj = Student()
              obj.Line = 0;
              obj.Bequeued = 0;
              obj.Leaved=false;
              obj.Changed=0;
              obj.Quited=false;
              obj.RegretCost=rand();
              obj.Getangry=0;
              obj.Tolerance=100000;
              obj.NextTolerance=100000;
        end
   end
end