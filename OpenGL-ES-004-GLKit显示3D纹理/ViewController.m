//
//  ViewController.m
//  OpenGL-ES-004-GLKit显示3D纹理
//
//  Created by zhongding on 2019/1/7.
//

#import "ViewController.h"

#import "sphere.h"

@interface ViewController ()
{
    EAGLContext *context;
    GLKBaseEffect *effect;
    
    GLKTextureInfo *earthInfo;
    GLKTextureInfo *moonInfo;
    GLKTextureInfo *sonInfo;

    
    GLKMatrix4 projectionMatrix1;
    GLKMatrix4 projectionMatrix2;
    
    GLKMatrixStackRef matrixStack;
    
    CGFloat earthRot;
    CGFloat moonRot;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setupContext];
    [self setupEffect];
}

//初始化GLKBaseEffect
- (void)setupEffect{
  
    
    effect = [[GLKBaseEffect alloc] init];
    effect.texture2d0.enabled = YES;
    
    [self setupLight];
    [self setupBuffer];
    [self setupTexureinfo];
    
    
    //模型视图矩阵
    effect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);

    //投影矩阵
    CGFloat aspect = self.view.frame.size.width/self.view.frame.size.height;
    projectionMatrix1 = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35), aspect, 1, 15);
    projectionMatrix2 = GLKMatrix4MakeOrtho(-1.5 * aspect, 1.5 * aspect, -1.5, 1.50, 10.0, 80.0f);
    effect.transform.projectionMatrix = projectionMatrix1;
    
    //初始化矩阵堆栈
    matrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    GLKMatrixStackLoadMatrix4(matrixStack, effect.transform.modelviewMatrix);
    
}

//坐标信息
- (void)setupBuffer{
    GLuint vertexBuffer,textureCoordBuffer,normalBuffer;
    
    //顶点坐标
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereVerts), sphereVerts, GL_STATIC_DRAW);
    
    
    //顶点坐标信息读取
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLfloat*)NULL+0);
    
    //纹理坐标
    glGenBuffers(1, &textureCoordBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, textureCoordBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereTexCoords), sphereTexCoords, GL_STATIC_DRAW);

    
    //纹理坐标信息读取
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, (GLfloat*)NULL+0);
    
    //法线
    glGenBuffers(1, &normalBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, normalBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereNormals), sphereNormals, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, NULL);
    
}

//光照信息
- (void)setupLight{
    //开启光照
    effect.light0.enabled = GL_TRUE;
    
    /*
     union _GLKVector4
     {
     struct { float x, y, z, w; };
     struct { float r, g, b, a; };
     struct { float s, t, p, q; };
     float v[4];
     } __attribute__((aligned(16)));
     typedef union _GLKVector4 GLKVector4;
     
     union共用体
     有3个结构体，
     比如表示顶点坐标的x,y,z,w
     比如表示颜色的，RGBA;
     表示纹理的stpq
     
     */
    //2.设置漫射光颜色
    effect.light0.diffuseColor = GLKVector4Make(
                                                         1.00f,//Red
                                                         1.0f,//Green
                                                         1.0f,//Blue
                                                         1.0f);//Alpha
    /*
     The position of the light in world coordinates.
     世界坐标中的光的位置。
     If the w component of the position is 0.0, the light is calculated using the directional light formula. The x, y, and z components of the vector specify the direction the light shines. The light is assumed to be infinitely far away; attenuation and spotlight properties are ignored.
     如果位置的w分量为0，则使用定向光公式计算光。向量的x、y和z分量指定光的方向。光被认为是无限远的，衰减和聚光灯属性被忽略。
     If the w component of the position is a non-zero value, the coordinates specify the position of the light in homogenous coordinates, and the light is either calculated as a point light or a spotlight, depending on the value of the spotCutoff property.
     如果该位置的W组件是一个非零的值，指定的坐标的光在齐次坐标的位置，和光是一个点光源和聚光灯计算，根据不同的spotcutoff属性的值
     The default value is [0.0, 0.0, 1.0, 0.0].
     默认值[0.0f,0.0f,1.0f,0.0f];
     */
    
    effect.light0.position = GLKVector4Make(
                                                     1.0f, //x
                                                     0.0f, //y
                                                     0.8f, //z
                                                     0.0f);//w
    
    //光的环境部分
    effect.light0.ambientColor = GLKVector4Make(
                                                         0.0f,//Red
                                                         0.0f,//Green
                                                         0.0f,//Blue
                                                         1.0f);//Alpha
    
}

//纹理信息
- (void)setupTexureinfo{
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"1",GLKTextureLoaderOriginBottomLeft, nil];
    
    //地球纹理
    CGImageRef earthImage = [UIImage imageNamed:@"Earth512x256.jpg"].CGImage;
    earthInfo = [GLKTextureLoader textureWithCGImage:earthImage options:options error:nil];
    
    //月亮纹理
    CGImageRef moonImage = [UIImage imageNamed:@"Moon256x128.png"].CGImage;
    moonInfo = [GLKTextureLoader textureWithCGImage:moonImage options:options error:nil];
    
    
    CGImageRef sonImage = [UIImage imageNamed:@"son.jpg"].CGImage;
    sonInfo = [GLKTextureLoader textureWithCGImage:sonImage options:options error:nil];
}

//上下文
- (void)setupContext{
    context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    
    GLKView *view = (GLKView*)self.view;
    view.context = context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:context];
    
    glEnable(GL_DEPTH_TEST);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    moonRot += (360/60.0/28.0);
    earthRot += (360/12.0/365.0);
    
    //[self drawSon];
    [self drawEarth];
    [self drawMoon];
}

- (void)drawSon{
    
    effect.texture2d0.name = sonInfo.name;
    
    GLKMatrixStackPush(matrixStack);
    
    effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(matrixStack);
    [effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);

    GLKMatrixStackPop(matrixStack);
    
    effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(matrixStack);
}

- (void)drawEarth{
    effect.texture2d0.name = earthInfo.name;
    GLKMatrixStackPush(matrixStack);
    
    //自转
    GLKMatrixStackRotateY(matrixStack, GLKMathDegreesToRadians(earthRot));

//    //地球相对于太阳的大小
//    GLKMatrixStackScale(matrixStack, 0.4, 0.4, 0.4);
//
//    //太阳与地球的距离
//    GLKMatrixStackTranslate(matrixStack, 0.5, 0, 2);
//
//    //公转
//    GLKMatrixStackRotateX(matrixStack, GLKMathDegreesToRadians(earthRot));

    //更新模型视图矩阵
    effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(matrixStack);

    //绘制
    [effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    GLKMatrixStackPop(matrixStack);

    effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(matrixStack);
}

- (void)drawMoon{
    effect.texture2d0.name = moonInfo.name;
    
    GLKMatrixStackPush(matrixStack);
    
    //缩小
    GLKMatrixStackScale(matrixStack, 0.2, 0.2, 0.2);

    //自转
    GLKMatrixStackRotateY(matrixStack,GLKMathDegreesToRadians(moonRot-60));

    //距离地球的距离
    GLKMatrixStackTranslate(matrixStack,1, 0, 5);

    //公转
    GLKMatrixStackRotateY(matrixStack, GLKMathDegreesToRadians(moonRot));
    
    effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(matrixStack);
    
    //绘制
    [effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    GLKMatrixStackPop(matrixStack);
    effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(matrixStack);
}

- (IBAction)swithChange:(UISwitch*)sender {
    
    if (sender.on) {
        effect.transform.projectionMatrix = projectionMatrix1;
    }else{
        effect.transform.projectionMatrix = projectionMatrix2;
    }
}


@end
