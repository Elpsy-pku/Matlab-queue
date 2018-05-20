load('initialization')
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
                    %disp(['he is cheated and now at ',num2str(i),' ',num2str(j+1)]);
                    students_cheat=students_cheat+1;
                    doqueue=true; 
                    for q=j+1:queue_length(i)
                    %someonequeue
                        student(queue_member(i,q)).Bequeued=student(queue_member(i,q)).Bequeued+1;
                        if student(queue_member(i,q)).Bequeued>=student(queue_member(i,q)).Tolerance;
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
    student_inline=0;
    for i=1:windows
        student_inline=student_inline+queue_length(i);
        maxlength(i)=max(maxlength(i),queue_length(i));
    end
    maxstudent=max(maxstudent,student_inline);
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
    student_inline=0;
    for i=1:windows
        student_inline=student_inline+queue_length(i);
        maxlength(i)=max(maxlength(i),queue_length(i));
    end
    maxstudent=max(maxstudent,student_inline);  
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

figure,plot(Nowtime_sample(1:sample_point),students_arrived_sample(1:sample_point),'r.');hold on;
plot(Nowtime_sample(1:sample_point),students_leave_sample(1:sample_point),'y.');
plot(Nowtime_sample(1:sample_point),students_quit_sample(1:sample_point),'b.');
plot(Nowtime_sample(1:sample_point),student_inline_sample(1:sample_point),'g.');
plot(Nowtime_sample(1:sample_point),students_change_sample(1:sample_point),'k.');
legend('students arrived','students leave','students quit','students inqueue','students change','Location','East');
xlabel('time'),ylabel('人数')