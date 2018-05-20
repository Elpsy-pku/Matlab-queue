%统计参数
c=zeros(80,1); %插队者数目
cus=zeros(80,1);%插队者平均不满意度
ucus=zeros(80,1);%不插队者平均不满意度
awt=zeros(80,1);%平均等待时间
ct=zeros(80,1);%插队者平均等待时间
uct=zeros(80,1);%不插队者平均等待时间
aus=zeros(80,1);%平均不满意度
nowcheat=zeros(80,1);%插队者比率
average_tolerance=zeros(80,1);%不插队者平均容忍率
load('initialization');
for x=1:80
disp(x);
nowcheat(x)=0;
conflict2cheat=conflict2cheat+3*(mean(uct)-mean(ct));
conflict2uncheat=conflict2uncheat+3*(mean(ct)-mean(uct));
disp(conflict2cheat);
disp(conflict2uncheat);
for i=1:students
    student(i).Cheated=student(i).Nextcheated;
    student(i).Tolerance=student(i).NextTolerance;
    if(student(i).Cheated==true)
        nowcheat(x)=nowcheat(x)+1;
    end
     student(i).Line = 0;
     student(i).Bequeued = 0;
     student(i).Leaved=false;
     student(i).Changed=0;
     student(i).Quited=false;
     student(i).Getangry=0;      
end
cheated_person_rates=nowcheat(x)/students;
nowcheat(x)=cheated_person_rates;
disp(['now cheat rate',num2str(cheated_person_rates)]);
queue_limit=200;
students_arrived=0;    %到达人数
students_quit=0;       %退出（中途离开）人数
students_leave=0;      %接受完服务从窗口离开的人数
students_cheat=0;      %实际插队的人数
students_change=0;     %实际换队伍的人数
maxlength=zeros(queues,1);%所有队列曾达到的最大长度
student_inline=0;      %此时在排队的人数
maxstudent=0;          %同一时间进行排队的最大人数
average_wait_time=0;   %平均等待时间
average_unSatisfaction=0; %平均不满意度
sample_point=0;        %第几个采样点

temp=[];
queue_length=zeros(queues,1);
queue_member=zeros(queues,queue_limit);
Nowtime=0;
Mintime=0;%此时加入某个队伍能得到的最短期望排队时间
%用于画图
Nowtime_sample=zeros(2*students,1);
students_arrived_sample=zeros(2*students,1);
students_quit_sample=zeros(2*students,1);
students_leave_sample=zeros(2*students,1);
students_cheat_sample=zeros(2*students,1);
students_change_sample=zeros(2*students,1);
student_inline_sample=zeros(2*students,1);
maxlength_sample=zeros(2*students,queues);
average_wait_time_sample=zeros(2*students,1);
average_unSatisfaction_sample=zeros(2*students,1);

while(students_arrived<students) %不断有学生到来
    sample_point=sample_point+1;
    students_arrived= students_arrived+1;
    Nowtime=Nowtime+exprnd(1/mean_arrival_rate);
    Nowtime_sample(sample_point)=Nowtime;
    %该离开的人都离开，并且每个已在排队且观察了一段时间的人算一下是否要离开或换队
    for i=1:students_arrived-1 
        if Nowtime>=student(i).RealTime && (student(i).Leaved==false) %服务完了 
            %disp(['student ',num2str(i),' leaved']);
            students_leave= students_leave+1;
            student(i).Leaved=true;
            %getUnSatisfaction;
            student(i).UnSatisfaction=student(i).RealTime-student(i).EnterTime+(3/(mean_service_rate(student(i).Line)))*(student(i).Bequeued)+student(i).RegretCost*student(i).Changed+basis_conflict_cost*student(i).Getangry;
            average_unSatisfaction=average_unSatisfaction+student(i).UnSatisfaction;
            average_wait_time=average_wait_time+(student(i).RealTime-student(i).EnterTime);
            queue_length(student(i).Line)=queue_length(student(i).Line)-1;
            queue_member(student(i).Line,1:queue_limit-1)=queue_member(student(i).Line,2:queue_limit);
            for j=1:queue_length(student(i).Line)
                student(queue_member(student(i).Line,j)).Personbeforeline=student(queue_member(student(i).Line,j)).Personbeforeline-1;
            end
        end
    end
    for i=1:students_arrived-1 
        if Nowtime>=student(i).EnterTime+student(i).ObserveTime && student(i).Leaved==false %队伍中的人通过比较可能后悔
            [minr,index]=min((queue_length+1)'./mean_service_rate);
            minr=queue_length(index);
            if minr==0
                Mintime=Nowtime+1./(mean_service_rate(index));
            else
                Mintime=student(queue_member(index,minr)).PredictTime+(1/(mean_service_rate(index)));
            end
            oldline=student(i).Line;
            %离开一队去另一队
            if student(i).PredictTime>student(i).ChangeThreshold +Mintime
                for j=student(i).Personbeforeline+2:queue_length(oldline)
                    %someoneLeave
                    numb=queue_member(oldline,j);
                    student(numb).Personbeforeline=student(numb).Personbeforeline-1;
                    student(numb).PredictTime=student(numb).PredictTime-1/mean_service_rate(student(numb).Line);
                    student(numb).RealTime=student(numb).RealTime-student(i).ServiceTime;
                end
                queue_length(oldline)=queue_length(oldline)-1;
                queue_member(oldline,student(i).Personbeforeline+1:queue_length(oldline)+1)=queue_member(oldline,student(i).Personbeforeline+2:queue_length(oldline)+2);
                %changeLine
                students_change=students_change+1;
                student(i).Line=index;
                student(i).Changed=student(i).Changed+1;
                student(i).Personbeforeline=minr;
                student(i).ServiceTime=exprnd(1/mean_service_rate(student(i).Line));
                if minr==0
                    student(i).PredictTime=Nowtime+1/mean_service_rate(student(i).Line);
                    student(i).RealTime=Nowtime+student(i).ServiceTime;
                else
                    student(i).PredictTime=student(queue_member(index,minr)).PredictTime+1/mean_service_rate(student(i).Line);
                    student(i).RealTime=student(queue_member(index,minr)).RealTime+student(i).ServiceTime;
                end
                queue_length(index)=minr+1;
                queue_member(index,minr+1)=i;
            end
            %离开食堂
            if student(i).PredictTime>student(i).QuitThreshold +Nowtime
                if student(i).Line~=oldline
                    students_change=students_change-1;
                end
                student(i).Changed=1;
                student(i).Quited=true;
                students_quit=students_quit+1;
                student(i).Leaved=true;
                student(i).UnSatisfaction=Nowtime-student(i).EnterTime+(3/(mean_service_rate(student(i).Line)))*(student(i).Bequeued)+2*student(i).RegretCost+basis_conflict_cost*student(i).Getangry;
                average_unSatisfaction=average_unSatisfaction+student(i).UnSatisfaction;
                for j=student(i).Personbeforeline+2:queue_length(student(i).Line)
                    %someoneLeave
                    numb=queue_member(student(i).Line,j);
                    student(numb).Personbeforeline=student(numb).Personbeforeline-1;
                    student(numb).PredictTime=student(numb).PredictTime-1/mean_service_rate(student(numb).Line);
                    student(numb).RealTime=student(numb).RealTime-student(i).ServiceTime;
                end
                queue_length(student(i).Line)=queue_length(student(i).Line)-1;
                queue_member(student(i).Line,student(i).Personbeforeline+1:queue_length(student(i).Line)+1)=queue_member(student(i).Line,student(i).Personbeforeline+2:queue_length(student(i).Line)+2);
            end
        end
    end
    %进入队伍时只能依据队伍长度
    student(students_arrived).EnterTime=Nowtime;
    [minr,index]=min(queue_length);
    doqueue=false;
    conflict=false;
    %如果是插队者并且起了插队的念头现在去排到某个前面的那个插队者后面是有利的，则去插队
    if student(students_arrived).Cheated == 1 && rand()<=cheated_queue_rates
        for i=1:windows
            for j=1:minr-1
                k=queue_member(i,j);
                if student(k).Cheated==1
                    students_cheat=students_cheat+1;
                    doqueue=true; 
                    for q=j+1:queue_length(i)
                    %someonequeue
                        student(queue_member(i,q)).Bequeued=student(queue_member(i,q)).Bequeued+1;
                        if student(queue_member(i,q)).Bequeued>=student(queue_member(i,q)).Tolerance
                            doqueue=false;
                            conflict=true;
                            student(queue_member(i,q)).Getangry=1;
                            student(students_arrived).Getangry=1;
                        end
                    end
                    if conflict==true
                        break;
                    end
                    student(students_arrived).Personbeforeline=j;
                    student(students_arrived).Line=i;
                    student(students_arrived).ServiceTime=exprnd(1/mean_service_rate(i));
                    student(students_arrived).PredictTime=student(k).PredictTime+1/mean_service_rate(i);
                    student(students_arrived).RealTime=student(k).RealTime+student(students_arrived).ServiceTime;
                    for q=j+1:queue_length(i)
                    %someonequeue
                        student(queue_member(i,q)).Personbeforeline=student(queue_member(i,q)).Personbeforeline+1;
                        student(queue_member(i,q)).PredictTime=student(queue_member(i,q)).PredictTime+1/mean_service_rate(i);
                        student(queue_member(i,q)).RealTime=student(students_arrived).ServiceTime+student(queue_member(i,q)).RealTime;
                    end
                    
                    queue_length(i)=queue_length(i)+1;
                    queue_member(i,j+2:queue_length(i))=queue_member(i,j+1:queue_length(i)-1);
                    queue_member(i,j+1)=students_arrived;
                    break
                end
            end
            if doqueue==true || conflict==true
                break;
            end
        end
    end
    if doqueue==false %getinQueue
    	student(students_arrived).Line=index;
        student(students_arrived).Personbeforeline=minr;
        %disp(['he is in ',num2str(index),' ',num2str(minr+1)]);
        student(students_arrived).ServiceTime=exprnd(1/mean_service_rate(student(students_arrived).Line));
        if minr==0
            student(students_arrived).PredictTime=Nowtime+1/mean_service_rate(student(students_arrived).Line);
            student(students_arrived).RealTime=Nowtime+student(students_arrived).ServiceTime;
        else
            student(students_arrived).PredictTime=student(queue_member(index,minr)).PredictTime+1/mean_service_rate(student(students_arrived).Line);
            student(students_arrived).RealTime=student(queue_member(index,minr)).RealTime+student(students_arrived).ServiceTime;
        end  
        queue_length(index)=queue_length(index)+1;
        queue_member(index,queue_length(index))=students_arrived;
    end
    %disp(['quit one: ',num2str(students_quit),'    leave one: ',num2str(students_leave),'   cheat one: ',num2str(students_cheat),'   change one: ',num2str(students_change)]),
    student_inline=0;
    for i=1:windows
        student_inline=student_inline+queue_length(i);
        maxlength(i)=max(maxlength(i),queue_length(i));
    end
    maxstudent=max(maxstudent,student_inline);
    %disp(['student_inline:',num2str(student_inline),'  maxlength:',num2str(maxlength'),'  maxstudent:',num2str(maxstudent),' averge_wait_time:',num2str(average_wait_time/students_leave),' averge_unSatisfaction:',num2str(average_unSatisfaction/students_leave)]);
    %disp(queue_length')
    students_arrived_sample(sample_point)=students_arrived;
    students_quit_sample(sample_point)=students_quit;
    students_leave_sample(sample_point)=students_leave;
    students_cheat_sample(sample_point)=students_cheat;
    students_change_sample(sample_point)=students_change;
    student_inline_sample(sample_point)=student_inline;
    maxlength_sample(sample_point,:)=maxlength;
    average_wait_time_sample(sample_point)=average_wait_time/students_leave;
    average_unSatisfaction_sample(sample_point)=average_unSatisfaction/students_leave;
end

while(students_leave+students_quit<students) %没人来了，队伍还在排
    sample_point=sample_point+1;
    Nowtime=Nowtime+exprnd(1/mean_arrival_rate);
    Nowtime_sample(sample_point)=Nowtime;
    %disp(['time:',num2str(Nowtime)]);
    %该离开的人都离开，并且每个已在排队且观察完了的人算一下是否要离开或换队
    for i=1:students_arrived
        if Nowtime>=student(i).RealTime && student(i).Leaved==false%服务完了 
            %disp(['student ',num2str(i),' leaved']);
            students_leave= students_leave+1;
            student(i).Leaved=true;
            %getUnSatisfaction;
            student(i).UnSatisfaction=student(i).RealTime-student(i).EnterTime+(3/(mean_service_rate(student(i).Line)))*(student(i).Bequeued)+student(i).RegretCost*student(i).Changed+basis_conflict_cost*student(i).Getangry;
            average_unSatisfaction=average_unSatisfaction+student(i).UnSatisfaction;
            average_wait_time=average_wait_time+(student(i).RealTime-student(i).EnterTime);
            queue_length(student(i).Line)=queue_length(student(i).Line)-1;
            queue_member(student(i).Line,1:queue_limit-1)=queue_member(student(i).Line,2:queue_limit);
            for j=1:queue_length(student(i).Line)
                student(queue_member(student(i).Line,j)).Personbeforeline=student(queue_member(student(i).Line,j)).Personbeforeline-1;
            end
        end
    end
    for i=1:students_arrived
        if Nowtime>=student(i).EnterTime+student(i).ObserveTime&& student(i).Leaved==false
            [minr,index]=min((queue_length+1)'./mean_service_rate);
            minr=queue_length(index);
            if minr==0
                Mintime=Nowtime+1./(mean_service_rate(index));
            else
                Mintime=student(queue_member(index,minr)).PredictTime+(1/(mean_service_rate(index)));
            end
            oldline=student(i).Line;
            %离开一队去另一队
            if student(i).PredictTime>student(i).ChangeThreshold +Mintime
                %disp(['student ',num2str(i),' change from ',num2str(oldline),' to ',num2str(index)]);
                for j=student(i).Personbeforeline+2:queue_length(oldline)
                    %someoneLeave
                    numb=queue_member(oldline,j);
                    student(numb).Personbeforeline=student(numb).Personbeforeline-1;
                    student(numb).PredictTime=student(numb).PredictTime-1/mean_service_rate(student(numb).Line);
                    student(numb).RealTime=student(numb).RealTime-student(i).ServiceTime;
                end
                queue_length(oldline)=queue_length(oldline)-1;
                %disp([i,student(i).Personbeforeline])
                queue_member(oldline,student(i).Personbeforeline+1:queue_length(oldline)+1)=queue_member(oldline,student(i).Personbeforeline+2:queue_length(oldline)+2);
                %changeLine
                students_change=students_change+1;
                student(i).Changed=1;
                student(i).Line=index;
                student(i).Personbeforeline=minr;
                student(i).ServiceTime=exprnd(1/mean_service_rate(student(i).Line));
                if minr==0
                    student(i).PredictTime=Nowtime+1/mean_service_rate(student(i).Line);
                    student(i).RealTime=Nowtime+student(i).ServiceTime;
                else
                    student(i).PredictTime=student(queue_member(index,minr)).PredictTime+1/mean_service_rate(student(i).Line);
                    student(i).RealTime=student(queue_member(index,minr)).RealTime+student(i).ServiceTime;
                end
                queue_length(index)=minr+1;
                queue_member(index,minr+1)=i;
            end
            %离开食堂
            if student(i).PredictTime>student(i).QuitThreshold +Nowtime
                if student(i).Line~=oldline
                    students_change=students_change-1;
                end
                student(i).Changed=1;
                student(i).Quited=true;
                students_quit=students_quit+1;
                student(i).UnSatisfaction=Nowtime-student(i).EnterTime+(3/(mean_service_rate(student(i).Line)))*(student(i).Bequeued)+2*student(i).RegretCost+basis_conflict_cost*student(i).Getangry;
                average_unSatisfaction=average_unSatisfaction+student(i).UnSatisfaction;
                student(i).Leaved=true;
                for j=student(i).Personbeforeline+2:queue_length(student(i).Line)
                    %someoneLeave
                    numb=queue_member(student(i).Line,j);
                    student(numb).Personbeforeline=student(numb).Personbeforeline-1;
                    student(numb).PredictTime=student(numb).PredictTime-1/mean_service_rate(student(numb).Line);
                    student(numb).RealTime=student(numb).RealTime-student(i).ServiceTime;
                end
                queue_length(student(i).Line)=queue_length(student(i).Line)-1;
                queue_member(student(i).Line,student(i).Personbeforeline+1:queue_length(student(i).Line)+1)=queue_member(student(i).Line,student(i).Personbeforeline+2:queue_length(student(i).Line)+2);
            end
        end
    end
%     disp(['quit one: ',num2str(students_quit),'    leave one: ',num2str(students_leave),'   cheat one: ',num2str(students_cheat),'   change one: ',num2str(students_change)]),
    student_inline=0;
    for i=1:windows
        student_inline=student_inline+queue_length(i);
        maxlength(i)=max(maxlength(i),queue_length(i));
    end
    maxstudent=max(maxstudent,student_inline);
%     disp(['student_inline:',num2str(student_inline),'  maxlength:',num2str(maxlength'),'  maxstudent:',num2str(maxstudent),' averge_wait_time:',num2str(average_wait_time/students_leave),' averge_unSatisfaction:',num2str(average_unSatisfaction/(students_leave+students_quit))]);
%     disp(queue_length')
%     disp(queue_member(:,1:7)')  
    students_arrived_sample(sample_point)=students_arrived;
    students_quit_sample(sample_point)=students_quit;
    students_leave_sample(sample_point)=students_leave;
    students_cheat_sample(sample_point)=students_cheat;
    students_change_sample(sample_point)=students_change;
    student_inline_sample(sample_point)=student_inline;
    maxlength_sample(sample_point,:)=maxlength;
    average_wait_time_sample(sample_point)=average_wait_time/students_leave;
    average_unSatisfaction_sample(sample_point)=average_unSatisfaction/(students_leave+students_quit);
end

%插队者与不插队者可能相互转化，并且容忍度可能有变化
for i=1:students
    if student(i).Quited==true && rand()<=quit2cheat
        student(i).Nextcheated=true;
        student(i).NextTolerance=10000;
    end
    if student(i).Getangry==1 && student(i).Cheated==true && rand()<=conflict2uncheat
        student(i).Nextcheated=false;
        student(i).NextTolerance=floor(basis_tolerance*(1+0.1*randn()));
    end
    if student(i).Getangry==1 && student(i).Cheated==false
        if rand()<=conflict2cheat
            student(i).Nextcheated=true;
            student(i).NextTolerance=10000;
        elseif rand()>=1-conflict2tolerance && student(i).NextTolerance>0
            student(i).NextTolerance=student(i). NextTolerance-1;
        end
    end
end
start=0;
for i=1:students
    if students_leave_sample(i)>0
        start=i;
        break
    end
end
cheat_unSatisfaction=0;
uncheat_unSatisfaction=0;
cheat_time=0;
uncheat_time=0;
cheat_coflict_count=0;
uncheat_coflict_count=0;
cou=0;
cl=0;
average_tolerance(x)=0;
for i=1:students
    if student(i).Cheated==true
        cheat_unSatisfaction=cheat_unSatisfaction+student(i).UnSatisfaction;
        if student(i).Getangry==1
            cheat_coflict_count=cheat_coflict_count+1;
        end
        if student(i).Quited==false
            cheat_time=cheat_time+student(i).RealTime-student(i).EnterTime;
            cl=cl+1;
        end
        cou=cou+1;
    else
        average_tolerance(x)=average_tolerance(x)+student(i).Tolerance;
        uncheat_unSatisfaction=uncheat_unSatisfaction+student(i).UnSatisfaction;
        if student(i).Getangry==1
            uncheat_coflict_count=uncheat_coflict_count+1;
        end
    end
end
average_tolerance(x)=average_tolerance(x)/(students-students*cheated_person_rates);
c(x)=students_cheat;
cus(x)=cheat_unSatisfaction/(students*cheated_person_rates);
ucus(x)=uncheat_unSatisfaction/(students-students*cheated_person_rates);
awt(x)=average_wait_time/students_leave;
ct(x)=cheat_time/cl;
uct(x)=(average_wait_time-cheat_time)/(students_leave-cl);
aus(x)=average_unSatisfaction/students;
disp(['cheatperson',num2str(students_cheat),'aus',num2str(aus(x)),'cus',num2str(cheat_unSatisfaction/(students*cheated_person_rates)),'ucus',num2str(uncheat_unSatisfaction/(students-students*cheated_person_rates))]);
disp(['awt',num2str(awt(x)),'ct',num2str(ct(x)),'uct',num2str(uct(x))]);
disp(['quit rate:',num2str(students_quit/students),' maaxlength of queue',num2str(max(maxlength)),'average tolerance',num2str(average_tolerance(x))]);
end