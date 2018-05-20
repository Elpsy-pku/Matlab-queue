classdef Student
   properties(Access=public)
      Cheated          %�Ƿ���ӣ���ʼ����
      ChangeThreshold  %�ı���ֵ����ʼ����
      QuitThreshold    %�˳���ֵ����ʼ����
      RegretCost       %��ڳɱ�����ʼ����
      ObserveTime      %�۲�ʱ�䣺��ʼ����
      Tolerance        %���̶ȣ���ʼ����
      Nextcheated      %��һ���Ƿ���
      NextTolerance    %��һ�����̶�
      
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
              obj.NextTolerance=100000;
        end
   end
end