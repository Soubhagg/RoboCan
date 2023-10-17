classdef Assignment2 < handle    properties (Access = private)        GripperBase1;LeftHand;RightHand;        robot;Can;Can_vert;Can_transf;        qDest = [];        qMatrix = [];matrix_signal;        collision_signal;gripper_signal;        object_pos;object_index;target_pos;destination_pos;target_ori        drop_signal;can_attached;        smart_feature;        stop_signal = 0;    end    methods (Access = public)        function self = Assignment2()            %            close all            warning('off')            figure            axis([-2 2 -2 2 -0.01 4])            view(-13,14)            hold on            self.robot = UR3(transl(0,0,1.5));            baseTr = self.robot.model.fkine(self.robot.model.getpos).T*transl(0,0,-0.01)*troty(pi);            self.GripperBase1 = GripperBase(baseTr);            GripperHand1 = self.GripperBase1.model.fkine(self.GripperBase1.model.getpos).T*transl(0,0.015,-0.06)*troty(pi/2);            GripperHand2 = self.GripperBase1.model.fkine(self.GripperBase1.model.getpos).T*trotz(pi)*transl(0,0.015,-0.06)*troty(pi/2);            self.LeftHand = GripperHand(GripperHand1);            self.RightHand = GripperHand(GripperHand2);            self.Add_models            pause(2)            self.RunGUI            self.smart_feature = false;            self.ProcessingWork        end        %% Working Process        function ProcessingWork(self)            self.destination_pos = {[-0.4,0.2,1.5];[-0.4,0,1.5];[-0.4,-0.2,1.5];[0,0.3,1.6]};            for index = 1:size(self.destination_pos,1)                self.object_index = index;                for step = 1:2                    if self.stop_signal                        break                    end                    cases = step;                    if index == size(self.destination_pos,1)                        cases = 3;                    end                    switch cases                        case 1                            self.target_pos = self.object_pos{index};                            self.target_pos(1) = self.target_pos(1) - 0.15;                            self.target_ori = trotx(-pi/2)*troty(pi/2)*trotz(-pi/2);                            self.matrix_signal = self.FindqMatrix;                            self.run                            self.gripper_signal = 0;                            self.GripperControl                            self.can_attached = true;                        case 2                            self.target_pos = self.destination_pos{index};                            self.target_ori = trotx(-pi/2)*troty(-pi/2)*trotz(-pi/2);                            self.matrix_signal = self.FindqMatrix;                            self.run                            self.gripper_signal = 1;                            self.GripperControl                            self.can_attached = false;                        case 3                            self.target_pos = self.destination_pos{index};                            self.target_ori = trotx(-pi/2)*trotz(-pi/2);                            self.matrix_signal = self.FindqMatrix;                            self.run                            break                    end                end            end        end        %% Add table        function Add_models(self)            Table = PlaceObject('Table.ply');            Table_vertices = get(Table,'Vertices');            transformedVerticesT = [Table_vertices,ones(size(Table_vertices,1),1)]*troty(-pi/2)'*transl(0,0,1.4)';            set(Table,'Vertices',transformedVerticesT(:,1:3));            % Add cans            self.object_pos = {[0.4,0.3,1.5];[0.4,0,1.5];[0.4,-0.3,1.5]};            for index = 1: size(self.object_pos,1)                self.Can{index} = PlaceObject('Canbody2.ply');                self.Can_vert{index} = get(self.Can{index},'Vertices');                self.Can_transf{index} = [self.Can_vert{index},ones(size(self.Can_vert{index},1),1)]*trotx(-pi/2)*transl(self.object_pos{index})';                set(self.Can{index},'Vertices',self.Can_transf{index}(:,1:3));            end            surf([-2,-2;2,2],[-2,2;-2,2],[0,0;0,0],'CData',imread('concrete.jpg'),'FaceColor','texturemap','FaceLighting','none');            surf([2,2;2,2],[-2,2;-2,2],[0,0;3,3],'CData',imread('Wall.jpg'),'FaceColor','texturemap');            surf([-2,2;-2,2],[2,2;2,2],[0,0;3,3],'CData',imread('Wall.jpg'),'FaceColor','texturemap');        end        %% Test Movement        function run(self)            if self.matrix_signal                self.LeftHand.model.delay = 0;                self.RightHand.model.delay = 0;                self.robot.model.delay = 0;                self.GripperBase1.model.delay = 0;                for i=1:size(self.qMatrix,1)                    if self.stop_signal                        break                    end                    self.GripperBase1.model.base = self.robot.model.fkine(self.robot.model.getpos).T*transl(0,0,-0.01)*troty(pi);                    self.LeftHand.model.base = self.GripperBase1.model.base.T*transl(0,0.015,-0.06)*troty(pi/2);                    self.RightHand.model.base = self.GripperBase1.model.base.T*trotz(pi)*transl(0,0.015,-0.06)*troty(pi/2);                    self.robot.model.animate(self.qMatrix(i,:));                    self.GripperBase1.model.animate(0);                    self.LeftHand.model.animate(self.LeftHand.model.getpos);                    self.RightHand.model.animate(self.RightHand.model.getpos);                    if self.can_attached                        self.Can_transf{self.object_index} = [self.Can_vert{self.object_index},ones(size(self.Can_vert{self.object_index},1),1)]*trotz(pi/2)'*transl(0.12,0,-0.16)'*self.GripperBase1.model.base.T';                        set(self.Can{self.object_index},'Vertices',self.Can_transf{self.object_index}(:,1:3))                    end                    drawnow                end            end        end        %% Gripper Control        % Signal = 1: Open || Signal = 0: Close        function GripperControl(self)            q_open =  [1.1345,0,0.6213];            q_close = [0.6319, 0,1.1240];            if self.gripper_signal                q_gripper = jtraj(q_close,q_open,200);            else                q_gripper = jtraj(q_open,q_close,200);            end            for i = 1:200                if self.stop_signal                    break                end                self.LeftHand.model.animate(q_gripper(i,:));                self.RightHand.model.animate(q_gripper(i,:));                drawnow            end        end        %%        function result = FindqMatrix(self)            self.qMatrix = [];            cur_object = self.target_pos;            cur_pos = self.robot.model.fkine(self.robot.model.getpos).T;            cur_pos(3,4) = cur_pos(3,4) + 0.15;            Q_destination{2} = cur_pos;            Q_destination{3} = transl(cur_object(1),cur_object(2),cur_object(3)+0.3)*self.target_ori;            Q_destination{4} = transl(cur_object(1),cur_object(2),cur_object(3)+0.12)*self.target_ori;            Q{1}=self.robot.model.getpos;            Q{2}=[];            Q{3}=[];            Q{4}=[];            if self.smart_feature                Q_iniguest = randn(1000,6)*pi;                Q_test=[];            else                Q_iniguest = load("Initial_guest_Optimized.m");            end            for pt = 2:4                count = 1;                while count < size(Q_iniguest,1)+1                    Q{pt} = self.robot.model.ikine(Q_destination{pt},'q0',Q_iniguest(count,:),'mask',[1 1 1 1 1 1],'forceSln');                    count = count + 1;                    if ~size(Q{pt},1)                        result = 0;                    else                        result = 1;                    end                    if result                        for i= 1:6                            a = fix(Q{pt}(i)/(pi));                            if (a<-1 || a>1)                                Q{pt}(i) = Q{pt}(i) - a*2*pi;                            end                        end                        self.qMatrix = [self.qMatrix;jtraj(Q{pt-1},Q{pt},200)];                        self.collision_signal = self.CheckCollision;                        if self.collision_signal                            self.qMatrix = self.qMatrix(1:(end-200),:);                        else                            if self.smart_feature                                fprintf('The joint configuration at %s : ',num2str(pt-1));                                disp(Q{pt});                                Q_test = [Q{pt};Q_test];                                save("Initial_guest.m","Q_test","-ascii");                            end                            break                        end                    end                end                if count >=size(Q_iniguest,1)                    disp('Can not reach destination!!!');                end            end        end        %%        function result = CheckCollision(self)            result = 0;            for qIndex = 1:size(self.qMatrix,1)                % Get the transform of every joint (i.e. start and end of every link)                tr = GetLinkPoses(self.qMatrix(qIndex,:), self);                % Go through each link and also each triangle face                for i = 2 : size(tr,3)-1                    vertOnPlane = [0,0,1.55];                    faceNormals = [0,0,1];                    [~,check] = LinePlaneIntersection(faceNormals,vertOnPlane,tr(1:3,4,i)',tr(1:3,4,i+1)');                    if check == 1                        result = result + 1;                    end                end            end        end        %%        function [ transforms ] = GetLinkPoses(q,self)            links = self.robot.model.links;            transforms = zeros(4, 4, length(links) + 1);            transforms(:,:,1) = self.robot.model.base;            for i = 1:length(links)                L = links(1,i);                current_transform = transforms(:,:, i);                current_transform = current_transform * trotz(q(1,i) + L.offset) * ...                    transl(0,0, L.d) * transl(L.a,0,0) * trotx(L.alpha);                transforms(:,:,i + 1) = current_transform;            end        end    end    %% GUI SETTING    methods (Access = protected)        function RunGUI(self)            handles.fig = figure('position',[1 1 360 740]);            handles.pb = uicontrol('style','pushbutton','position',[114 612 133 70],'callback',@stop_cb,'string','Stop');            guidata(handles.fig,handles);            function stop_cb(~,~)                self.stop_signal = 1;                disp("Emergency Stop!!!")            end        end    endend