%% Lab 2 Robocan Assignment
close all
clc

%% Log




%% Environment Creation

% % Add table
%             Table = PlaceObject('Table.ply');
%             Table_vertices = get(Table,'Vertices');
%             transformedVerticesT = [Table_vertices,ones(size(Table_vertices,1),1)]*troty(-pi/2)'*transl(0,0,1.4)';
%             set(Table,'Vertices',transformedVerticesT(:,1:3));
% % Add cans
% 
%             Can1 = PlaceObject('Canbody.ply');
%             Can1_vertices = get(Can1,'Vertices');
%             Can1_transformedVerticesT = [Can1_vertices,ones(size(Can1_vertices,1),1)]*trotx(-pi/2)*transl(0.5,0,1.5)';
%             set(Can1,'Vertices',Can1_transformedVerticesT(:,1:3));

%% UR3




%% Custom Robot Arm

%KUKA DH Parameters

L1 = Link('d',0.345, 'a',0.020, 'alpha',-pi/2, 'offset',      pi/2, 'qlim',[-170*pi/180 170*pi/180]);
L2 = Link('d',   0, 'a',-0.260, 'alpha',    0, 'offset',        pi, 'qlim',[-170*pi/180  50*pi/180]);
L3 = Link('d',   0, 'a', -0.020, 'alpha', pi/2, 'offset',     -pi/2, 'qlim',[-110*pi/180 155*pi/180]);
L4 = Link('d',0.260, 'a',  0, 'alpha',-pi/2, 'offset',-80*pi/180, 'qlim',[-175*pi/180 175*pi/180]);
L5 = Link('d',   0, 'a',  0, 'alpha', pi/2, 'offset',         0, 'qlim',[-120*pi/180 120*pi/180]);
L6 = Link('d', 0.075, 'a',  0, 'alpha',   pi, 'offset',        pi, 'qlim',[-350*pi/180 350*pi/180]);


robot = SerialLink([L1,L2,L3,L4,L5,L6], 'name', 'KUKA' );


      

%% Main
figure
            axis([-2 2 -2 2 -0.01 4])
            view(-13,14)
            hold on
            robot = UR3(transl(0,0,1.5));
            baseTr = robot.model.fkine(robot.model.getpos).T*transl(0,0,-0.01)*troty(pi);
            pause(2)

        
        %% Working Process
      
            destination_pos = {[-0.4,0.2,1.5];[-0.4,0,1.5];[-0.4,-0.2,1.5];[0,0.3,1.6]};
            for index = 1:size(destination_pos,1)
                object_index = index;
                for step = 1:2
                    if stop_signal
                        break
                    end
                    cases = step;
                    if index == size(destination_pos,1)
                        cases = 3;
                    end
                    switch cases
                        case 1
                            target_pos = object_pos{index};
                            target_pos(1) = target_pos(1) - 0.15;
                            target_ori = trotx(-pi/2)*troty(pi/2)*trotz(-pi/2);
                            matrix_signal = self.FindqMatrix;
                            self.run
                            
                        case 2
                            self.target_pos = self.destination_pos{index};
                            self.target_ori = trotx(-pi/2)*troty(-pi/2)*trotz(-pi/2);
                            self.matrix_signal = self.FindqMatrix;
                            self.run
                            self.gripper_signal = 1;
                            self.GripperControl
                            self.can_attached = false;
                        case 3
                            self.target_pos = self.destination_pos{index};
                            self.target_ori = trotx(-pi/2)*trotz(-pi/2);
                            self.matrix_signal = self.FindqMatrix;
                            self.run
                            break
                    end
                end
            end
        end

