//
//  EAGLView.m
//
// Copyright 2007-2013 metaio GmbH. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <metaioSDK/IMetaioSDKIOS.h>
#import "EAGLView.h"


@interface EAGLView (PrivateMethods)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end


@implementation EAGLView
@synthesize context;


// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:.
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
	if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        self.contentScaleFactor = [UIScreen mainScreen].scale;
    }
    
    supportAntialiasing = [self enableAntialiasing];
    
    return self;
}

- (void)dealloc
{
    [self deleteFramebuffer];    
    [context release];
   
    [super dealloc];
}

- (void)setContext:(EAGLContext *)newContext
{
    if (context != newContext) {
        [self deleteFramebuffer];
        
        [context release];
        context = [newContext retain];
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFramebuffer
{
	// early exit
    if (!context || defaultFramebuffer)
		return;
        
	// Create default framebuffer object.
	glGenFramebuffers(1, &defaultFramebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	
	// Create color render buffer and allocate backing store.
	glGenRenderbuffers(1, &colorRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
	
	
	// create depth buffer
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT24_OES, framebufferWidth, framebufferHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
	
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));

	
}

- (void)createFramebufferAntialiased
{
	// early exit
    if (!context || defaultFramebuffer)
		return;
	
	[EAGLContext setCurrentContext:context];
    
	//Anti Aliasing
	//create Render buffers
	glGenFramebuffersOES(1, &defaultFramebuffer);
	glGenRenderbuffersOES(1, &colorRenderbuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER_OES
					fromDrawable:(CAEAGLLayer*)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
								 GL_COLOR_ATTACHMENT0_OES,
								 GL_RENDERBUFFER_OES,
								 colorRenderbuffer);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
									GL_RENDERBUFFER_WIDTH_OES, &framebufferWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
									GL_RENDERBUFFER_HEIGHT_OES, &framebufferHeight);
	
	//create MSAA buffer
	glGenFramebuffersOES(1, &msaaFramebuffer);
	glGenRenderbuffersOES(1, &msaaRenderBuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaRenderBuffer);
	// Samples is the amount of pixels the MSAA buffer uses to make one pixel on the render
	// buffer. Use a small number like 2 for the 3G and below and 4 or more for newer models
	glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, 2, GL_RGB5_A1_OES,
										  framebufferWidth, framebufferHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES,
								 GL_RENDERBUFFER_OES, msaaRenderBuffer);
	glGenRenderbuffersOES(1, &msaaDepthBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaDepthBuffer);
	glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, 2,
										  GL_DEPTH_COMPONENT24_OES, framebufferWidth , framebufferHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES,
								 GL_RENDERBUFFER_OES, msaaDepthBuffer);
		
}

- (void)deleteFramebuffer
{
	// early exit
    if (!context)
		return;
	
    [EAGLContext setCurrentContext:context];
	
	if (supportAntialiasing)
    {
        
        if (defaultFramebuffer) {
            glDeleteFramebuffersOES(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffersOES(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if(msaaFramebuffer)
        {
            glDeleteFramebuffersOES(1, &msaaFramebuffer);
            msaaFramebuffer = 0;
        }
        
        if(msaaRenderBuffer)
        {
            glDeleteRenderbuffersOES(1, &msaaRenderBuffer);
            msaaRenderBuffer = 0;
        }
        
        if(msaaDepthBuffer)
        {
            glDeleteRenderbuffersOES(1, &msaaDepthBuffer);
            msaaDepthBuffer = 0;
        }
        
    }
    else
    {
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if(depthRenderbuffer)
        {
            glDeleteRenderbuffersOES(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}

- (void)setFramebuffer
{
	// early exit
    if (!context)
		return;
	
	[EAGLContext setCurrentContext:context];
	
	// use antialised if enabled
	if (supportAntialiasing)
	{
		if (!defaultFramebuffer)
			[self createFramebufferAntialiased];
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer); //Bind MSAA
	}
	else
	{
		if (!defaultFramebuffer)
			[self createFramebuffer];
		glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	}
	
	glViewport(0, 0, framebufferWidth, framebufferHeight);
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
	// early exit
    if (!context)
		return FALSE;
	
	[EAGLContext setCurrentContext:context];
    
    if (supportAntialiasing)
    {
		glBindFramebufferOES(GL_READ_FRAMEBUFFER_APPLE, msaaFramebuffer);
		glBindFramebufferOES(GL_DRAW_FRAMEBUFFER_APPLE, defaultFramebuffer);
		// Call a resolve to combine buffers
		glResolveMultisampleFramebufferAPPLE();
		// Present final image to screen
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
		success = [context presentRenderbuffer:GL_RENDERBUFFER_OES];
	}
	else
	{
		glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
		success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }

    return success;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

- (BOOL)enableAntialiasing
{

    BOOL result;
    
    metaio::E_IOS_DEVICETYPE currentDevice = metaio::getDeviceType();
	switch( currentDevice )
	{
		case metaio::EID_IPHONEOLD__UNSUPPORTED:
		case metaio::EID_IPHONE3GS:
		case metaio::EID_IPHONE4:
		case metaio::EID_IPAD__UNSUPPORTED:
		case metaio::EID_IPODOLD__UNSUPPORTED:
		case metaio::EID_IPOD4:
        case metaio::EID_IPAD2:
		{
			result = false;
		}
			break;

			default:
		{
			result = true;
		}
			break;
	}
    
    NSLog(@"Anti-Aliasing is %i", result);
    return result;
}


@end
