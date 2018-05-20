clear;
clc;
students=3000;%多少学生
windows=10;   %多少窗口
queues=10;    %多少队伍

quit2cheat=0.1;
conflict2cheat=0.2;
conflict2uncheat=0.2;
conflict2tolerance=0.6;

cheated_person_rates=0.5;
cheated_queue_rates=0.15;
basis_ChangeThreshold=2;
basis_LeaveThreshold=6; 
basis_observetime=1; %观察这些时间可得到所有窗口各自的销售速度的期望
basis_tolerance=3;
mean_arrival_rate=150; %λ
basis_service_rate=10.5;
basis_conflict_cost=6/basis_service_rate;
queue_limit = 100;
for i=1:windows
    mean_service_rate(i)=basis_service_rate*(0.75+0.5*rand());  %不同窗口的服务率期望
end

%初始化
cheated_students_num=randperm(students);
cheated_students_num=cheated_students_num(1:students*cheated_person_rates);%生成可能插队者的编号
student(1,students)=Student();
for i=1:students
    student(i).Cheated=ismember(i,cheated_students_num);
    student(i).Nextcheated= student(i).Cheated;
    if student(i).Cheated==false
         student(i).Tolerance=floor(basis_tolerance*(1+0.1*randn()));
         student(i).NextTolerance=student(i).Tolerance
    end
    student(i).ChangeThreshold=basis_ChangeThreshold*(1+0.16*randn());
    student(i).QuitThreshold=basis_LeaveThreshold*(1+0.07*randn());
    student(i).RegretCost=1/basis_service_rate*(1+0.16*randn());
    student(i).ObserveTime=basis_observetime*(1+0.16*rand());
end

save('initialization');
