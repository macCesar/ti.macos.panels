/**
 * ti.macos.panels
 *
 * Created by César Estrada
 * Copyright (c) 2026 César Estrada. All rights reserved.
 */

#import "TiModule.h"

@interface TiMacosPanelsModule : TiModule

- (id)pickFolder:(id)args;
- (id)pickFile:(id)args;
- (id)pickFiles:(id)args;
- (id)openDocument:(id)args;
- (id)openDocuments:(id)args;
- (id)saveFile:(id)args;

@end
