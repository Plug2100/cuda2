#include <iostream>
#include <fstream>
#include <vector>
#include "lodepng.h"
using namespace std;
int help_ = 0;
int smalll = 0;
__global__
void filtr(const unsigned char* dev_input_0, const unsigned char* dev_input_1, const unsigned char* dev_input_2, unsigned char* dev_output_0, unsigned char* dev_output_1, unsigned char* dev_output_2, int width, int height, int cern) {
    //Индекс треда внутри текущего блока
    __shared__  unsigned char r_dev_input_0[36][36];
    __shared__  unsigned char b_dev_input_0[36][36];
    __shared__  unsigned char g_dev_input_0[36][36];

    const unsigned int linearX = (blockIdx.x / 3) * blockDim.x + threadIdx.x;
    const unsigned int linearY = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (linearX >= (width * 3) || linearY >= height) {
        return;
    }

    r_dev_input_0[threadIdx.y+2][threadIdx.x+2] = dev_input_0[(linearY * width + linearX)];
    g_dev_input_0[threadIdx.y+2][threadIdx.x+2] = dev_input_1[(linearY * width + linearX)];
    b_dev_input_0[threadIdx.y+2][threadIdx.x+2] = dev_input_2[(linearY * width + linearX)];
    
    if(threadIdx.x == 31){
        r_dev_input_0[threadIdx.y+2][threadIdx.x+3] = dev_input_0[(linearY * width + linearX+1)];
        g_dev_input_0[threadIdx.y+2][threadIdx.x+3] = dev_input_1[(linearY * width + linearX+1)];
        b_dev_input_0[threadIdx.y+2][threadIdx.x+3] = dev_input_2[(linearY * width + linearX+1)];
    
    }
    if(threadIdx.x == 0 and linearX > 0){
        r_dev_input_0[threadIdx.y+2][threadIdx.x+1] = dev_input_0[(linearY * width + linearX-1)];
        g_dev_input_0[threadIdx.y+2][threadIdx.x+1] = dev_input_1[(linearY * width + linearX-1)];
        b_dev_input_0[threadIdx.y+2][threadIdx.x+1] = dev_input_2[(linearY * width + linearX-1)];
    }
    if(threadIdx.y == 31){
        r_dev_input_0[threadIdx.y+3][threadIdx.x+2] = dev_input_0[((linearY+1) * width + linearX)];
        g_dev_input_0[threadIdx.y+3][threadIdx.x+2] = dev_input_1[((linearY+1) * width + linearX)];
        b_dev_input_0[threadIdx.y+3][threadIdx.x+2] = dev_input_2[((linearY+1) * width + linearX)];
    }
    if(threadIdx.y == 0 and linearY > 0){
        r_dev_input_0[threadIdx.y+1][threadIdx.x+2] = dev_input_0[((linearY-1) * width + linearX)];
        g_dev_input_0[threadIdx.y+1][threadIdx.x+2] = dev_input_1[((linearY-1) * width + linearX)];
        b_dev_input_0[threadIdx.y+1][threadIdx.x+2] = dev_input_2[((linearY-1) * width + linearX)];
    
    }
    if(cern == 1){
        if(threadIdx.x == 31){
        r_dev_input_0[threadIdx.y+2][threadIdx.x+4] = dev_input_0[(linearY * width + linearX+2)];
        g_dev_input_0[threadIdx.y+2][threadIdx.x+4] = dev_input_1[(linearY * width + linearX+2)];
        b_dev_input_0[threadIdx.y+2][threadIdx.x+4] = dev_input_2[(linearY * width + linearX+2)];
    
    }
    if(threadIdx.x == 0 and linearX > 0){
        r_dev_input_0[threadIdx.y+2][threadIdx.x] = dev_input_0[(linearY * width + linearX-2)];
        g_dev_input_0[threadIdx.y+2][threadIdx.x] = dev_input_1[(linearY * width + linearX-2)];
        b_dev_input_0[threadIdx.y+2][threadIdx.x] = dev_input_2[(linearY * width + linearX-2)];
    }
    if(threadIdx.y == 31){
        r_dev_input_0[threadIdx.y+4][threadIdx.x+2] = dev_input_0[((linearY+2) * width + linearX)];
        g_dev_input_0[threadIdx.y+4][threadIdx.x+2] = dev_input_1[((linearY+2) * width + linearX)];
        b_dev_input_0[threadIdx.y+4][threadIdx.x+2] = dev_input_2[((linearY+2) * width + linearX)];
    }
    if(threadIdx.y == 0 and linearY > 0){
        r_dev_input_0[threadIdx.y][threadIdx.x+2] = dev_input_0[((linearY-2) * width + linearX)];
        g_dev_input_0[threadIdx.y][threadIdx.x+2] = dev_input_1[((linearY-2) * width + linearX)];
        b_dev_input_0[threadIdx.y][threadIdx.x+2] = dev_input_2[((linearY-2) * width + linearX)];
    
    }
    }
    __syncthreads();
    if(cern == 1){
        if(linearY > 1 and linearY < (height - 2) and linearX > 1 and linearX < (width - 2)
            or linearY > 1 and linearY < (height - 2) and linearX > (1 + width) and linearX < (2 * width - 2)
            or linearY > 1 and linearY < (height - 2) and linearX > (1 + 2* width) and linearX < (3 * width - 2)) {
            if(blockIdx.x % 3 == 0){
                dev_output_0[(linearY * width + linearX)] = 
                    (r_dev_input_0[threadIdx.y+2][threadIdx.x+2] * 36 +
                    r_dev_input_0[threadIdx.y+2][threadIdx.x+1] * 24 +
                    r_dev_input_0[threadIdx.y+3][threadIdx.x+2] * 24 +
                    r_dev_input_0[threadIdx.y+1][threadIdx.x+2] * 24 +
                    r_dev_input_0[threadIdx.y+2][threadIdx.x+3] * 24 +



                    r_dev_input_0[threadIdx.y+3][threadIdx.x+3] * 16 +
                    r_dev_input_0[threadIdx.y+3][threadIdx.x+1] * 16 +
                    r_dev_input_0[threadIdx.y+1][threadIdx.x+3] * 16 +
                    r_dev_input_0[threadIdx.y+1][threadIdx.x+1] * 16 +
 
                    r_dev_input_0[threadIdx.y+2][threadIdx.x+4] * 6 +
                    r_dev_input_0[threadIdx.y+2][threadIdx.x] * 6 +
                    r_dev_input_0[threadIdx.y+4][threadIdx.x+2] * 6 +
                    r_dev_input_0[threadIdx.y][threadIdx.x+2] * 6 +
 
 
                    r_dev_input_0[threadIdx.y+4][threadIdx.x+4] +
                    r_dev_input_0[threadIdx.y][threadIdx.x+4] +
                    r_dev_input_0[threadIdx.y+4][threadIdx.x] +
                    r_dev_input_0[threadIdx.y][threadIdx.x] +
 
 
                    r_dev_input_0[threadIdx.y][threadIdx.x+1] +
                    r_dev_input_0[threadIdx.y+4][threadIdx.x+1] +
                    r_dev_input_0[threadIdx.y][threadIdx.x+3] +
                    r_dev_input_0[threadIdx.y+4][threadIdx.x+3] +
 
                    r_dev_input_0[threadIdx.y+1][threadIdx.x+4] +
                    r_dev_input_0[threadIdx.y+3][threadIdx.x+4] +
                    r_dev_input_0[threadIdx.y+1][threadIdx.x] +
                    r_dev_input_0[threadIdx.y+3][threadIdx.x]) /  256;
            }
 
 
 
            if(blockIdx.x % 3 == 1){ 
                dev_output_1[(linearY * width + linearX)] = (g_dev_input_0[threadIdx.y+2][threadIdx.x+2] * 36 +
                    g_dev_input_0[threadIdx.y+2][threadIdx.x+1] * 24 +
                    g_dev_input_0[threadIdx.y+3][threadIdx.x+2] * 24 +
                    g_dev_input_0[threadIdx.y+1][threadIdx.x+2] * 24 +
                    g_dev_input_0[threadIdx.y+2][threadIdx.x+3] * 24 +



                    g_dev_input_0[threadIdx.y+3][threadIdx.x+3] * 16 +
                    g_dev_input_0[threadIdx.y+3][threadIdx.x+1] * 16 +
                    g_dev_input_0[threadIdx.y+1][threadIdx.x+3] * 16 +
                    g_dev_input_0[threadIdx.y+1][threadIdx.x+1] * 16 +
 
                    g_dev_input_0[threadIdx.y+2][threadIdx.x+4] * 6 +
                    g_dev_input_0[threadIdx.y+2][threadIdx.x] * 6 +
                    g_dev_input_0[threadIdx.y+4][threadIdx.x+2] * 6 +
                    g_dev_input_0[threadIdx.y][threadIdx.x+2] * 6 +
 
 
                    g_dev_input_0[threadIdx.y+4][threadIdx.x+4] +
                    g_dev_input_0[threadIdx.y][threadIdx.x+4] +
                    g_dev_input_0[threadIdx.y+4][threadIdx.x] +
                    g_dev_input_0[threadIdx.y][threadIdx.x] +
 
 
                    g_dev_input_0[threadIdx.y][threadIdx.x+1] +
                    g_dev_input_0[threadIdx.y+4][threadIdx.x+1] +
                    g_dev_input_0[threadIdx.y][threadIdx.x+3] +
                    g_dev_input_0[threadIdx.y+4][threadIdx.x+3] +
 
                    g_dev_input_0[threadIdx.y+1][threadIdx.x+4] +
                    g_dev_input_0[threadIdx.y+3][threadIdx.x+4] +
                    g_dev_input_0[threadIdx.y+1][threadIdx.x] +
                    g_dev_input_0[threadIdx.y+3][threadIdx.x]) /  256;
            }
 
 
            if(blockIdx.x % 3 == 2){ 
                dev_output_2[(linearY * width + linearX)] = (b_dev_input_0[threadIdx.y+2][threadIdx.x+2] * 36 +
                    b_dev_input_0[threadIdx.y+2][threadIdx.x+1] * 24 +
                    b_dev_input_0[threadIdx.y+3][threadIdx.x+2] * 24 +
                    b_dev_input_0[threadIdx.y+1][threadIdx.x+2] * 24 +
                    b_dev_input_0[threadIdx.y+2][threadIdx.x+3] * 24 +



                    b_dev_input_0[threadIdx.y+3][threadIdx.x+3] * 16 +
                    b_dev_input_0[threadIdx.y+3][threadIdx.x+1] * 16 +
                    b_dev_input_0[threadIdx.y+1][threadIdx.x+3] * 16 +
                    b_dev_input_0[threadIdx.y+1][threadIdx.x+1] * 16 +
 
                    b_dev_input_0[threadIdx.y+2][threadIdx.x+4] * 6 +
                    b_dev_input_0[threadIdx.y+2][threadIdx.x] * 6 +
                    b_dev_input_0[threadIdx.y+4][threadIdx.x+2] * 6 +
                    b_dev_input_0[threadIdx.y][threadIdx.x+2] * 6 +
 
 
                    b_dev_input_0[threadIdx.y+4][threadIdx.x+4] +
                    b_dev_input_0[threadIdx.y][threadIdx.x+4] +
                    b_dev_input_0[threadIdx.y+4][threadIdx.x] +
                    b_dev_input_0[threadIdx.y][threadIdx.x] +
 
 
                    b_dev_input_0[threadIdx.y][threadIdx.x+1] +
                    b_dev_input_0[threadIdx.y+4][threadIdx.x+1] +
                    b_dev_input_0[threadIdx.y][threadIdx.x+3] +
                    b_dev_input_0[threadIdx.y+4][threadIdx.x+3] +
 
                    b_dev_input_0[threadIdx.y+1][threadIdx.x+4] +
                    b_dev_input_0[threadIdx.y+3][threadIdx.x+4] +
                    b_dev_input_0[threadIdx.y+1][threadIdx.x] +
                    b_dev_input_0[threadIdx.y+3][threadIdx.x]) /  256;
            }
        }
    }
    else if(cern == 2){
        if(linearY > 0 and linearY < (height - 1) and linearX > 0 and linearX < (width - 1)
            or linearY > 0 and linearY < (height - 1) and linearX > width and linearX < (2*width - 1)
            or linearY > 0 and linearY < (height - 1) and linearX > 2*width and linearX < (3*width - 1)) {
            if(blockIdx.x % 3 == 0){ 
                dev_output_0[(linearY * width + linearX)] =
                    (r_dev_input_0[threadIdx.y+2][threadIdx.x+2] +
                          r_dev_input_0[threadIdx.y+1][threadIdx.x+3] +
                          r_dev_input_0[threadIdx.y+2][threadIdx.x+3] +
                          r_dev_input_0[threadIdx.y+3][threadIdx.x+3] +
                          r_dev_input_0[threadIdx.y+1][threadIdx.x+2] +
                          r_dev_input_0[threadIdx.y+3][threadIdx.x+2] +
                          r_dev_input_0[threadIdx.y+1][threadIdx.x+1] +
                          r_dev_input_0[threadIdx.y+2][threadIdx.x+1] +
                          r_dev_input_0[threadIdx.y+2][threadIdx.x+2]) / 9;
            }
            if(blockIdx.x % 3 == 1){ 
                dev_output_1[(linearY * width + linearX)] =
                    (g_dev_input_0[threadIdx.y+2][threadIdx.x+2] +
                          g_dev_input_0[threadIdx.y+1][threadIdx.x+3] +
                          g_dev_input_0[threadIdx.y+2][threadIdx.x+3] +
                          g_dev_input_0[threadIdx.y+3][threadIdx.x+3] +
                          g_dev_input_0[threadIdx.y+1][threadIdx.x+2] +
                          g_dev_input_0[threadIdx.y+3][threadIdx.x+2] +
                          g_dev_input_0[threadIdx.y+1][threadIdx.x+1] +
                          g_dev_input_0[threadIdx.y+2][threadIdx.x+1] +
                          g_dev_input_0[threadIdx.y+2][threadIdx.x+2]) / 9;
            }
            if(blockIdx.x % 3 == 2){ 
                dev_output_2[(linearY * width + linearX)] =
                    (b_dev_input_0[threadIdx.y+2][threadIdx.x+2] +
                          b_dev_input_0[threadIdx.y+1][threadIdx.x+3] +
                          b_dev_input_0[threadIdx.y+2][threadIdx.x+3] +
                          b_dev_input_0[threadIdx.y+3][threadIdx.x+3] +
                          b_dev_input_0[threadIdx.y+1][threadIdx.x+2] +
                          b_dev_input_0[threadIdx.y+3][threadIdx.x+2] +
                          b_dev_input_0[threadIdx.y+1][threadIdx.x+1] +
                          b_dev_input_0[threadIdx.y+2][threadIdx.x+1] +
                          b_dev_input_0[threadIdx.y+2][threadIdx.x+2]) / 9;
            }
        }
    }
    else if(cern == 3){
        if(linearY > 0 and linearY < (height - 1) and linearX > 0 and linearX < (width - 1)
            or linearY > 0 and linearY < (height - 1) and linearX > width and linearX < (2*width - 1)
            or linearY > 0 and linearY < (height - 1) and linearX > 2*width and linearX < (3*width - 1)){
            if(blockIdx.x % 3 == 0){    
                dev_output_0[(linearY * width + linearX)] =
                    r_dev_input_0[threadIdx.y+2][threadIdx.x+2] * 8 -
                          r_dev_input_0[threadIdx.y+1][threadIdx.x+3] -
                          r_dev_input_0[threadIdx.y+2][threadIdx.x+3] -
                          r_dev_input_0[threadIdx.y+3][threadIdx.x+3] -
                          r_dev_input_0[threadIdx.y+1][threadIdx.x+2] -
                          r_dev_input_0[threadIdx.y+3][threadIdx.x+2] -
                          r_dev_input_0[threadIdx.y+1][threadIdx.x+1] -
                          r_dev_input_0[threadIdx.y+2][threadIdx.x+1] -
                          r_dev_input_0[threadIdx.y+2][threadIdx.x+2];
            }
            if(blockIdx.x % 3 == 1){ 
                dev_output_1[(linearY * width + linearX)]=
                    g_dev_input_0[threadIdx.y+2][threadIdx.x+2] * 8 -
                          g_dev_input_0[threadIdx.y+1][threadIdx.x+3] -
                          g_dev_input_0[threadIdx.y+2][threadIdx.x+3] -
                          g_dev_input_0[threadIdx.y+3][threadIdx.x+3] -
                          g_dev_input_0[threadIdx.y+1][threadIdx.x+2] -
                          g_dev_input_0[threadIdx.y+3][threadIdx.x+2] -
                          g_dev_input_0[threadIdx.y+1][threadIdx.x+1] -
                          g_dev_input_0[threadIdx.y+2][threadIdx.x+1] -
                          g_dev_input_0[threadIdx.y+2][threadIdx.x+2];
            }
            if(blockIdx.x % 3 == 2){ 
                dev_output_2[(linearY * width + linearX)] =
                    b_dev_input_0[threadIdx.y+2][threadIdx.x+2] * 8-
                          b_dev_input_0[threadIdx.y+1][threadIdx.x+3] -
                          b_dev_input_0[threadIdx.y+2][threadIdx.x+3] -
                          b_dev_input_0[threadIdx.y+3][threadIdx.x+3] -
                          b_dev_input_0[threadIdx.y+1][threadIdx.x+2] -
                          b_dev_input_0[threadIdx.y+3][threadIdx.x+2] -
                          b_dev_input_0[threadIdx.y+1][threadIdx.x+1] -
                          b_dev_input_0[threadIdx.y+2][threadIdx.x+1] -
                          b_dev_input_0[threadIdx.y+2][threadIdx.x+2];
            }
        }
    }
}
 
 
 
void funk(const char* input_file, const char* output_file, int filtr_n){
    vector<unsigned char> in_image;
    unsigned int width, height;
    // Load the data
    unsigned error = lodepng::decode(in_image, width, height, input_file);
    float all_all = 0;
    float caunting_all = 0;
    cudaEvent_t all_start;
    cudaEvent_t all_stop;
    cudaEvent_t start_caunting;
    cudaEvent_t stop_caunting;
    cudaEventCreate(&all_start);
    cudaEventCreate(&all_stop);
    cudaEventCreate(&start_caunting);
    cudaEventCreate(&stop_caunting);
 
 
    // Prepare the data
    unsigned char* input_image_0 = new unsigned char[(in_image.size())/4];
    unsigned char* input_image_1 = new unsigned char[(in_image.size())/4];
    unsigned char* input_image_2 = new unsigned char[(in_image.size())/4];
 
    unsigned char* output_image_0 = new unsigned char[(in_image.size())/4];
    unsigned char* output_image_1 = new unsigned char[(in_image.size())/4];
    unsigned char* output_image_2 = new unsigned char[(in_image.size())/4];
 
    int where_0 = 0;
    int where_1 = 0;
    int where_2 = 0;
    for(int i = 0; i < in_image.size(); ++i) {
        if(i % 4 == 0){
            input_image_0[where_0] = in_image.at(i);
            where_0++;
        }
        if(i % 4 == 1){
            input_image_1[where_1] = in_image.at(i);
            where_1++;
        }
        if(i % 4 == 2){
            input_image_2[where_2] = in_image.at(i);
            where_2++;
        }
    }
 
    cudaEventRecord(all_start);
    cudaEventSynchronize(all_start);
 
 
    unsigned char* dev_input_0;
    unsigned char* dev_input_1;
    unsigned char* dev_input_2;

    unsigned char* dev_output_0;
    unsigned char* dev_output_1;
    unsigned char* dev_output_2;
    if(help_ == 0){
        help_ = 1;
        cudaMalloc( (void**) &dev_input_0, width*height*sizeof(unsigned char));
        cudaMalloc( (void**) &dev_input_1, width*height*sizeof(unsigned char));
        cudaMalloc( (void**) &dev_input_2, width*height*sizeof(unsigned char));
        cudaMalloc( (void**) &dev_output_0, width*height*sizeof(unsigned char));
        cudaMalloc( (void**) &dev_output_1, width*height*sizeof(unsigned char));
        cudaMalloc( (void**) &dev_output_2, width*height*sizeof(unsigned char));
    }
    cudaMemcpy( dev_input_0, input_image_0, width*height*sizeof(unsigned char), cudaMemcpyHostToDevice ); 
    cudaMemcpy( dev_input_1, input_image_1, width*height*sizeof(unsigned char), cudaMemcpyHostToDevice );
    cudaMemcpy( dev_input_2, input_image_2, width*height*sizeof(unsigned char), cudaMemcpyHostToDevice );
 
 
 
 
   
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    int help = floor(sqrt(prop.maxThreadsPerBlock));
   // help = 61
    if(help > height){
        help = height;
    }
    if(help > width){
        help = width;
    }  
    dim3 blockDims(help, help,1);
    dim3 gridDims(ceil(width / help) * 3, ceil(height / help), 1 );
 
 
 
    cudaEventRecord(start_caunting);
    cudaEventSynchronize(start_caunting);
 
    filtr<<<gridDims, blockDims>>>(dev_input_0, dev_input_1, dev_input_2, dev_output_0, dev_output_1, dev_output_2, width, height, filtr_n);
    cudaEventRecord(stop_caunting);
    cudaEventSynchronize(stop_caunting);
    cudaEventElapsedTime(&caunting_all, start_caunting, stop_caunting);
 
    cudaMemcpy(output_image_0, dev_output_0, width*height*sizeof(unsigned char), cudaMemcpyDeviceToHost );
    cudaMemcpy(output_image_1, dev_output_1, width*height*sizeof(unsigned char), cudaMemcpyDeviceToHost );
    cudaMemcpy(output_image_2, dev_output_2, width*height*sizeof(unsigned char), cudaMemcpyDeviceToHost );
 

 
    cudaEventRecord(all_stop);
    cudaEventSynchronize(all_stop);
    cudaEventElapsedTime(&all_all, all_start, all_stop);
    where_0 = 0;
    where_1 = 0;
    where_2 = 0;
    vector<unsigned char> out_image;
    for(int i = 0; i < in_image.size(); ++i) {
        if(i % 4 == 0){
            out_image.push_back(output_image_0[where_0]);
            where_0++;
        }
        if(i % 4 == 1){
            out_image.push_back(output_image_1[where_1]);
            where_1++;
        }
        if(i % 4 == 2){
            out_image.push_back(output_image_2[where_2]);
            where_2++;
        }
        if(i % 4 == 3){
            out_image.push_back(255);
        }
    }
 
    error = lodepng::encode(output_file, out_image, width, height);
 
 
   // cout <<"caunting: " <<caunting_all << endl;
   // cout << "all time "<< all_all << endl;
}
 
 




















void funks(const char* input_file, const char* input_file2, const char* input_file3, const char* output_file, int filtr_n){
    cudaStream_t stream;
    cudaStreamCreate(&stream);
    
    vector<unsigned char> in_image;
    vector<unsigned char> in_image2;
    vector<unsigned char> in_image3;

    unsigned int width, height;
    // Load the data
    unsigned error = lodepng::decode(in_image, width, height, input_file);
    error = lodepng::decode(in_image2, width, height, input_file2);
    error = lodepng::decode(in_image3, width, height, input_file3);


    float all_all = 0;
    float caunting_all = 0;
    cudaEvent_t all_start;
    cudaEvent_t all_stop;
    cudaEvent_t start_caunting;
    cudaEvent_t stop_caunting;
    cudaEventCreate(&all_start);
    cudaEventCreate(&all_stop);
    cudaEventCreate(&start_caunting);
    cudaEventCreate(&stop_caunting);
 
 
    // Prepare the data
    
    unsigned char* input_image_0 = new unsigned char[3*(in_image.size())/4];
    unsigned char* input_image_1 = new unsigned char[3*(in_image.size())/4];
    unsigned char* input_image_2 = new unsigned char[3*(in_image.size())/4];
 
    unsigned char* output_image_0 = new unsigned char[3*(in_image.size())/4];
    unsigned char* output_image_1 = new unsigned char[3*(in_image.size())/4];
    unsigned char* output_image_2 = new unsigned char[3*(in_image.size())/4];
    
    int where_0 = 0;
    int where_1 = 0;
    int where_2 = 0;

    
    for(int i = 0; i < in_image.size(); ++i) {
        if(i % 4 == 0){
            input_image_0[where_0] = in_image.at(i);
            where_0++;
        }
        if(i % 4 == 1){
            input_image_1[where_1] = in_image.at(i);
            where_1++;
        }
        if(i % 4 == 2){
            input_image_2[where_2] = in_image.at(i);
            where_2++;
        }
    }
    for(int i = 0; i < in_image2.size(); ++i) {
        if(i % 4 == 0){
            input_image_0[where_0] = in_image2.at(i);
            where_0++;
        }
        if(i % 4 == 1){
            input_image_1[where_1] = in_image2.at(i);
            where_1++;
        }
        if(i % 4 == 2){
            input_image_2[where_2] = in_image2.at(i);
            where_2++;
        }
    }
    for(int i = 0; i < in_image3.size(); ++i) {
        if(i % 4 == 0){
            input_image_0[where_0] = in_image3.at(i);
            where_0++;
        }
        if(i % 4 == 1){
            input_image_1[where_1] = in_image3.at(i);
            where_1++;
        }
        if(i % 4 == 2){
            input_image_2[where_2] = in_image3.at(i);
            where_2++;
        }
    }
 
    cudaEventRecord(all_start);
    cudaEventSynchronize(all_start);
 
 
    unsigned char* dev_input_0;
    unsigned char* dev_input_1;
    unsigned char* dev_input_2;

    unsigned char* dev_output_0;
    unsigned char* dev_output_1;
    unsigned char* dev_output_2;

    width = width * 3;
    cudaMalloc( (void**) &dev_input_0, width*height*sizeof(unsigned char));
    cudaMalloc( (void**) &dev_input_1, width*height*sizeof(unsigned char));
    cudaMalloc( (void**) &dev_input_2, width*height*sizeof(unsigned char));
    cudaMalloc( (void**) &dev_output_0, width*height*sizeof(unsigned char));
    cudaMalloc( (void**) &dev_output_1, width*height*sizeof(unsigned char));
    cudaMalloc( (void**) &dev_output_2, width*height*sizeof(unsigned char));
    cudaMemcpyAsync( dev_input_0, input_image_0, width*height*sizeof(unsigned char), cudaMemcpyHostToDevice, stream ); 
    cudaMemcpyAsync( dev_input_1, input_image_1, width*height*sizeof(unsigned char), cudaMemcpyHostToDevice, stream );
    cudaMemcpyAsync( dev_input_2, input_image_2, width*height*sizeof(unsigned char), cudaMemcpyHostToDevice, stream );




   
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    int help = floor(sqrt(prop.maxThreadsPerBlock));
    if(help > height){
        help = height;
    }
    if(help > width){
        help = width;
    }  
    dim3 blockDims(help, help,1);
    dim3 gridDims(ceil(width / help) * 9 , ceil(height / help), 1 );
 
 
 
    cudaEventRecord(start_caunting);
    cudaEventSynchronize(start_caunting);

    filtr<<<gridDims, blockDims, 0, stream>>>(dev_input_0, dev_input_1, dev_input_2, dev_output_0, dev_output_1, dev_output_2, width, height, filtr_n);

    cudaDeviceSynchronize();
    cudaEventRecord(stop_caunting);
    cudaEventSynchronize(stop_caunting);
    cudaEventElapsedTime(&caunting_all, start_caunting, stop_caunting);
    
    cudaMemcpyAsync(output_image_0, dev_output_0, width*height*sizeof(unsigned char), cudaMemcpyDeviceToHost , stream);
    cudaMemcpyAsync(output_image_1, dev_output_1, width*height*sizeof(unsigned char), cudaMemcpyDeviceToHost , stream);
    cudaMemcpyAsync(output_image_2, dev_output_2, width*height*sizeof(unsigned char), cudaMemcpyDeviceToHost , stream);   
    

 
    cudaEventRecord(all_stop);
    cudaEventSynchronize(all_stop);
    cudaEventElapsedTime(&all_all, all_start, all_stop);
    where_0 = 0;
    where_1 = 0;
    where_2 = 0;
    vector<unsigned char> out_image;
    vector<unsigned char> out_image2;
    vector<unsigned char> out_image3;

    for(int i = 0; i < in_image.size(); ++i) {
        if(i % 4 == 0){
            out_image.push_back(output_image_0[where_0]);
            where_0++;
        }
        if(i % 4 == 1){
            out_image.push_back(output_image_1[where_1]);
            where_1++;
        }
        if(i % 4 == 2){
            out_image.push_back(output_image_2[where_2]);
            where_2++;
        }
        if(i % 4 == 3){
            out_image.push_back(255);
        }
    }
    for(int i = 0; i < in_image.size(); ++i) {
        if(i % 4 == 0){
            out_image2.push_back(output_image_0[where_0]);
            where_0++;
        }
        if(i % 4 == 1){
            out_image2.push_back(output_image_1[where_1]);
            where_1++;
        }
        if(i % 4 == 2){
            out_image2.push_back(output_image_2[where_2]);
            where_2++;
        }
        if(i % 4 == 3){
            out_image2.push_back(255);
        }
    }
    for(int i = 0; i < in_image.size(); ++i) {
        if(i % 4 == 0){
            out_image3.push_back(output_image_0[where_0]);
            where_0++;
        }
        if(i % 4 == 1){
            out_image3.push_back(output_image_1[where_1]);
            where_1++;
        }
        if(i % 4 == 2){
            out_image3.push_back(output_image_2[where_2]);
            where_2++;
        }
        if(i % 4 == 3){
            out_image3.push_back(255);
        }
    }
    const char* output_file2 = "2_out.png";
    const char* output_file3 = "3_out.png";

    error = lodepng::encode(output_file, out_image, width/3, height);
    error = lodepng::encode(output_file2, out_image2, width/3, height);
    error = lodepng::encode(output_file3, out_image3, width/3, height);
 //   cout <<"caunting: " <<caunting_all << endl;
   // cout << "all time "<< all_all << endl; 
}
 
 
 
 
 
 
 
 
int main(int argc, char** argv) {
    string cern = argv[1];
    string size = argv[2];
    const char* input_file;
    const char* output_file;
    // Read the arguments
    int filtr_n = 0;
    if(cern == "blur5"){
        filtr_n = 1;
    }
    else if(cern == "blur"){
        filtr_n = 2;
    }
    else if(cern == "edge_detection"){
        filtr_n = 3;
    }
    if(size == "small"){
        for(int i = 0; i < 1; i++){
            smalll = 1; 
            const char* input_file2 = "2.png";        
            const char* input_file3 = "3.png";
            input_file = "1.png";
            output_file = "1_out.png";
            funks(input_file,input_file2, input_file3, output_file, filtr_n);
        }
    }
    else{
        input_file = "big.png";
        output_file = "big_out.png";
        funk(input_file, output_file, filtr_n);
    }
 
    return 0;
}