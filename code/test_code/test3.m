
    %%%%%%%%%%%%%%%%%%%%% [ u,v ] = LucasKanade( It,It1,rect )%%%%%%%%%
    It = imread('data\Sequence1\frame0.pgm');%It(y,x)
    It1 = imread('data\Sequence1\frame1.pgm');%It1(y,x)
    rect = [150,85,170,95]; 
    %%%%%%%[x1, y1, x2,y2]%%%
    
    %��ʾ�ڵ�һ�ź͵ڶ���ͼ��Ӧ����λ�õľ��ο�%
    height = rect(4) - rect(2);
    width = rect(3) - rect(1);
    figure(1);imshow(It);hold on;
    rectangle('Position',[rect(1),rect(2),width,height],'Edgecolor','g');
    figure(2);imshow(It1);
    rectangle('Position',[rect(1),rect(2),width,height],'Edgecolor','r');
    fname = sprintf('test%d.jpg',0);
    print(2,'-djpeg',fname);
    hold on;
    %%%%% �ҵ���һ��ͼ�ľ��� %%%% It_Interp 11*21 %%%%%
    [X0,Y0] = meshgrid(1:size(It,2),1:size(It,1));
    [Xi,Yi] = meshgrid(rect(1):rect(3),rect(2):rect(4));
    It_rect = interp2(X0,Y0,double(It),Xi,Yi);

    u=0;
    v=0;
    threshold = 0.001;
    threshold1 = 0.000001;
    sum_uv = 1;
    [X1,Y1] = meshgrid(1:size(It1,2),1:size(It1,1));
    i=0;
    while(1)
        i = i+1;
        %%%%% �ҵ��ڶ���ͼ�ľ��� %%%% It_rect 11*21 %%%%%
        [Xi,Yi] = meshgrid(rect(1)+u:rect(3)+u,rect(2)+v:rect(4)+v);
        It1_rect = interp2(X1,Y1,double(It1),Xi,Yi);
        %%%���������ҵ��ľ���%%%%%
        rectangle('Position',[rect(1)+u,rect(2)+v,width,height],'Edgecolor','g');
        hold on;
        fname = sprintf('test%d.jpg',i);
        print(2,'-djpeg',fname);
        pause(1);


    
        %�ж����������Ƿ���ȣ����ڲ�ֵ����ֲ��ȵ������Ҫ��һ��%
        size1 = size(It_rect);%%��ֵ��������� ��һ��ͼ�ȵڶ���ͼ��һ�л�һ��
        size2 = size(It1_rect);
        if (size1(1)*size1(2)) ~= (size2(1)*size2(2))
            size1
            size2
            if size1(1)==size2(1)+1
               It_rect(1,:) = [];
            elseif size1(1)==size2(1)-1
                    It1_rect(1,:) = [];
            elseif size1(2)==size2(2)+1
                    It_rect(:,1) = [];
            elseif size1(2)==size2(2)-1
                    It1_rect(:,1) = [];
            end  
        end
        
        %����Ix��Iy% 
        [Ix,Iy] = gradient(double(It1_rect));
        %����A%
        Sum_Ix2 = sum(sum(Ix.^2));
        Sum_Iy2 = sum(sum(Iy.^2));
        Sum_IxIy =sum(sum(Ix.*Iy));
        A = [Sum_Ix2,Sum_IxIy;Sum_IxIy,Sum_Iy2];
        
        %����b%
        I_t = It1_rect-It_rect;
        Ix_I_t = sum(sum(Ix.*I_t));
        Iy_I_t = sum(sum(Iy.*I_t));  
        b = -1*[Ix_I_t;Iy_I_t];

        %�����µľ��ο��uv%
        uv = A\b;
        %�����ж��µ�uv�Ƿ��㹻С%
        sum_uv_this = uv(1).^2+uv(2).^2;
        if (sum_uv_this <  threshold )
            %%%�������վ���%%%%%
           rectangle('Position',[rect(1)+u,rect(2)+v,width,height],'Edgecolor','b');
           fname = sprintf('test%d.jpg',i);
           print(2,'-djpeg',fname);
           break;
        end
%         %%�ж��µ�uv�ĸı����Ƿ��㹻С%
%         if abs(sum_uv_this-sum_uv)<threshold1
%            %%%�������վ���%%%%%
%            rectangle('Position',[rect(1)+u,rect(2)+v,width,height],'Edgecolor','y');
%            break
%         end 
        %������һ�μ���ı���%
        sum_uv = sum_uv_this; 
        %�ۼӽ��ɵ�uv%
        u = u + uv(1);
        v = v + uv(2);
    end