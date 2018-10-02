#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

#import "OpenCVWrapper.h"
#include <cmath>

using namespace cv;
using namespace std;

#define COCO_COLORS \
255.f,    0.f,    0.f, \
255.f,   85.f,    0.f, \
255.f,  170.f,    0.f, \
255.f,  255.f,    0.f, \
170.f,  255.f,    0.f, \
85.f,   255.f,    0.f, \
0.f,    255.f,    0.f, \
0.f,    255.f,   85.f, \
0.f,    255.f,  170.f, \
0.f,    255.f,  255.f, \
0.f,    170.f,  255.f, \
0.f,    85.f,   255.f, \
0.f,     0.f,   255.f, \
85.f,    0.f,   255.f, \
170.f,   0.f,   255.f, \
255.f,   0.f,   255.f, \
255.f,   0.f,   170.f, \
255.f,   0.f,    85.f

#define PI 3.14159265



@implementation OpenCVWrapper

-(void) matrixMin: (double *) data
        data_size:(int)data_size
        data_rows:(int)data_rows
        heat_rows:(int)heat_rows {
    
    std::vector<double> vec(&data[0], data + data_size);
    cv::Mat m1(vec),m2;
    m1 = m1.reshape(0, data_rows);
    cv::reduce(m1, m2, 1, CV_REDUCE_MIN);
    for(int i = 0; i < m1.rows; i++)
    {
        m1.row(i) -= m2.row(i);
    }
    
    m1 = m1.reshape(0,data_rows*heat_rows);
    cv::reduce(m1, m2, 1, CV_REDUCE_MIN);
    for(int i = 0; i < m1.rows; i++)
    {
        m1.row(i) -= m2.row(i);
    }
    
    size_t size2 = data_size*sizeof(double);
    std::memcpy(&data[0],m1.data,size2);
    
    vector<double>().swap(vec);
    m1.release();
    m2.release();
}

-(void) maximum_filter: (double *) data
             data_size:(int)data_size
             data_rows:(int)data_rows
             mask_size:(int)mask_size
             threshold:(double)threshold {
    
    std::vector<double> vec(&data[0], data + data_size);
    cv::Mat m1(vec);
    m1 = m1.reshape(0, data_rows);
    
    cv::Mat bg;
    
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT,
                                               cv::Size(mask_size,mask_size),
                                               cv::Point(-1,-1));
    cv::Mat m2;
    m1.copyTo(m2,m1 > threshold);
    
    dilate(m2, bg, kernel);
    
    cv::Mat bg2;
    m2.copyTo(bg2,m2 == bg);
    
    //    cout << "bg = "<< endl << " "  << bg  << endl << endl;
    //    cout << "bg2 = "<< endl << " "  << bg2  << endl << endl;
    
    size_t size2 = data_size*sizeof(double);
    std::memcpy(&data[0],bg2.data,size2);
    
    vector<double>().swap(vec);
    m1.release();
    m2.release();
    bg.release();
    bg2.release();
    kernel.release();
    
}

-(UIImage*) renderKeyPoint:(CGRect) bounds
                  keypoint:(int*) keypoint
             keypoint_size:(int) keypoint_size
                       pos:(CGPoint*) pos
{
    
    std::vector<int> key(&keypoint[0], keypoint + keypoint_size);
    std::vector<CGPoint> position(&pos[0], pos + keypoint_size*2);
    
    auto colors = std::vector<float>{COCO_COLORS};
    
    const auto exp = 4;
    const auto width = bounds.size.width * exp;
    const auto height = bounds.size.height * exp;
    
    cv::Mat mat(width,height,CV_8UC4);
    mat = cv::Scalar(0);
    
    int stickwidth = int(bounds.size.width * exp / 130);
    std::vector<cv::Point> polygon;
    
    for(int i = 0; i < keypoint_size; i++)
    {
        const auto colorIndex = key[i] * 3;
        const auto numberColors = colors.size();
        
        const cv::Scalar color{colors[colorIndex % numberColors],
            colors[(colorIndex+1) % numberColors],
            colors[(colorIndex+2) % numberColors],255};
        
        CGPoint p1 = position[i*2];
        p1.x *= width + 0.5;
        p1.y *= height + 0.5;
        
        CGPoint p2 = position[i*2+1];
        p2.x *= width + 0.5;
        p2.y *= height + 0.5;
        
        cv::Point point = cv::Point(int(p1.x), int(p1.y));
        cv::circle(mat,point,stickwidth,color,-1);
        
        point = cv::Point(int(p2.x), int(p2.y));
        cv::circle(mat,point,stickwidth,color,-1);
        
        auto length = pow( pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2) ,0.5);
        auto angle = atan2(p1.y - p2.y, p1.x - p2.x) * 180.0 / PI;
        
        cv::Point center = cv::Point(int((p1.x + p2.x) / 2.0),
                                     int((p1.y + p2.y) / 2.0));
        cv::ellipse2Poly(center,
                         cv::Size(int(length / 2), stickwidth),
                         int(angle), 0 , 360 , 1, polygon);
        cv::fillConvexPoly(mat, polygon, color);
        
        //        cout << color << endl;
        //        p1 = position[i*2];
        //        p2 = position[i*2+1];
        //        cv::line(mat,
        //                 cv::Point(int(p1.x * width + 0.5), int(p1.y * height + 0.5)),
        //                 cv::Point(int(p2.x * width + 0.5), int(p2.y * height + 0.5)),
        //                 color,5,CV_8UC4);
    }
    
    UIImage *preview = MatToUIImage(mat);
    vector<cv::Point>().swap(polygon);
    vector<int>().swap(key);
    vector<CGPoint>().swap(position);
    mat.release();
    
    return preview;
}

-(NSMutableDictionary*) skinDetect:(UIImage*) oImage
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    CGFloat cols = CGImageGetWidth(oImage.CGImage), rows = CGImageGetHeight(oImage.CGImage);

    
    cv::Mat mat;
    UIImageToMat(oImage, mat);
    

    Mat skinCrCbHist = Mat::zeros(cv::Size(256, 256), CV_8UC1);

    ellipse(skinCrCbHist, cv::Point(113, 155.6), cv::Size(23.4, 15.2), 43.0, 0.0, 360.0, cv::Scalar(255, 255, 255), -1);

    Mat ycrcb_image;
    Mat output_mask = Mat::zeros(rows,cols, CV_8UC1);
    cvtColor(mat, ycrcb_image, CV_RGB2YCrCb); //首先转换成到YCrCb空间

    for (int i = 0; i < cols; i++)   //利用椭圆皮肤模型进行皮肤检测
        for (int j = 0; j < rows; j++)
        {
            Vec3b ycrcb = ycrcb_image.at<Vec3b>(j, i);
            if (skinCrCbHist.at<uchar>(ycrcb[1], ycrcb[2]) > 0)   //如果该落在皮肤模型椭圆区域内，该点就是皮肤像素点
                output_mask.at<uchar>(j, i) = 255;
        }

    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarcy;
    
    findContours(output_mask, contours, hierarcy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    
  
    vector<CGPoint> pts;
    Point2f center;  //定义圆中心坐标
    float radius;  //定义圆半径
    
    NSMutableArray<NSValue *> *muArray = [NSMutableArray array];
    for (int i = 0; i<contours.size(); i++)  //依次遍历每个轮廓
    {
        float area = contourArea(contours[i]);
        if (area > 200)
        {
            minEnclosingCircle(Mat(contours[i]), center, radius);
            NSValue *pointVaule = [NSValue valueWithCGPoint:CGPointMake(center.x,center.y)];
            [muArray addObject:pointVaule];
            
            drawContours(mat, contours, i, Scalar(255, 0, 0,180), 1, 8);
            //circle(mat, center, radius, Scalar(255, 0, 0,180), 1, 8);  //绘制第i个轮廓的最小外接圆
        }
    }
    
    [resultDict setObject:muArray forKey:@"resultCGPointVauleArray"];
    
    UIImage *preview = MatToUIImage(mat);
    mat.release();
    skinCrCbHist.release();
    ycrcb_image.release();
    output_mask.release();
    
    [resultDict setObject:preview forKey:@"resultImage"];
    
    return resultDict;
    
    
    
//    Mat ycrcb_image;
//    int Cr = 1;
//    int Cb = 2;
//    cvtColor(mat, ycrcb_image, CV_RGB2YCrCb); //首先转换成到YCrCb空间
//    Mat output_mask = Mat::zeros(mat.size(), CV_8UC1);
//    for (int i = 0; i < mat.rows; i++)
//    {
//        for (int j = 0; j < mat.cols; j++)
//        {
//            uchar *p_mask = output_mask.ptr<uchar>(i, j);
//            uchar *p_src = ycrcb_image.ptr<uchar>(i, j);
//            if (p_src[Cr] >= 133 && p_src[Cr] <= 173 && p_src[Cb] >= 77 && p_src[Cb] <= 127)
//            {
//                p_mask[0] = 255;
//            }
//        }
//    }
//
//    UIImage *preview = MatToUIImage(output_mask);
//    mat.release();
//    ycrcb_image.release();
//    output_mask.release();

}


@end



