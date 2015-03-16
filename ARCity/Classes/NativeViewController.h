// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import <metaioSDK/MetaioSDKViewController.h>

@interface NativeViewController : MetaioSDKViewController
{
	metaio::IGeometry* m_earth;			//!< Reference to  the earth model
	metaio::IGeometry* m_earthOcclusion;			//!< Reference to  the earth occlusion model
	metaio::IGeometry* m_earthIndicators;			//!< Reference to  the earth indicators model

	BOOL m_earthOpened;					 // has the earth open animation been triggered
}

@end
