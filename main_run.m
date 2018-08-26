clc
clear all
close all


pause(2)


imaqreset

op1=imresize(imread('.\Images\Eat.jpg'),[256 300]);
op2=imresize(imread('.\Images\Entertainment.png'),[256 300]);
op3=imresize(imread('.\Images\Help.jpg'),[256 300]);

lv1_1=imresize(imread('.\Images\Juice.jpg'),[256 300]);
lv1_2=imresize(imread('.\Images\Water.jpg'),[256 300]);
lv1_3=imresize(imread('.\Images\food.jpg'),[256 300]);
lv1_4=imresize(imread('.\Images\back.png'),[256 300]);

lv2_1=imresize(imread('.\Images\Music.jpg'),[256 300]);
lv2_2=imresize(imread('.\Images\Movie.jpg'),[256 300]);
lv2_3=imresize(imread('.\Images\back.png'),[256 300]);

lv3_1=imresize(imread('.\Images\Urination.png'),[256 300]);
lv3_2=imresize(imread('.\Images\Excreation.png'),[256 300]);
lv3_3=imresize(imread('.\Images\Pain.jpg'),[256 300]);
lv3_4=imresize(imread('.\Images\back.png'),[256 300]);

flow=0;

%%%%%%%%%%%%%%%%%%%%%%
%   Op           Meaning     %
%--------------------------------%
%   4               Juice
%   5               Water
%   6               Food
%   8               Music
%   9               Movie
%  11              Urination
%  12              Excreation
%  13              Feeling Pain
%%%%%%%%%%%%%%%%%%%%%%

opvect={' ', ' ',' ','Juice', 'Water','Food',' ', 'Music', 'Movie', ' ', 'Urination', 'Excreation', 'Feeling Pain'};

% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

vid_obj = videoinput('winvideo', 2,'YUY2_640x480');
disp('Initializing..')

flg=1;
k=0;
imcnt=0;
eyecnt=0;
blkcnt=0;
chngcnt=0;
freq=3;%%% Option changing frequency
blink_thresh=3;%%% Blink count threshold
tic
%run the face detector
while(flg==1)
    
    videoFrame      = ycbcr2rgb(getsnapshot(vid_obj));
    bbox1            = step(faceDetector, videoFrame);
    
    % Draw the returned bounding box around the detected face.
    videoOut = insertObjectAnnotation(videoFrame,'rectangle',bbox1,'Face Region');
    
    imcnt=imcnt+1;
    
%     figure(1),
%     imshow(videoOut), 
%     title(['Captured Image number ' num2str(imcnt)]);
    
    if(size(bbox1,1)==1)
        if(bbox1(1,3)<150 && bbox1(4)<150)
            disp('here..')
            continue;
        end
    else
        continue;
    end

    eyesDetector = vision.CascadeObjectDetector('EyePairBig');
    faceImage    = imcrop(videoFrame,bbox1(1,:));
    eyesBBox     = step(eyesDetector,faceImage);

    % The nose bounding box is defined relative to the cropped face image.
    if size(eyesBBox,1)==1
        eyesBBox(1,1:2) = eyesBBox(1,1:2) + bbox1(1,1:2);
        
        eyecnt=eyecnt+1;
     
        h1=figure(1);
        rect=get(h1,'Position');
        set(h1,'Position',[100 rect(2:4)]);
        imshow(videoOut) 
        hold on
        rectangle('Position',eyesBBox(1,:),'LineWidth',2,'EdgeColor',[0 0 1])
        title(['Detected face and eye( frame no. '  num2str(eyecnt) , ')'])
        
        eye_img=videoOut(eyesBBox(2):eyesBBox(2)+eyesBBox(4), eyesBBox(1):eyesBBox(1)+eyesBBox(3),:);
        
        h2=figure(2);
        rect2=get(h2,'Position');
        set(h2,'Position',[rect(1)+rect(3)+50 rect2(2:4)]);
        subplot(2,1,1)
        imshow(eye_img)
        title('Extracted Eye Region')
        
%         imwrite(eye_img,['.\Data\' num2str(eyecnt) '.png'])
        [im2, des2, loc2] = sift_img(eye_img);
        load('length');

        for k = 1:len
            eval(['load SIFTData' num2str(k) ';']);
            num(k)=match(im2, des2, loc2,im1, des1, loc1);
        end

        [val id]=max(num);
        
        if id <4
            blkcnt=blkcnt+1;
            if blkcnt==blink_thresh
                
                disp('Blink detected');
                blkcnt=0;
                
                if op<4 && op~=0
                    flow=1;
                    chngcnt=0;
                    sel=op;
                    if op==1,
                        disp('Eat option selected');
                         tts('Eat option selected')
                          
                    elseif op==2,
                        disp('Entertainment option selected')
                         tts('Entertainment option selected')
                          
                         %%%%%%
                    else
                        disp('Help option selected')
                         tts('Help option selected')
                          
                    end
                    pause(1)
                     tts('Select the sub-option')

                end
                
                if flow==1 && op>3
                    if op==7 || op==10 || op==14
                        disp('Going to previous option')
                         tts('Going to previous option')
                    else
                        disp([opvect{op} ' option selected'])
                         tts([opvect{op} ' option selected'])
  
                          
                         pause(1)
                         tts('Your request has been sent. Please wait for a moment!')
                    end                   
                    flow=0;
                    chngcnt=0;
                    flg=0; %%%%%%   REMOVE FOR A CONTINOUS LOOP  %%%
                end
                
            end
        else
            blkcnt=0;
            chngcnt=chngcnt+1;%%%%%%%%%%%frame show
            
            if flow==0
                if chngcnt<freq+1
                    subplot(2,1,2)
                    imshow(op1)
                    title('Need to Eat ?')
                    op=1;
                elseif chngcnt <2*freq+1
                    subplot(2,1,2)
                    imshow(op2)
                    title('Want Entertainment ?')
                    op=2;
                elseif chngcnt <3*freq+1
                    subplot(2,1,2)
                    imshow(op3)
                    title('Need Help ?')
                    op=3;
                    
                else
                    chngcnt=0;
                    op=0;
                end
            %%%%%%%%%%%%  Inside First Level -- EAT Option %%%%%%%%    
            elseif flow==1 && sel==1
                if chngcnt<freq+1
                    subplot(2,1,2)
                    imshow(lv1_1)
                    title('Need Juice ?')
                    op=4;
                elseif chngcnt <2*freq+1
                    subplot(2,1,2)
                    imshow(lv1_2)
                    title('Need Water ?')
                    op=5;
                elseif chngcnt <3*freq+1
                    subplot(2,1,2)
                    imshow(lv1_3)
                    title('Need Food ?')
                    op=6;
                 elseif chngcnt <4*freq+1
                    subplot(2,1,2)
                    imshow(lv1_4)
                    title('Previous Option ?')
                    op=7;
                else
                    chngcnt=0;
                    op=0;
                end
   %%%%%%%%%%%%  Inside First Level -- Entertainment Option %%%%%%%%    
            elseif flow==1 && sel==2
                if chngcnt<freq+1
                    subplot(2,1,2)
                    imshow(lv2_1)
                    title('Play Music ?')
                    op=8;
                elseif chngcnt <2*freq+1
                    subplot(2,1,2)
                    imshow(lv2_2)
                    title('Play Movie ?')
                    op=9;
                elseif chngcnt <3*freq+1
                    subplot(2,1,2)
                    imshow(lv2_3)
                    title('Previous Option ?')
                    op=10;
                 else
                    chngcnt=0;
                    op=0;
                end
             %%%%%%%%%%%%  Inside First Level -- Help Option %%%%%%%%    
            elseif flow==1 && sel==3
                if chngcnt<freq+1
                    subplot(2,1,2)
                    imshow(lv3_1)
                    title('Urination?')
                    op=11;
                elseif chngcnt <2*freq+1
                    subplot(2,1,2)
                    imshow(lv3_2)
                    title('Excreation ?')
                    op=12;
                    
                elseif chngcnt <3*freq+1
                    subplot(2,1,2)
                    imshow(lv3_3)
                    title('Feeling Pain ?')
                    op=13;
                elseif chngcnt <4*freq+1
                    subplot(2,1,2)
                    imshow(lv3_4)
                    title('Previous Option ?')
                    op=14;
                 else
                    chngcnt=0;
                    op=0;
                end
                
            end
        end
                    
    end
    k=k+1;
    
end
