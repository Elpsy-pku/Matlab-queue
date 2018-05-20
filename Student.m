classdef Student
   properties(Access=public)
      Cheated          %�Ƿ���ӣ���ʼ����
      ChangeThreshold  %�ı���ֵ����ʼ����
      QuitThreshold    %�˳���ֵ����ʼ����
      RegretCost       %��ڳɱ�����ʼ����
      ObserveTime      %�۲�ʱ�䣺��ʼ����
      Tolerance        %���̶ȣ���ʼ����
       
      %�����ĸ��ӣ�����ʳ��ʱ������֮�������changeLine����
      Line             
      %ǰ�����˶����ˣ�getinQueueʱ������
      %֮�������changeLine��someonequeue��someoneLeave����
      Personbeforeline 
      %��ʱ����ʳ�ã�ѭ��ʱ�������
      EnterTime        
      %Ԥ���Ŷӽ���ʱ�䣺getinQueueʱ������
      %֮�������someonequeue��changeLine��someoneLeave����
      PredictTime  
      %��ĳһ���ڽ��ܷ����ʱ�䣬�����ڷ����ʵ�ָ���ֲ���
      %getinQueueʱ������changeLine����    
      ServiceTime      
      %��ʵ�Ŷӽ���ʱ�䣺getinQueueʱ������
      %֮�������someonequeue��changeLine��someoneLeave����
      RealTime         
       
      %�Ƿ��ѳ������̶Ƚ��ޣ���someonequeue����
      Getangry
      %����Ӵ�������someonequeue����
      Bequeued        
      %�Ƿ�����˶���������changeLine����
      Changed          
      %������ȣ������֮�������
      %�����Ŷ�ʱ����ܱ���Ӵ����ĺ�������getSatisfaction����
      UnSatisfaction   
      %�Ƿ��Ѿ��뿪��������ӻ�����Ŷ�ʱ����
      Leaved
      %�Ƿ��Ѿ������Ŷӣ��ڷ����Ŷ�ʱ����
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
%             obj.QuitThreshold = QuitThreshold;
        end
        
        function getSatisfaction(obj,mean_service_time)
              obj.Satisfaction=1/(obj.RealTime+3*mean_service_time*obj.Bequeued);
        end
        
        function getinQueue(obj,minr,index,Nowtime)
            obj.Line=index;
            obj.Personbeforeline=minr;
            obj.ServiceTime=exprnd(mean_service_rate(obj.Line));
            if minr==0
                obj.PredictTime=Nowtime+1/mean_service_rate(obj.Line);
                obj.RealTime=Nowtime+obj.ServiceTime;
            else
                obj.PredictTime=student(queue_member(index,minr)).PredictTime+1/mean_service_rate(obj.Line);
                obj.RealTime=student(queue_member(index,minr)).RealTime+1/mean_service_rate(obj.Line);+obj.ServiceTime;
            end
        end
        
        function changeLine(obj,minr,index)
            obj.Line=index;
            obj.Personbeforeline=minr;
            obj.ServiceTime=exprnd(mean_service_rate(obj.Line));
            if minr==0
                obj.PredictTime=Nowtime+1/mean_service_rate(obj.Line);
                obj.RealTime=Nowtime+obj.ServiceTime;
            else
                obj.PredictTime=student(queue_member(index,minr)).PredictTime+1/mean_service_rate(obj.Line);
                obj.RealTime=student(queue_member(index,minr)).RealTime+obj.ServiceTime;
            end
            
        end
        
        function someoneLeave(obj,leaveone)
            obj.Personbeforeline=obj.Personbeforeline-1;
            obj.PredictTime=obj.PredictTime-1/mean_service_rate(obj.Line);
            obj.RealTime=obj.RealTime-student(leaveone).ServiceTime;
        end
        
        function someonequeue(obj,cheatedone)
            obj.Personbeforeline=obj.Personbeforeline+1;
            obj.Bequeued=obj.Bequeued+1;
            obj.PredictTime=obj.PredictTime+1/mean_service_rate(obj.Line);
            obj.RealTime=student(cheatedone).ServiceTime+obj.RealTime;
        end
        
   end
end