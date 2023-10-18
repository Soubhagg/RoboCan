%% Lab 2 Robocan Assignment
close all
clc

%% Log
L = 



%% Environment Creation

% Add table
            Table = PlaceObject('Table.ply');
            Table_vertices = get(Table,'Vertices');
            transformedVerticesT = [Table_vertices,ones(size(Table_vertices,1),1)]*troty(-pi/2)'*transl(0,0,1.4)';
            set(Table,'Vertices',transformedVerticesT(:,1:3));
% Add cans

            Can1 = PlaceObject('Canbody.ply');
            Can1_vertices = get(Can1,'Vertices');
            Can1_transformedVerticesT = [Can1_vertices,ones(size(Can1_vertices,1),1)]*trotx(-pi/2)*transl(0.5,0,1.5)';
            set(Can1,'Vertices',Can1_transformedVerticesT(:,1:3));

%% UR3




%% Custom Robot Arm

%KUKA DH Parameters

L1=Link('d',0.129, 'a', 0.002, 'alpha', -pi/2, 'offset', 0, 'qlim',[deg2rad(-170), deg2rad(170)]);
L2=Link('d',0, 'a', 0.345-0.129, 'alpha', 0, 'offset', 0, 'qlim',[deg2rad(-170), deg2rad(50)]);
L3=Link('d',0, 'a', 0.280, 'alpha', -pi/2, 'offset', 0, 'qlim',[deg2rad(-110), deg2rad(155)]);
L4=Link('d',0.260-0.152, 'a',0, 'alpha', pi/2, 'offset', 0, 'qlim',[deg2rad(-175), deg2rad(175)]);
L5=Link('d',0, 'a', 0.260-0.152, 'alpha',-pi/2 , 'offset', 0, 'qlim',[deg2rad(-120), deg2rad(120)]);
L6=Link('d',0.075, 'a', 0, 'alpha',pi/2, 'offset', 0, 'qlim',[deg2rad(-350), deg2rad(350)]);


Robot = SerialLink([L1,L2,L3,L4,L5,L6], 'name', 'KUKA' );

q = zeros(1,6);       
Robot.plot(q);       
Robot.teach();
      



%% Main


