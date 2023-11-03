 %% Updated UI
       self.handles.fig = uifigure('Name','Can-Can Robot','position',[80 250 524 472]);
       self.handles.pb0 = uiswitch(self.handles.fig,'toggle','Position',[45 385 20 45],'Items',{'Off','On'},'Value',0,'ValueChangedFcn',@login_cb,'ItemsData',{0,1});
       self.handles.pb1 = uicontrol(self.handles.fig,'style','togglebutton','position',[35 179 108 41],'callback',@stop_cb,'string','Stop');
       self.handles.pb2 = uicontrol(self.handles.fig,'style','pushbutton','position',[35 249 108 41],'callback',@resume_cb,'string','Run');
       self.handles.pb3 = uicontrol(self.handles.fig,'style','pushbutton','position',[35 109 108 41],'callback',@logout_cb,'string','Log out');
       self.handles.pb4 = uicontrol(self.handles.fig,'style','edit','position',[111 333 304 118],'HorizontalAlignment','center','FontSize',14,'Value',1,'BackgroundColor','k');
       self.handles.pb5 = uilamp(self.handles.fig,'Color','r','Position',[449 405 46 46]);
       self.handles.pb6 = uicontrol(self.handles.fig,'style','pushbutton','position',[35 39 108 41],'callback',@control_Ur3,'string','Control UR3');
       self.handles.pb7 = uicontrol(self.handles.fig,'style','pushbutton','position',[178 39 108 41],'callback',@control_Kuka,'string','Control Kuka');


%% Open the Control GUI for the KUKA Kr540
            function control_Kuka(~,~)
                cur2_q = self.robot2.model.getpos();
                cur2_pos = self.robot2.model.fkine(self.robot2.model.getpos).T;
                cur2_ori = tr2rpy(cur2_pos,'deg','xyz');

                self.handles.fig2 = uifigure('Name','Control Mode','position',[77 250 524 472]);
                self.handles.sb0 = uicontrol(self.handles.fig2,'style','edit','position',[112 392 304 70],'HorizontalAlignment','center','FontSize',11,'BackgroundColor','w','Max',2,'Min',0);
                self.handles.sb1 = uislider(self.handles.fig2,"Position",[77 367 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb1.Value = cur2_q(1);
                self.handles.sb2 = uislider(self.handles.fig2,"Position",[77 317 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb2.Value = cur2_q(2);
                self.handles.sb3 = uislider(self.handles.fig2,"Position",[77 267 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb3.Value = cur2_q(3);
                self.handles.sb4 = uislider(self.handles.fig2,"Position",[77 217 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb4.Value = cur2_q(4);
                self.handles.sb5 = uislider(self.handles.fig2,"Position",[77 167 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb5.Value = cur2_q(5);
                self.handles.sb6 = uislider(self.handles.fig2,"Position",[77 117 327 7],"Limits",[-2*pi 2*pi]);
                self.handles.sb6.Value = cur2_q(6);
                

                self.handles.sb7 = uispinner(self.handles.fig2,"Position",[448 344 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb7.Value = cur2_pos(1,4);
                self.handles.sb8 = uispinner(self.handles.fig2,"Position",[448 279 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb8.Value = cur2_pos(2,4);
                self.handles.sb9 = uispinner(self.handles.fig2,"Position",[448 214 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb9.Value = cur2_pos(3,4);
                self.handles.sb10 = uispinner(self.handles.fig2,"Position",[448 149 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb10.Value = cur2_ori(1);
                self.handles.sb11 = uispinner(self.handles.fig2,"Position",[448 84 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb11.Value = cur2_ori(2);
                self.handles.sb12 = uispinner(self.handles.fig2,"Position",[448 19 67 30],"ValueDisplayFormat", '%.2f',"Step",0.02);
                self.handles.sb12.Value = cur2_ori(3);

                self.handles.sb13 = uicontrol(self.handles.fig2,'style','pushbutton','position',[44 22 116 35],'callback',@updatepose3_cb,'string','Joints');
                self.handles.sb14 = uicontrol(self.handles.fig2,'style','pushbutton','position',[270 22 116 35],'callback',@updatepose4_cb,'string','Cartesian');

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

            %% updatepose3
             function updatepose3_cb(~, ~)
            % Get the joint angle values from the sliders
            joint1 = self.handles.sb1.Value;
            joint2 = self.handles.sb2.Value;
            joint3 = self.handles.sb3.Value;
            joint4 = self.handles.sb4.Value;
            joint5 = self.handles.sb5.Value;
            joint6 = self.handles.sb6.Value;
        
             % Set the joint angles for the robot (assuming 'robot2' represents the KUKA KR3 R540)
             q_end = [joint1, joint2, joint3, joint4, joint5, joint6];
    
            % Update the robot's joint angles
            self.robot2.model.animate(q_end);

             % Update UI Values
            cur_pos = self.robot2.model.fkine(self.robot2.model.getpos).T;
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
            end