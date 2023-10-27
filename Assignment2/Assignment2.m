classdef Assignment2 < handle
    properties (Access = private)
        GripperBase0;LeftHand;RightHand;robot;robot2;                      % Tag Name for 2 Robot Arms and Gripper
        Can;Can_vert;Can_transf;Cap;Cap_vert;Cap_transf;                   % Tag Name for Can And Cap
        qDest = [];                                                        % Joints Stage at destination
        qMatrix = [];matrix_signal;                                        % Matrix of Joints Stages - matrix_signal: 0 (Cant Found) - 1 (Found)
        collision_signal;                                                  % Signal for collision detection: 0 (Not Collided) - 1 (Collided)
        gripper_signal;                                                    % Signal for gripper stage: 0 (Close) - 1 (Open)
        object_pos;object_index;                                           % Position of each objects and current object index
        target_pos;destination_pos;target_ori                              % Position and Orientation of the current target
        can_attached;                                                      % Indicate the status of the current object which is grab by the Gripper or not (True - False)
        stop_signal = false;                                               % E-Stop Signal: true(Stop)-false(Run)
        handles;                                                           % Information Storage for the GUI
        cur_state;cur_step;                                                % Indicate the current stage and step
        smart_feature;                                                     % Develop feature (not User Friendly) - Used to enhance the smooth and precise of the robot movement
    end
    methods (Access = public)
        %% Open the GUI for the system
        function self = Assignment2()
            close all
            warning('off')
            self.RunGUI
        end
        %% Create Working Environment and Add Models
        % (description)
        function Add_models(self)
            Table = PlaceObject('Table.ply');
            Table_vertices = get(Table,'Vertices');
            transformedVerticesT = [Table_vertices,ones(size(Table_vertices,1),1)]*troty(-pi/2)'*transl(0,0,1.4)';
            set(Table,'Vertices',transformedVerticesT(:,1:3));

            self.object_pos = {[0.4,0.3,1.5];[0.5,0,1.5];[0.35,-0.3,1.5]};
            objectCap_pos = {[0.4,0.3,1.66];[0.5,0,1.66];[0.35,-0.3,1.66]};
            for index = 1: size(self.object_pos,1)
                self.Can{index} = PlaceObject('Canbody.ply');
                self.Can_vert{index} = get(self.Can{index},'Vertices');
                self.Can_transf{index} = [self.Can_vert{index},ones(size(self.Can_vert{index},1),1)]*trotx(-pi/2)*transl(self.object_pos{index})';
                set(self.Can{index},'Vertices',self.Can_transf{index}(:,1:3));

                self.Cap{index} = PlaceObject('CanCap.ply');
                self.Cap_vert{index} = get(self.Cap{index},'Vertices');
                self.Cap_transf{index} = [self.Cap_vert{index},ones(size(self.Cap_vert{index},1),1)]*trotx(-pi/2)*transl(objectCap_pos{index})';
                set(self.Cap{index},'Vertices',self.Cap_transf{index}(:,1:3));
            end

            surf([-2,-2;2,2],[-2,2;-2,2],[0,0;0,0],'CData',imread('concrete.jpg'),'FaceColor','texturemap','FaceLighting','none');
            surf([2,2;2,2],[-2,2;-2,2],[0,0;3,3],'CData',imread('Wall.jpg'),'FaceColor','texturemap');
            surf([-2,2;-2,2],[2,2;2,2],[0,0;3,3],'CData',imread('Wall.jpg'),'FaceColor','texturemap');

        end
        %% The Main Predefined Working Process
        % The UR3 will pick up a Can and pass it toward the Kuka.The Kuka
        % then opens the Cap and throw it to the bin. Then the UR3 pick up
        % the Can and pass it toward the customer's table.

        function ProcessingWork(self)
            fprintf('Start Working Process! \n ... ... ... \n ... ... ... \n ')
            self.destination_pos = {[-0.4,0,1.5];[-0.4,0,1.5];[-0.4,0,1.5];[0,0.3,1.6]};                        % The robot will go through each Can (defined as each stage)
            for index = self.cur_state:size(self.destination_pos,1)                                             % Each stage include 3 main step:
                self.object_index = index;                                                                      %  1) Go to the Can location, close the gripper and pick the Can up.
                for step = self.cur_step:3                                                                      %  2) Move it to the Kuka location. And wait for the Kuka to open the Cap.
                    cases = step;                                                                               %  3) Move the Can to the customer.
                    if index == size(self.destination_pos,1)                                                    % If all the Cans are opened and given to the customer. The UR3 will enter the rest stage (step 4).
                        cases = 4;
                    end                                                                                         % During this working process, the system will stop immediately if the E-stop button is pushed.
                    % Before stopping, the current stage and step will be saved to be used later.
                    switch cases
                        case 1
                            self.target_pos = self.object_pos{index};
                            self.target_pos(1) = self.target_pos(1) - 0.15;
                            self.target_ori = trotx(-pi/2)*troty(pi/2)*trotz(-pi/2);
                            self.matrix_signal = self.FindqMatrix;
                            self.run
                            self.gripper_signal = 0;
                            self.GripperControl
                        case 2
                            self.target_pos = self.destination_pos{index};
                            self.target_ori = trotx(-pi/2)*troty(-pi/2)*trotz(-pi/2);
                            self.matrix_signal = self.FindqMatrix;
                            self.can_attached = true;
                            self.run
                            self.OpenCap
                        case 3
                            self.target_pos = [-0.4 + index*0.2,-0.35,1.5];
                            self.target_ori = trotx(-pi/2)*troty(pi)*trotz(-pi/2);
                            self.matrix_signal = self.FindqMatrix;
                            self.run
                            self.gripper_signal = 1;
                            self.GripperControl
                            self.can_attached = false;
                        case 4
                            self.target_pos = self.destination_pos{index};
                            self.target_ori = trotx(-pi/2)*trotz(-pi/2);
                            self.matrix_signal = self.FindqMatrix;
                            self.run
                            self.handles.pb4.String = "!Finished Process!";
                            break
                    end
                    if self.stop_signal
                        break
                    end
                    self.handles.pb4.Value = self.handles.pb4.Value + 1;
                    self.handles.pb4.String = "Current State: " + num2str(self.handles.pb4.Value);
                    self.cur_step = 1;
                end
                if self.stop_signal
                    break
                end
            end
        end

        %% Find the Joints Stages Matrix to reach a goal
        % It takes the goal information from the source and run a process
        % to find the joints stages matrix to reach that goal. After
        % processing, the matrix_signal will be updated.

        function result = FindqMatrix(self)
            self.qMatrix = [];
            cur_object = self.target_pos;
            cur_pos = self.robot.model.fkine(self.robot.model.getpos).T;
            if (cur_pos(3,4) - 1.5) < 0.2
                cur_pos(3,4) = cur_pos(3,4) + 0.2;
            end
            Q_destination{2} = cur_pos;
            Q_destination{3} = transl(cur_object(1),cur_object(2),cur_object(3)+0.3)*self.target_ori;         % Move up 0.3m above the object to avoid collision. Then going down slowly.
            Q_destination{4} = transl(cur_object(1),cur_object(2),cur_object(3)+0.06)*self.target_ori;
            Q{1}=self.robot.model.getpos;
            Q{2}=[];
            Q{3}=[];
            Q{4}=[];
            % This process will use ikine function to find the q (joints stage) to reach a destination.
            if self.smart_feature                                                                             % The results can be different and depended significantly on the Initial Guess Q.
                Q_iniguess = randn(1000,6)*pi;                                                                % In order to have a smooth and precise movement, we need a good and pre-defined Initial Guess Q.
                Q_test=[];                                                                                    % For this task, an optimized initial guess has been created based on the smart_feature.
            else                                                                                              % Smart feature will create 1000 random joints stages for the ikine function and animate them.
                Q_iniguess = load("Initial_guess_Optimized.m");                                               % Then we can observe and choose the most optimal path based on the distance between 1 joints stages
            end                                                                                               % to another.The shortest path will be the fastest and most effective one.

            for pt = 2:4                                                                                      % Warning: The smart feature may affect the movement of the robot and create error. For that reason
                count = 1;                                                                                    % this feature will only be used by the develop person or the owner. It's not user friendly feature.
                while count < size(Q_iniguess,1)+1
                    Q{pt} = self.robot.model.ikine(Q_destination{pt},'q0',Q_iniguess(count,:),'mask',[1 1 1 1 1 1],'forceSln');
                    count = count + 1;
                    if ~size(Q{pt},1)
                        result = 0;
                    else
                        result = 1;
                    end
                    if result
                        for i= 1:6                                                                            % Check and modify to make sure the joints stage is in the qlim (-360 to 360 degree)
                            a = fix(Q{pt}(i)/(pi));
                            if (a<-1 || a>1)
                                Q{pt}(i) = Q{pt}(i) - a*2*pi;
                            end
                        end
                        self.qMatrix = [self.qMatrix;jtraj(Q{pt-1},Q{pt},200)];
                        self.collision_signal = self.CheckCollision;                                          % Check the collision of each joints stage in the matrix.
                        if self.collision_signal
                            self.qMatrix = self.qMatrix(1:(end-200),:);
                        else
                            if self.smart_feature
                                fprintf('The joint configuration at %s : ',num2str(pt-1));
                                disp(Q{pt});
                                Q_test = [Q{pt};Q_test];
                                save("Initial_guess.m","Q_test","-ascii");
                            end
                            break
                        end
                    end
                end
                if count >=size(Q_iniguess,1)
                    disp('Can not reach destination!!!');
                end
            end
        end
        %% Main Control for the system
        % When it's called, it will check the status of the Joints Stages
        % Matrix. If the matrix is existence, it will control the system
        % following the matrix. In addition, it's also check for the
        % gripper and Can signal simultaneously to animate the action of
        % grabbing and moving Cans.

        function run(self)
            if self.matrix_signal
                self.LeftHand.model.delay = 0;
                self.RightHand.model.delay = 0;
                self.robot.model.delay = 0;
                self.GripperBase0.model.delay = 0;
                for i=1:size(self.qMatrix,1)
                    if self.stop_signal
                        break
                    end
                    self.GripperBase0.model.base = self.robot.model.fkine(self.robot.model.getpos).T*transl(0,0,-0.01)*troty(pi);
                    self.LeftHand.model.base = self.GripperBase0.model.base.T*transl(0,0.015,-0.06)*troty(pi/2);
                    self.RightHand.model.base = self.GripperBase0.model.base.T*trotz(pi)*transl(0,0.015,-0.06)*troty(pi/2);
                    self.robot.model.animate(self.qMatrix(i,:));

                    % Moving the Gripper along with the robot.
                    self.GripperBase0.model.animate(0);
                    self.LeftHand.model.animate(self.LeftHand.model.getpos);
                    self.RightHand.model.animate(self.RightHand.model.getpos);

                    % If the current object is grabbed. Moving it with the gripper.
                    if self.can_attached
                        self.Can_transf{self.object_index} = [self.Can_vert{self.object_index},ones(size(self.Can_vert{self.object_index},1),1)]*trotz(pi/2)'*transl(0.06,0,-0.16)'*self.GripperBase0.model.base.T';
                        set(self.Can{self.object_index},'Vertices',self.Can_transf{self.object_index}(:,1:3))
                        if self.Cap{self.object_index}
                            self.Cap_transf{self.object_index} = [self.Cap_vert{self.object_index},ones(size(self.Cap_vert{self.object_index},1),1)]*trotz(pi/2)'*transl(-0.1,0,-0.16)'*self.GripperBase0.model.base.T';
                            set(self.Cap{self.object_index},'Vertices',self.Cap_transf{self.object_index}(:,1:3))
                        end
                    end
                    drawnow
                end
            end
        end
        %% Collision Detection
        % This process will take Joints Stages Matrix from the source and
        % check the collision with the surrounding environment including
        % the robot itself. Then output the result of the checking
        % (True-False)

        function result = CheckCollision(self)
            result = 0;
            for qIndex = 1:size(self.qMatrix,1)
                % Get the transform of every joint and gripper (i.e. start and end of every link)
                tr = GetLinkPoses(self.qMatrix(qIndex,:), self);
                tr(:,:,end+1) = self.robot.model.fkine(self.qMatrix(qIndex,:)).T*transl(0,0,0.15);

                % Go through each link and also each triangle face
                for i = 2 : size(tr,3)-1
                    vertOnPlane = [0,0,1.51];
                    faceNormals = [0,0,1];
                    [~,check] = LinePlaneIntersection(faceNormals,vertOnPlane,tr(1:3,4,i)',tr(1:3,4,i+1)');
                    if check == 1
                        result = result + 1;
                    end
                end
            end
        end
        %% Gripper Control
        % Control the Gripper based on gripper_signal
        % Signal = 1: Open || Signal = 0: Close

        function GripperControl(self)
            q_open =  [1.1345,0,0.6213];
            q_close = [0.6319, 0,1.1240];

            if self.gripper_signal
                q_gripper = jtraj(q_close,q_open,200);
            else
                q_gripper = jtraj(q_open,q_close,200);
            end
            for i = 1:200
                if self.stop_signal
                    break
                end
                self.LeftHand.model.animate(q_gripper(i,:));
                self.RightHand.model.animate(q_gripper(i,:));
                drawnow
            end
        end

        %% Open Cap
        % This is a Kuka process. The movement of the Kuka is predefined
        % which is opening the Cap and throwing it to other place.

        function OpenCap(self)
            q_matrix = {jtraj([-1.5708,-0.8659,0.8196,-1.7454,-1.6171,0.4636],[-1.5708,-0.4598,1.5083,-1.7461,-0.5224,0],200)...
                ;[repmat([-1.5708,-0.4598,1.5083,-1.7461,-0.5224],200,1),[0:8*pi/199:8*pi]']...
                ;jtraj([-1.5708,-0.4598,1.5083,-1.7461,-0.5224,8*pi],[-1.5708,-0.8659,0.8196,-1.7454,-1.6171,8*pi],200)...
                ;jtraj([-1.5708,-0.8659,0.8196,-1.7454,-1.6171,8*pi],[0,-0.8659,0.8196,-1.7454,-1.6171,8*pi],200)...
                ;jtraj([0,-0.8659,0.8196,-1.7454,-1.6171,8*pi],[-1.5708,-0.8659,0.8196,-1.7454,-1.6171,8*pi],200)};

            q_cap = [repmat([-0.8,0.4473],200,1),[2:-(0.51-self.object_index*0.01)/199:(1.49+self.object_index*0.01)]'];
            if ~self.stop_signal
            for index = 1:5
                for i = 1:200
                    if index == 3 || index == 4
                        self.Cap_transf{self.object_index} = [self.Cap_vert{self.object_index},ones(size(self.Cap_vert{self.object_index},1),1)]*trotx(pi/2)'*self.robot2.model.fkine(self.robot2.model.getpos).T';
                        set(self.Cap{self.object_index},'Vertices',self.Cap_transf{self.object_index}(:,1:3))
                    elseif index == 5
                        self.Cap_transf{self.object_index} = [self.Cap_vert{self.object_index},ones(size(self.Cap_vert{self.object_index},1),1)]*trotx(-pi/2)*transl(q_cap(i,:))';
                        set(self.Cap{self.object_index},'Vertices',self.Cap_transf{self.object_index}(:,1:3));
                    end
                    self.robot2.model.animate(q_matrix{index}(i,:))
                    drawnow
                end
            end
            end
            self.Cap{self.object_index} = 0;
        end

        %% Create Link Poses
        % This is a sub-process for the Collision Detection.
        % This process will create a transform which contains the
        % information of all Link Poses.

        function [ transforms ] = GetLinkPoses(q,self)
            links = self.robot.model.links;
            transforms = zeros(4, 4, length(links) + 1);
            transforms(:,:,1) = self.robot.model.base;

            for i = 1:length(links)
                L = links(1,i);

                current_transform = transforms(:,:, i);

                current_transform = current_transform * trotz(q(1,i) + L.offset) * ...
                    transl(0,0, L.d) * transl(L.a,0,0) * trotx(L.alpha);
                transforms(:,:,i + 1) = current_transform;
            end
        end

    end
    %% GUI SETTING
    % The main process takes responsible for the GUI of the system
    % It includes many sub-functions inside.

    methods (Access = protected)
        % Create GUI will all the buttons connecting to parameters from
        % the system source.

        function RunGUI(self)
            self.handles.fig = uifigure('Name','Can-Can Robot','position',[80 250 524 472]);
            self.handles.pb0 = uiswitch(self.handles.fig,'toggle','Position',[45 385 20 45],'Items',{'Off','On'},'Value',0,'ValueChangedFcn',@login_cb,'ItemsData',{0,1});
            self.handles.pb1 = uicontrol(self.handles.fig,'style','togglebutton','position',[35 179 108 41],'callback',@stop_cb,'string','Stop');
            self.handles.pb2 = uicontrol(self.handles.fig,'style','pushbutton','position',[35 249 108 41],'callback',@resume_cb,'string','Run');
            self.handles.pb3 = uicontrol(self.handles.fig,'style','pushbutton','position',[35 109 108 41],'callback',@logout_cb,'string','Log out');
            self.handles.pb4 = uicontrol(self.handles.fig,'style','edit','position',[111 333 304 118],'HorizontalAlignment','center','FontSize',14,'Value',1,'BackgroundColor','k');
            self.handles.pb5 = uilamp(self.handles.fig,'Color','r','Position',[449 405 46 46]);
            self.handles.pb6 = uicontrol(self.handles.fig,'style','pushbutton','position',[35 39 108 41],'callback',@control_cb,'string','Control Mode');
            guidata(self.handles.fig,self.handles);

            % Stop function sends signal to the system if being pushed
            function stop_cb(src,~)
                self.handles = guidata(src);
                self.stop_signal = self.handles.pb1.Value;
                % Send true signal if being pressed. Change the system
                % status to stop stage.
                if self.stop_signal
                    self.handles.pb4.String = "Emergency Stop!!!";
                    self.handles.pb5.Color = 'r';
                    % Send false signal if being released. Change the system
                    % status to ready stage.
                else
                    self.handles.pb4.String = "Preparing to resume the system!";
                    self.handles.pb5.Color = 'y';
                end
            end
            % Resume function reactivates the system if it's ready.
            function resume_cb(src,~)
                self.handles = guidata(src);
                % Reloading and calculating  the current stage and step.
                % Then reactivating the system. Change the system status
                % to run stage.
                if ~self.handles.pb1.Value
                    self.cur_state = fix(self.handles.pb4.Value/3) + 1;
                    if ~rem(self.handles.pb4.Value,2)
                        self.cur_step = 2;
                    else
                        self.cur_step = 1;
                    end
                    self.handles.pb4.String = "Current State: " + num2str(self.handles.pb4.Value);
                    self.handles.pb5.Color = 'g';
                    self.ProcessingWork
                else
                    self.handles.pb4.String = "Disengaging the E-stop button first!";
                end
            end
            
            % Login to the environment - Create Robot and add environment.
            function login_cb(~,~)
                if self.handles.pb0.Value
                    self.handles.pb4.BackgroundColor = 'w';
                    pause(1.5)
                    self.handles.pb4.String = "Logging into the system";
                    figure('Position',[900 70 900 900])
                    axis([-2 2 -2 2 -0.01 4])
                    view(15,25)
                    hold on
                    self.robot = UR3(transl(0,0,1.5));
                    self.robot2 = KukaKr3R540(transl(-0.95,0,1.5));
                    baseTr = self.robot.model.fkine(self.robot.model.getpos).T*transl(0,0,-0.01)*troty(pi);
                    self.GripperBase0 = GripperBase(baseTr);
                    GripperHand1 = self.GripperBase0.model.fkine(self.GripperBase0.model.getpos).T*transl(0,0.015,-0.06)*troty(pi/2);
                    GripperHand2 = self.GripperBase0.model.fkine(self.GripperBase0.model.getpos).T*trotz(pi)*transl(0,0.015,-0.06)*troty(pi/2);
                    self.LeftHand = GripperHand(GripperHand1);
                    self.RightHand = GripperHand(GripperHand2);
                    self.Add_models
                    self.handles.pb4.String ="Press The Run Button To Start";
                    pause(2)
                else
                    logout_cb
                    pause(1)
                    self.handles.pb4.String = "Logging out of the system";
                    pause(2)
                    self.handles.pb4.BackgroundColor = 'w';
                    pause(1.5)
                    close(self.handles.fig)
                end
            end
            
            % Open the control GUI for the robot UR3
            % It includes 6 joints stages and Cartesian values
            % (x,y,z,Y,P,R)
            function control_cb(~,~)
                cur_q = self.robot.model.getpos();
                cur_pos = self.robot.model.fkine(self.robot.model.getpos).T;
                cur_ori = tr2rpy(cur_pos,'deg','xyz');

                self.handles.fig2 = uifigure('Name','Control Mode','position',[80 250 524 472]);
                self.handles.sb0 = uicontrol(self.handles.fig2,'style','edit','position',[112 392 304 70],'HorizontalAlignment','center','FontSize',12,'BackgroundColor','w','Max',2,'Min',0);
                self.handles.sb1 = uislider(self.handles.fig2,"Position",[77 367 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb1.Value = cur_q(1);
                self.handles.sb2 = uislider(self.handles.fig2,"Position",[77 317 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb2.Value = cur_q(2);
                self.handles.sb3 = uislider(self.handles.fig2,"Position",[77 267 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb3.Value = cur_q(3);
                self.handles.sb4 = uislider(self.handles.fig2,"Position",[77 217 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb4.Value = cur_q(4);
                self.handles.sb5 = uislider(self.handles.fig2,"Position",[77 167 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb5.Value = cur_q(5);
                self.handles.sb6 = uislider(self.handles.fig2,"Position",[77 117 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb6.Value = cur_q(6);

                self.handles.sb7 = uispinner(self.handles.fig2,"Position",[448 344 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb7.Value = cur_pos(1,4);
                self.handles.sb8 = uispinner(self.handles.fig2,"Position",[448 279 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb8.Value = cur_pos(2,4);
                self.handles.sb9 = uispinner(self.handles.fig2,"Position",[448 214 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb9.Value = cur_pos(3,4);
                self.handles.sb10 = uispinner(self.handles.fig2,"Position",[448 149 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb10.Value = cur_ori(1);
                self.handles.sb11 = uispinner(self.handles.fig2,"Position",[448 84 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb11.Value = cur_ori(2);
                self.handles.sb12 = uispinner(self.handles.fig2,"Position",[448 19 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb12.Value = cur_ori(3);

                self.handles.sb13 = uicontrol(self.handles.fig2,'style','pushbutton','position',[44 22 116 35],'callback',@updatepose_cb,'string','Joints');
                self.handles.sb14 = uicontrol(self.handles.fig2,'style','pushbutton','position',[270 22 116 35],'callback',@updatepose2_cb,'string','Cartesian');

                self.handles.lb1 = uilabel(self.handles.fig2,"Position",[6 355 46 22],"Text",'Joint 1');
                self.handles.lb2 = uilabel(self.handles.fig2,"Position",[6 305 46 22],"Text",'Joint 2');
                self.handles.lb3 = uilabel(self.handles.fig2,"Position",[6 255 46 22],"Text",'Joint 3');
                self.handles.lb4 = uilabel(self.handles.fig2,"Position",[6 205 46 22],"Text",'Joint 4');
                self.handles.lb5 = uilabel(self.handles.fig2,"Position",[6 155 46 22],"Text",'Joint 5');
                self.handles.lb6 = uilabel(self.handles.fig2,"Position",[6 105 46 22],"Text",'Joint 6');
                self.handles.lb7 = uilabel(self.handles.fig2,"Position",[424 348 17 22],"Text",'x',"HorizontalAlignment",'center');
                self.handles.lb8 = uilabel(self.handles.fig2,"Position",[424 283 17 22],"Text",'y',"HorizontalAlignment",'center');
                self.handles.lb9 = uilabel(self.handles.fig2,"Position",[424 218 17 22],"Text",'z',"HorizontalAlignment",'center');
                self.handles.lb10 = uilabel(self.handles.fig2,"Position",[424 153 17 22],"Text",'R',"HorizontalAlignment",'center');
                self.handles.lb11 = uilabel(self.handles.fig2,"Position",[424 88 17 22],"Text",'P',"HorizontalAlignment",'center');
                self.handles.lb12 = uilabel(self.handles.fig2,"Position",[424 23 17 22],"Text",'Y',"HorizontalAlignment",'center');
                VRcontrol();
            end
            
            % Animate the robot based on the joints stage modification.
            function updatepose_cb(~,~)
                q_end = [self.handles.sb1.Value,self.handles.sb2.Value,self.handles.sb3.Value,self.handles.sb4.Value,self.handles.sb5.Value,self.handles.sb6.Value];
                self.qMatrix = jtraj(self.robot.model.getpos,q_end,10);
                result = self.CheckCollision;
                result =false;
                if ~result
                    self.matrix_signal = true;
                    self.run;
                    cur_pos = self.robot.model.fkine(self.robot.model.getpos).T;
                    cur_ori = tr2rpy(cur_pos,'deg','xyz');
                    self.handles.sb7.Value = cur_pos(1,4);
                    self.handles.sb8.Value = cur_pos(2,4);
                    self.handles.sb9.Value = cur_pos(3,4);
                    self.handles.sb10.Value = cur_ori(1);
                    self.handles.sb11.Value = cur_ori(2);
                    self.handles.sb12.Value = cur_ori(3);
                    A{1,1} = sprintf('x = %0.2f, y = %0.2f, z= %0.2f',cur_pos(1,4),cur_pos(2,4),cur_pos(3,4));
                    A{1,2} = sprintf('R= %0.2f, P= %0.2f, Y=%0.2f',cur_ori(1),cur_ori(2),cur_ori(3));
                    self.handles.sb0.String = {A{1,1},newline,A{1,2}};
                else
                    self.handles.sb0.String = {'Cant reach this pose';newline;'Please Change Your Option!'};
                end
            end

            % Animate the robot based on the Cartesian modification.
            function updatepose2_cb(~,~)
                self.target_pos = transl(self.handles.sb7.Value,self.handles.sb8.Value,self.handles.sb9.Value);
                self.target_ori = trotx(self.handles.sb10.Value*pi/180)*troty(self.handles.sb11.Value*pi/180)*trotz(self.handles.sb12.Value*pi/180);
                self.handles.sb0.String = 'Calculating ... ... Pls Wait';
                pause(0.5)
                Q_ini = load("Initial_guest_Optimized.m");
                for i = 1 : size(Q_ini,1)
                    q = self.robot.model.ikine(self.target_pos*self.target_ori,'q0',Q_ini(i,:),'mask',[1 1 1 1 1 1],'ForceSln');
                    if size(q,1)
                        break
                    end
                end
                if ~size(q,1)
                    self.handles.sb0.String = {'Cant reach this pose';newline;'Please Change Your Option!'};
                else
                    for i= 1:6
                        a = q(i)/(pi);
                        if (a<-1 || a>1)
                            q(i) = q(i) - fix(a)*2*pi;
                        end
                    end
                    self.handles.sb1.Value = q(1);
                    self.handles.sb2.Value = q(2);
                    self.handles.sb3.Value = q(3);
                    self.handles.sb4.Value = q(4);
                    self.handles.sb5.Value = q(5);
                    self.handles.sb6.Value = q(6);
                    updatepose_cb
                end

            end

            function VRcontrol(~,~)
                id = 1; % NOTE: may need to change if multiple joysticks present
                joy = vrjoystick(id);
                [~, buttons, ~] = read(joy);
                self.handles.buttons = buttons;
                % Create a loop to autimatically receive signal from controller.
                while(1)
                    % Read joystick buttons
                    [axes, buttons, ~] = read(joy);
                    self.handles.buttons = buttons;
                    self.handles.axes = axes;
                    step = 0.1;
                    % Update the data based on the signal from pressed
                    % buttons.
                    if abs(self.handles.axes(1) - 1) < 0.1
                        self.handles.sb1.Value = self.handles.sb1.Value + step;
                        updatepose_cb;
                    elseif abs(self.handles.axes(1) + 1) < 0.1
                        self.handles.sb1.Value = self.handles.sb1.Value - step;
                        updatepose_cb;
                    elseif abs(self.handles.axes(2) - 1) < 0.1
                        self.handles.sb2.Value = self.handles.sb2.Value + step;
                        updatepose_cb;
                    elseif abs(self.handles.axes(2) + 1) < 0.1
                        self.handles.sb2.Value = self.handles.sb2.Value - step;
                        updatepose_cb;
                    elseif abs(self.handles.axes(4) - 1) < 0.1
                        self.handles.sb3.Value = self.handles.sb3.Value + step;
                        updatepose_cb;
                    elseif abs(self.handles.axes(4) + 1) < 0.1
                        self.handles.sb3.Value = self.handles.sb3.Value - step;
                        updatepose_cb;
                    elseif abs(self.handles.axes(5) - 1) < 0.1
                        self.handles.sb4.Value = self.handles.sb4.Value + step;
                        updatepose_cb;
                    elseif abs(self.handles.axes(5) + 1) < 0.1
                        self.handles.sb4.Value = self.handles.sb4.Value - step;
                        updatepose_cb;
                    elseif abs(self.handles.axes(3) - 1) < 0.1
                        self.handles.sb5.Value = self.handles.sb5.Value + step;
                        updatepose_cb;
                    elseif abs(self.handles.axes(3) + 1) < 0.1
                        self.handles.sb5.Value = self.handles.sb5.Value - step;
                        updatepose_cb;
                    elseif self.handles.buttons(5)
                        self.handles.sb6.Value = self.handles.sb6.Value + step;
                        updatepose_cb;
                    elseif self.handles.buttons(6)
                        self.handles.sb6.Value = self.handles.sb6.Value - step;
                        updatepose_cb;
                    elseif self.handles.buttons(9)
                        self.gripper_signal = 0;
                        self.GripperControl
                    elseif self.handles.buttons(10)
                        self.gripper_signal = 1;
                        self.GripperControl
                    end
                    pause(0.05);
                    if buttons(7)
                        break
                    end
                end
            end

            function logout_cb(~,~)
                self.stop_signal = true;
                self.handles.pb4.String = "Goodbye! Thanks.";
                close all
            end
        end
    end
end
