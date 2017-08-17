//
//  Constants_Log.h
//  AtHomeCam
//
//  Created by lvyi on 12/18/15.
//  Copyright © 2015 ichano. All rights reserved.
//

#ifndef Constants_Log_h
#define Constants_Log_h


#define APP_LOG_ERR(_pucFormat, ...)  [[Rvs_Viewer defaultViewer] logWithLogLevel:EN_RVS_LOG_LEVEL_ERROR LogFormat:_pucFormat, ##__VA_ARGS__]

#define APP_LOG_WARN(_pucFormat, ...) [[Rvs_Viewer defaultViewer] logWithLogLevel:EN_RVS_LOG_LEVEL_WARNNING LogFormat:_pucFormat, ##__VA_ARGS__]

#define APP_LOG_INF(_pucFormat, ...)  [[Rvs_Viewer defaultViewer] logWithLogLevel:EN_RVS_LOG_LEVEL_INFO LogFormat:_pucFormat, ##__VA_ARGS__]

#define APP_LOG_DBG(_pucFormat, ...)  [[Rvs_Viewer defaultViewer] logWithLogLevel:EN_RVS_LOG_LEVEL_DEBUG LogFormat:_pucFormat, ##__VA_ARGS__]



#endif /* Constants_Log_h */
