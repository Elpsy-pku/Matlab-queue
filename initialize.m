clear;
clc;
students=3000;%����ѧ��
windows=10;   %���ٴ���
queues=10;    %���ٶ���
cheated_person_rates=0.1;
cheated_queue_rates=0.3;
basis_ChangeThreshold=2;
basis_LeaveThreshold=6; 
basis_observetime=1; %�۲���Щʱ��ɵõ����д��ڸ��Ե������ٶȵ�����
basis_tolerance=3;
mean_arrival_rate=150; %��
basis_service_rate=10.5;
basis_conflict_cost=6/basis_service_rate;
queue_limit = 100;
for i=1:windows
    mean_service_rate(i)=basis_service_rate*(0.75+0.5*rand());  %��ͬ���ڵķ���������
end

%��ʼ��
cheated_students_num=randperm(students);
cheated_students_num=cheated_students_num(1:students*cheated_person_rates);%���ɿ��ܲ���ߵı��
student(1,students)=Student();
for i=1:students
    student(i).Cheated=ismember(i,cheated_students_num);
    if student(i).Cheated==false
         student(i).Tolerance=floor(basis_tolerance*(1+0.1*randn()));
    end
    student(i).ChangeThreshold=basis_ChangeThreshold*(1+0.16*randn());
    student(i).QuitThreshold=basis_LeaveThreshold*(1+0.07*randn());
    student(i).RegretCost=1/basis_service_rate*(1+0.16*randn());
    student(i).ObserveTime=basis_observetime*(1+0.16*rand());
end

save('initialization');