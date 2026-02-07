/**
 * ti.macos.panels
 *
 * Created by César Estrada
 * Copyright (c) 2026 César Estrada. All rights reserved.
 */

#import "TiMacosPanelsModule.h"
#import "KrollCallback.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import <TargetConditionals.h>
#import <objc/message.h>

static NSString *const TFPPanelOpen = @"open";
static NSString *const TFPPanelSave = @"save";

static NSString *const TFPCodeNotSupported = @"ERR_NOT_SUPPORTED_PLATFORM";
static NSString *const TFPCodeInvalidOptions = @"ERR_INVALID_OPTIONS";
static NSString *const TFPCodePanelUnavailable = @"ERR_PANEL_UNAVAILABLE";
static NSString *const TFPCodeUserCancelled = @"ERR_USER_CANCELLED";
static NSString *const TFPCodeNoSelection = @"ERR_NO_SELECTION";
static NSString *const TFPCodeInvalidStartDirectory = @"ERR_INVALID_START_DIRECTORY";

@implementation TiMacosPanelsModule

#pragma mark Internal

// This is generated for your module, please do not change it
- (id)moduleGUID
{
  return @"18254a0c-de55-48b9-8e00-e881d4466d9e";
}

// This is generated for your module, please do not change it
- (NSString *)moduleId
{
  return @"ti.macos.panels";
}

#pragma mark Lifecycle

- (void)startup
{
  [super startup];
  DebugLog(@"[DEBUG] %@ loaded", self);
}

#pragma mark Helpers

- (KrollCallback *)callbackFromArgs:(id)args
{
  if ([args isKindOfClass:[KrollCallback class]]) {
    return (KrollCallback *)args;
  }

  if (![args isKindOfClass:[NSArray class]]) {
    return nil;
  }

  for (id entry in (NSArray *)args) {
    if ([entry isKindOfClass:[KrollCallback class]]) {
      return (KrollCallback *)entry;
    }
  }

  return nil;
}

- (id)rawOptionsFromArgs:(id)args
{
  if (args == nil || args == [NSNull null]) {
    return nil;
  }

  if ([args isKindOfClass:[NSDictionary class]]) {
    return args;
  }

  if ([args isKindOfClass:[NSArray class]]) {
    NSArray *argArray = (NSArray *)args;
    if (argArray.count == 0) {
      return nil;
    }

    id firstArg = [argArray objectAtIndex:0];
    if ([firstArg isKindOfClass:[KrollCallback class]]) {
      return nil;
    }

    return firstArg;
  }

  return args;
}

- (void)fireCallback:(KrollCallback *)callback withEvent:(NSDictionary *)event
{
  if (callback == nil) {
    return;
  }

  NSDictionary *payload = event != nil ? event : @{};
  [callback callAsync:@[ payload ] thisObject:nil];
}

- (id)dispatchResultObject:(NSDictionary *)result callback:(KrollCallback *)callback
{
  if (callback != nil) {
    [self fireCallback:callback withEvent:result];
    return nil;
  }

  return result;
}

- (NSDictionary *)normalizedFilePartsForPath:(NSString *)path
{
  if (path == nil || path.length == 0) {
    return @{ @"fileName" : [NSNull null], @"extension" : [NSNull null] };
  }

  NSString *fileName = [path lastPathComponent];
  NSString *extension = [path pathExtension];

  return @{
    @"fileName" : (fileName.length > 0 ? fileName : (id)[NSNull null]),
    @"extension" : (extension.length > 0 ? extension : (id)[NSNull null])
  };
}

- (NSDictionary *)resultWithSuccess:(BOOL)success
                          cancelled:(BOOL)cancelled
                               code:(NSString *)code
                            message:(NSString *)message
                              panel:(NSString *)panel
                      selectionType:(NSString *)selectionType
                               path:(NSString *)path
                              paths:(NSArray *)paths
{
  NSMutableArray<NSString *> *normalizedPaths = [NSMutableArray array];
  if ([paths isKindOfClass:[NSArray class]]) {
    for (id value in paths) {
      if ([value isKindOfClass:[NSString class]] && [(NSString *)value length] > 0) {
        [normalizedPaths addObject:(NSString *)value];
      }
    }
  }

  NSString *normalizedPath = nil;
  if ([path isKindOfClass:[NSString class]] && path.length > 0) {
    normalizedPath = path;
  } else if (normalizedPaths.count == 1) {
    normalizedPath = [normalizedPaths firstObject];
  }

  if (normalizedPath != nil && normalizedPaths.count == 0) {
    [normalizedPaths addObject:normalizedPath];
  }

  NSDictionary *fileParts = [self normalizedFilePartsForPath:normalizedPath];

  return @{
    @"success" : @(success),
    @"cancelled" : @(cancelled),
    @"canceled" : @(cancelled),
    @"code" : (code != nil ? code : (id)[NSNull null]),
    @"message" : (message != nil ? message : (id)[NSNull null]),
    @"panel" : (panel != nil ? panel : (id)[NSNull null]),
    @"selectionType" : (selectionType != nil ? selectionType : (id)[NSNull null]),
    @"path" : (normalizedPath != nil ? normalizedPath : (id)[NSNull null]),
    @"paths" : normalizedPaths,
    @"fileName" : [fileParts objectForKey:@"fileName"],
    @"extension" : [fileParts objectForKey:@"extension"]
  };
}

- (NSDictionary *)errorResultWithCode:(NSString *)code
                              message:(NSString *)message
                                panel:(NSString *)panel
                        selectionType:(NSString *)selectionType
                            cancelled:(BOOL)cancelled
{
  return [self resultWithSuccess:NO
                       cancelled:cancelled
                            code:code
                         message:message
                           panel:panel
                   selectionType:selectionType
                            path:nil
                           paths:@[]];
}

- (NSDictionary *)successResultWithPanel:(NSString *)panel selectionType:(NSString *)selectionType path:(NSString *)path paths:(NSArray *)paths
{
  return [self resultWithSuccess:YES
                       cancelled:NO
                            code:nil
                         message:nil
                           panel:panel
                   selectionType:selectionType
                            path:path
                           paths:paths];
}

- (BOOL)validateStringOption:(NSString *)key options:(NSDictionary *)options errorMessage:(NSString **)errorMessage
{
  id value = [options objectForKey:key];
  if (value == nil || value == [NSNull null]) {
    return YES;
  }

  if (![value isKindOfClass:[NSString class]]) {
    if (errorMessage != NULL) {
      *errorMessage = [NSString stringWithFormat:@"Option '%@' must be a string.", key];
    }
    return NO;
  }

  return YES;
}

- (BOOL)validateBooleanOption:(NSString *)key options:(NSDictionary *)options errorMessage:(NSString **)errorMessage
{
  id value = [options objectForKey:key];
  if (value == nil || value == [NSNull null]) {
    return YES;
  }

  if (![value isKindOfClass:[NSNumber class]]) {
    if (errorMessage != NULL) {
      *errorMessage = [NSString stringWithFormat:@"Option '%@' must be a boolean.", key];
    }
    return NO;
  }

  return YES;
}

- (BOOL)validateStringOrStringArrayOption:(NSString *)key options:(NSDictionary *)options errorMessage:(NSString **)errorMessage
{
  id value = [options objectForKey:key];
  if (value == nil || value == [NSNull null]) {
    return YES;
  }

  if ([value isKindOfClass:[NSString class]]) {
    NSString *trimmed = [(NSString *)value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0) {
      if (errorMessage != NULL) {
        *errorMessage = [NSString stringWithFormat:@"Option '%@' cannot be empty.", key];
      }
      return NO;
    }
    return YES;
  }

  if (![value isKindOfClass:[NSArray class]]) {
    if (errorMessage != NULL) {
      *errorMessage = [NSString stringWithFormat:@"Option '%@' must be a string or string array.", key];
    }
    return NO;
  }

  for (id entry in (NSArray *)value) {
    if (![entry isKindOfClass:[NSString class]]) {
      if (errorMessage != NULL) {
        *errorMessage = [NSString stringWithFormat:@"Option '%@' must contain only strings.", key];
      }
      return NO;
    }

    NSString *trimmed = [(NSString *)entry stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0) {
      if (errorMessage != NULL) {
        *errorMessage = [NSString stringWithFormat:@"Option '%@' contains an empty value.", key];
      }
      return NO;
    }
  }

  return YES;
}

- (NSDictionary *)validatedOptionsFromRaw:(id)rawOptions errorMessage:(NSString **)errorMessage
{
  if (rawOptions == nil || rawOptions == [NSNull null]) {
    return @{};
  }

  if (![rawOptions isKindOfClass:[NSDictionary class]]) {
    if (errorMessage != NULL) {
      *errorMessage = @"Options must be an object.";
    }
    return nil;
  }

  NSDictionary *options = (NSDictionary *)rawOptions;

  if (![self validateStringOption:@"title" options:options errorMessage:errorMessage]) {
    return nil;
  }
  if (![self validateStringOption:@"prompt" options:options errorMessage:errorMessage]) {
    return nil;
  }
  if (![self validateStringOption:@"directoryURL" options:options errorMessage:errorMessage]) {
    return nil;
  }
  if (![self validateStringOption:@"defaultName" options:options errorMessage:errorMessage]) {
    return nil;
  }
  if (![self validateStringOption:@"defaultExtension" options:options errorMessage:errorMessage]) {
    return nil;
  }

  if (![self validateBooleanOption:@"showHiddenFiles" options:options errorMessage:errorMessage]) {
    return nil;
  }
  if (![self validateBooleanOption:@"canCreateDirectories" options:options errorMessage:errorMessage]) {
    return nil;
  }
  if (![self validateBooleanOption:@"resolvesAliases" options:options errorMessage:errorMessage]) {
    return nil;
  }
  if (![self validateBooleanOption:@"allowMultiple" options:options errorMessage:errorMessage]) {
    return nil;
  }

  if (![self validateStringOrStringArrayOption:@"allowedExtensions" options:options errorMessage:errorMessage]) {
    return nil;
  }
  if (![self validateStringOrStringArrayOption:@"allowedContentTypes" options:options errorMessage:errorMessage]) {
    return nil;
  }

  return options;
}

- (NSString *)stringOptionForKey:(NSString *)key options:(NSDictionary *)options
{
  if (options == nil || key.length == 0) {
    return nil;
  }

  id rawValue = [options objectForKey:key];
  if (rawValue == nil || rawValue == [NSNull null]) {
    return nil;
  }

  NSString *value = [TiUtils stringValue:rawValue];
  if (![value isKindOfClass:[NSString class]]) {
    return nil;
  }

  NSString *trimmedValue = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  return trimmedValue.length > 0 ? trimmedValue : nil;
}

- (NSDictionary *)validateStartDirectoryInOptions:(NSDictionary *)options panel:(NSString *)panel selectionType:(NSString *)selectionType
{
  NSString *directoryPath = [self stringOptionForKey:@"directoryURL" options:options];
  if (directoryPath.length == 0) {
    return nil;
  }

  BOOL isDirectory = NO;
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory];
  if (!exists || !isDirectory) {
    return [self errorResultWithCode:TFPCodeInvalidStartDirectory
                             message:@"Option 'directoryURL' must point to an existing directory path."
                               panel:panel
                       selectionType:selectionType
                           cancelled:NO];
  }

  return nil;
}

- (NSArray<NSString *> *)allowedExtensionsFromOptions:(NSDictionary *)options
{
  id rawValue = [options objectForKey:@"allowedExtensions"];
  if (rawValue == nil) {
    return nil;
  }

  NSMutableArray<NSString *> *extensions = [NSMutableArray array];
  if ([rawValue isKindOfClass:[NSString class]]) {
    NSString *extension = [(NSString *)rawValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([extension hasPrefix:@"."]) {
      extension = [extension substringFromIndex:1];
    }
    if (extension.length > 0) {
      [extensions addObject:extension];
    }
    return extensions.count > 0 ? extensions : nil;
  }

  if (![rawValue isKindOfClass:[NSArray class]]) {
    return nil;
  }

  for (id entry in (NSArray *)rawValue) {
    if (![entry isKindOfClass:[NSString class]]) {
      continue;
    }

    NSString *extension = [(NSString *)entry stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([extension hasPrefix:@"."]) {
      extension = [extension substringFromIndex:1];
    }
    if (extension.length > 0) {
      [extensions addObject:extension];
    }
  }

  return extensions.count > 0 ? extensions : nil;
}

- (NSArray *)allowedContentTypesFromOptions:(NSDictionary *)options
{
  id rawValue = [options objectForKey:@"allowedContentTypes"];
  if (rawValue == nil) {
    return nil;
  }

  NSMutableArray<NSString *> *identifiers = [NSMutableArray array];
  if ([rawValue isKindOfClass:[NSString class]]) {
    NSString *identifier = [(NSString *)rawValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (identifier.length > 0) {
      [identifiers addObject:identifier];
    }
  } else if ([rawValue isKindOfClass:[NSArray class]]) {
    for (id entry in (NSArray *)rawValue) {
      if (![entry isKindOfClass:[NSString class]]) {
        continue;
      }
      NSString *identifier = [(NSString *)entry stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      if (identifier.length > 0) {
        [identifiers addObject:identifier];
      }
    }
  }

  if (identifiers.count == 0) {
    return nil;
  }

  Class utTypeClass = NSClassFromString(@"UTType");
  SEL typeWithIdentifierSelector = NSSelectorFromString(@"typeWithIdentifier:");
  if (utTypeClass == nil || typeWithIdentifierSelector == nil || ![utTypeClass respondsToSelector:typeWithIdentifierSelector]) {
    return nil;
  }

  NSMutableArray *contentTypes = [NSMutableArray arrayWithCapacity:identifiers.count];
  for (NSString *identifier in identifiers) {
    id utType = ((id (*)(id, SEL, id))objc_msgSend)(utTypeClass, typeWithIdentifierSelector, identifier);
    if (utType != nil) {
      [contentTypes addObject:utType];
    }
  }

  return contentTypes.count > 0 ? contentTypes : nil;
}

- (void)applyCommonPanelOptions:(id)panel options:(NSDictionary *)options
{
  NSString *title = [self stringOptionForKey:@"title" options:options];
  if (title.length > 0 && [panel respondsToSelector:@selector(setTitle:)]) {
    ((void (*)(id, SEL, id))objc_msgSend)(panel, @selector(setTitle:), title);
  }

  NSString *prompt = [self stringOptionForKey:@"prompt" options:options];
  if (prompt.length > 0 && [panel respondsToSelector:@selector(setPrompt:)]) {
    ((void (*)(id, SEL, id))objc_msgSend)(panel, @selector(setPrompt:), prompt);
  }

  NSString *directoryPath = [self stringOptionForKey:@"directoryURL" options:options];
  if (directoryPath.length > 0 && [panel respondsToSelector:@selector(setDirectoryURL:)]) {
    NSURL *directoryURL = [NSURL fileURLWithPath:directoryPath];
    ((void (*)(id, SEL, id))objc_msgSend)(panel, @selector(setDirectoryURL:), directoryURL);
  }

  SEL setShowsHiddenFilesSelector = NSSelectorFromString(@"setShowsHiddenFiles:");
  if ([options objectForKey:@"showHiddenFiles"] != nil && setShowsHiddenFilesSelector != nil && [panel respondsToSelector:setShowsHiddenFilesSelector]) {
    BOOL showHiddenFiles = [TiUtils boolValue:[options objectForKey:@"showHiddenFiles"] def:NO];
    ((void (*)(id, SEL, BOOL))objc_msgSend)(panel, setShowsHiddenFilesSelector, showHiddenFiles);
  }

  SEL setCanCreateDirectoriesSelector = NSSelectorFromString(@"setCanCreateDirectories:");
  if ([options objectForKey:@"canCreateDirectories"] != nil && setCanCreateDirectoriesSelector != nil && [panel respondsToSelector:setCanCreateDirectoriesSelector]) {
    BOOL canCreateDirectories = [TiUtils boolValue:[options objectForKey:@"canCreateDirectories"] def:NO];
    ((void (*)(id, SEL, BOOL))objc_msgSend)(panel, setCanCreateDirectoriesSelector, canCreateDirectories);
  }
}

- (void)applyOpenPanelOptions:(id)panel options:(NSDictionary *)options
{
  [self applyCommonPanelOptions:panel options:options];

  BOOL resolvesAliases = YES;
  if ([options objectForKey:@"resolvesAliases"] != nil) {
    resolvesAliases = [TiUtils boolValue:[options objectForKey:@"resolvesAliases"] def:YES];
  }

  SEL setResolvesAliasesSelector = NSSelectorFromString(@"setResolvesAliases:");
  if (setResolvesAliasesSelector != nil && [panel respondsToSelector:setResolvesAliasesSelector]) {
    ((void (*)(id, SEL, BOOL))objc_msgSend)(panel, setResolvesAliasesSelector, resolvesAliases);
  }

  SEL setAllowedContentTypesSelector = NSSelectorFromString(@"setAllowedContentTypes:");
  NSArray *allowedContentTypes = [self allowedContentTypesFromOptions:options];
  if (allowedContentTypes.count > 0 && setAllowedContentTypesSelector != nil && [panel respondsToSelector:setAllowedContentTypesSelector]) {
    ((void (*)(id, SEL, id))objc_msgSend)(panel, setAllowedContentTypesSelector, allowedContentTypes);
    return;
  }

  SEL setAllowedFileTypesSelector = NSSelectorFromString(@"setAllowedFileTypes:");
  NSArray<NSString *> *allowedExtensions = [self allowedExtensionsFromOptions:options];
  if (allowedExtensions.count > 0 && setAllowedFileTypesSelector != nil && [panel respondsToSelector:setAllowedFileTypesSelector]) {
    ((void (*)(id, SEL, id))objc_msgSend)(panel, setAllowedFileTypesSelector, allowedExtensions);
  }
}

- (NSString *)pathFromURL:(id)url
{
  if (url == nil || ![url respondsToSelector:@selector(path)]) {
    return nil;
  }

  NSString *path = ((id (*)(id, SEL))objc_msgSend)(url, @selector(path));
  if (path.length == 0) {
    return nil;
  }

  return path;
}

- (NSArray<NSString *> *)pathsFromURLs:(NSArray *)urls
{
  if (urls.count == 0) {
    return @[];
  }

  NSMutableArray<NSString *> *paths = [NSMutableArray arrayWithCapacity:urls.count];
  for (id url in urls) {
    NSString *path = [self pathFromURL:url];
    if (path.length > 0) {
      [paths addObject:path];
    }
  }

  return paths;
}

- (NSDictionary *)openPanelResultWithChooseFiles:(BOOL)chooseFiles
                               chooseDirectories:(BOOL)chooseDirectories
                         allowsMultipleSelection:(BOOL)allowsMultipleSelection
                                         options:(NSDictionary *)options
                                   selectionType:(NSString *)selectionType
{
#if !TARGET_OS_MACCATALYST
  return [self errorResultWithCode:TFPCodeNotSupported
                           message:@"This method is only supported on Mac Catalyst."
                             panel:TFPPanelOpen
                     selectionType:selectionType
                         cancelled:NO];
#else
  NSDictionary *startDirectoryError = [self validateStartDirectoryInOptions:options panel:TFPPanelOpen selectionType:selectionType];
  if (startDirectoryError != nil) {
    return startDirectoryError;
  }

  Class openPanelClass = NSClassFromString(@"NSOpenPanel");
  SEL openPanelSelector = NSSelectorFromString(@"openPanel");
  if (openPanelClass == nil || openPanelSelector == nil || ![openPanelClass respondsToSelector:openPanelSelector]) {
    return [self errorResultWithCode:TFPCodePanelUnavailable
                             message:@"NSOpenPanel is unavailable in this runtime."
                               panel:TFPPanelOpen
                       selectionType:selectionType
                           cancelled:NO];
  }

  id panel = ((id (*)(id, SEL))objc_msgSend)(openPanelClass, openPanelSelector);
  if (panel == nil) {
    return [self errorResultWithCode:TFPCodePanelUnavailable
                             message:@"Could not create NSOpenPanel instance."
                               panel:TFPPanelOpen
                       selectionType:selectionType
                           cancelled:NO];
  }

  SEL setCanChooseFilesSelector = NSSelectorFromString(@"setCanChooseFiles:");
  SEL setCanChooseDirectoriesSelector = NSSelectorFromString(@"setCanChooseDirectories:");
  if (setCanChooseFilesSelector != nil && [panel respondsToSelector:setCanChooseFilesSelector]) {
    ((void (*)(id, SEL, BOOL))objc_msgSend)(panel, setCanChooseFilesSelector, chooseFiles);
  }
  if (setCanChooseDirectoriesSelector != nil && [panel respondsToSelector:setCanChooseDirectoriesSelector]) {
    ((void (*)(id, SEL, BOOL))objc_msgSend)(panel, setCanChooseDirectoriesSelector, chooseDirectories);
  }
  ((void (*)(id, SEL, BOOL))objc_msgSend)(panel, @selector(setAllowsMultipleSelection:), allowsMultipleSelection);

  [self applyOpenPanelOptions:panel options:options];

  SEL runModalSelector = NSSelectorFromString(@"runModal");
  if (runModalSelector == nil || ![panel respondsToSelector:runModalSelector]) {
    return [self errorResultWithCode:TFPCodePanelUnavailable
                             message:@"NSOpenPanel runModal is unavailable."
                               panel:TFPPanelOpen
                       selectionType:selectionType
                           cancelled:NO];
  }

  NSInteger response = ((NSInteger (*)(id, SEL))objc_msgSend)(panel, runModalSelector);
  if (response != 1) {
    return [self errorResultWithCode:TFPCodeUserCancelled
                             message:@"User cancelled the panel."
                               panel:TFPPanelOpen
                       selectionType:selectionType
                           cancelled:YES];
  }

  NSArray *urls = ((id (*)(id, SEL))objc_msgSend)(panel, @selector(URLs));
  NSArray<NSString *> *paths = [self pathsFromURLs:urls];
  if (paths.count == 0) {
    return [self errorResultWithCode:TFPCodeNoSelection
                             message:@"No file or folder was selected."
                               panel:TFPPanelOpen
                       selectionType:selectionType
                           cancelled:YES];
  }

  if (allowsMultipleSelection) {
    return [self successResultWithPanel:TFPPanelOpen selectionType:selectionType path:nil paths:paths];
  }

  return [self successResultWithPanel:TFPPanelOpen selectionType:selectionType path:[paths firstObject] paths:paths];
#endif
}

- (NSDictionary *)savePanelResultWithOptions:(NSDictionary *)options
{
#if !TARGET_OS_MACCATALYST
  return [self errorResultWithCode:TFPCodeNotSupported
                           message:@"This method is only supported on Mac Catalyst."
                             panel:TFPPanelSave
                     selectionType:@"save"
                         cancelled:NO];
#else
  NSDictionary *startDirectoryError = [self validateStartDirectoryInOptions:options panel:TFPPanelSave selectionType:@"save"];
  if (startDirectoryError != nil) {
    return startDirectoryError;
  }

  Class savePanelClass = NSClassFromString(@"NSSavePanel");
  SEL savePanelSelector = NSSelectorFromString(@"savePanel");
  if (savePanelClass == nil || savePanelSelector == nil || ![savePanelClass respondsToSelector:savePanelSelector]) {
    return [self errorResultWithCode:TFPCodePanelUnavailable
                             message:@"NSSavePanel is unavailable in this runtime."
                               panel:TFPPanelSave
                       selectionType:@"save"
                           cancelled:NO];
  }

  id panel = ((id (*)(id, SEL))objc_msgSend)(savePanelClass, savePanelSelector);
  if (panel == nil) {
    return [self errorResultWithCode:TFPCodePanelUnavailable
                             message:@"Could not create NSSavePanel instance."
                               panel:TFPPanelSave
                       selectionType:@"save"
                           cancelled:NO];
  }

  [self applyCommonPanelOptions:panel options:options];

  NSString *defaultName = [self stringOptionForKey:@"defaultName" options:options];
  SEL setNameFieldStringValueSelector = NSSelectorFromString(@"setNameFieldStringValue:");
  if (defaultName.length > 0 && setNameFieldStringValueSelector != nil && [panel respondsToSelector:setNameFieldStringValueSelector]) {
    ((void (*)(id, SEL, id))objc_msgSend)(panel, setNameFieldStringValueSelector, defaultName);
  }

  BOOL hasExplicitTypeFilter = NO;
  SEL setAllowedContentTypesSelector = NSSelectorFromString(@"setAllowedContentTypes:");
  NSArray *allowedContentTypes = [self allowedContentTypesFromOptions:options];
  if (allowedContentTypes.count > 0 && setAllowedContentTypesSelector != nil && [panel respondsToSelector:setAllowedContentTypesSelector]) {
    ((void (*)(id, SEL, id))objc_msgSend)(panel, setAllowedContentTypesSelector, allowedContentTypes);
    hasExplicitTypeFilter = YES;
  }

  NSString *defaultExtension = [self stringOptionForKey:@"defaultExtension" options:options];
  if (!hasExplicitTypeFilter && defaultExtension.length > 0) {
    if ([defaultExtension hasPrefix:@"."]) {
      defaultExtension = [defaultExtension substringFromIndex:1];
    }

    SEL setAllowedFileTypesSelector = NSSelectorFromString(@"setAllowedFileTypes:");
    if (defaultExtension.length > 0 && setAllowedFileTypesSelector != nil && [panel respondsToSelector:setAllowedFileTypesSelector]) {
      ((void (*)(id, SEL, id))objc_msgSend)(panel, setAllowedFileTypesSelector, @[ defaultExtension ]);
    }
  }

  SEL runModalSelector = NSSelectorFromString(@"runModal");
  if (runModalSelector == nil || ![panel respondsToSelector:runModalSelector]) {
    return [self errorResultWithCode:TFPCodePanelUnavailable
                             message:@"NSSavePanel runModal is unavailable."
                               panel:TFPPanelSave
                       selectionType:@"save"
                           cancelled:NO];
  }

  NSInteger response = ((NSInteger (*)(id, SEL))objc_msgSend)(panel, runModalSelector);
  if (response != 1) {
    return [self errorResultWithCode:TFPCodeUserCancelled
                             message:@"User cancelled the panel."
                               panel:TFPPanelSave
                       selectionType:@"save"
                           cancelled:YES];
  }

  id selectedURL = ((id (*)(id, SEL))objc_msgSend)(panel, @selector(URL));
  NSString *path = [self pathFromURL:selectedURL];
  if (path.length == 0) {
    return [self errorResultWithCode:TFPCodeNoSelection
                             message:@"No save path was selected."
                               panel:TFPPanelSave
                       selectionType:@"save"
                           cancelled:YES];
  }

  return [self successResultWithPanel:TFPPanelSave selectionType:@"save" path:path paths:@[ path ]];
#endif
}

- (void)scheduleAsyncSelector:(SEL)selector options:(NSDictionary *)options callback:(KrollCallback *)callback extra:(NSDictionary *)extra
{
  if (selector == nil || callback == nil) {
    return;
  }

  NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithObject:callback forKey:@"callback"];
  if (options != nil) {
    [payload setObject:options forKey:@"options"];
  }
  if (extra != nil) {
    [payload addEntriesFromDictionary:extra];
  }

  [self performSelector:selector withObject:payload afterDelay:0];
}

- (void)asyncRunOpenPanel:(NSDictionary *)payload
{
  NSDictionary *options = [payload objectForKey:@"options"];
  KrollCallback *callback = [payload objectForKey:@"callback"];

  BOOL chooseFiles = [TiUtils boolValue:[payload objectForKey:@"chooseFiles"] def:NO];
  BOOL chooseDirectories = [TiUtils boolValue:[payload objectForKey:@"chooseDirectories"] def:NO];
  BOOL allowsMultiple = [TiUtils boolValue:[payload objectForKey:@"allowsMultipleSelection"] def:NO];
  NSString *selectionType = [payload objectForKey:@"selectionType"];

  NSDictionary *result = [self openPanelResultWithChooseFiles:chooseFiles
                                            chooseDirectories:chooseDirectories
                                      allowsMultipleSelection:allowsMultiple
                                                      options:options
                                                selectionType:selectionType];
  [self dispatchResultObject:result callback:callback];
}

- (void)asyncRunSavePanel:(NSDictionary *)payload
{
  NSDictionary *options = [payload objectForKey:@"options"];
  KrollCallback *callback = [payload objectForKey:@"callback"];

  NSDictionary *result = [self savePanelResultWithOptions:options];
  [self dispatchResultObject:result callback:callback];
}

- (id)dispatchOptionErrorOrValidatedOptionsFromArgs:(id)args
                                          panel:(NSString *)panel
                                  selectionType:(NSString *)selectionType
                                       callback:(KrollCallback *)callback
                               validatedOptions:(NSDictionary **)validatedOptions
{
  NSString *validationError = nil;
  NSDictionary *options = [self validatedOptionsFromRaw:[self rawOptionsFromArgs:args] errorMessage:&validationError];
  if (options == nil) {
    NSDictionary *result = [self errorResultWithCode:TFPCodeInvalidOptions
                                             message:validationError
                                               panel:panel
                                       selectionType:selectionType
                                           cancelled:NO];
    return [self dispatchResultObject:result callback:callback];
  }

  if (validatedOptions != NULL) {
    *validatedOptions = options;
  }

  return nil;
}

#pragma mark Public APIs

- (id)pickFolder:(id)args
{
  ENSURE_UI_THREAD(pickFolder, args);

  KrollCallback *callback = [self callbackFromArgs:args];
  NSDictionary *options = nil;
  id validationDispatch = [self dispatchOptionErrorOrValidatedOptionsFromArgs:args
                                                                        panel:TFPPanelOpen
                                                                selectionType:@"folder"
                                                                     callback:callback
                                                             validatedOptions:&options];
  if (validationDispatch != nil) {
    return validationDispatch;
  }

  if (callback != nil) {
    [self scheduleAsyncSelector:@selector(asyncRunOpenPanel:)
                        options:options
                       callback:callback
                          extra:@{
                            @"chooseFiles" : @NO,
                            @"chooseDirectories" : @YES,
                            @"allowsMultipleSelection" : @NO,
                            @"selectionType" : @"folder"
                          }];
    return nil;
  }

  NSDictionary *result = [self openPanelResultWithChooseFiles:NO
                                            chooseDirectories:YES
                                      allowsMultipleSelection:NO
                                                      options:options
                                                selectionType:@"folder"];
  return [self dispatchResultObject:result callback:nil];
}

- (id)pickFile:(id)args
{
  ENSURE_UI_THREAD(pickFile, args);

  KrollCallback *callback = [self callbackFromArgs:args];
  NSDictionary *options = nil;
  id validationDispatch = [self dispatchOptionErrorOrValidatedOptionsFromArgs:args
                                                                        panel:TFPPanelOpen
                                                                selectionType:@"file"
                                                                     callback:callback
                                                             validatedOptions:&options];
  if (validationDispatch != nil) {
    return validationDispatch;
  }

  if (callback != nil) {
    [self scheduleAsyncSelector:@selector(asyncRunOpenPanel:)
                        options:options
                       callback:callback
                          extra:@{
                            @"chooseFiles" : @YES,
                            @"chooseDirectories" : @NO,
                            @"allowsMultipleSelection" : @NO,
                            @"selectionType" : @"file"
                          }];
    return nil;
  }

  NSDictionary *result = [self openPanelResultWithChooseFiles:YES
                                            chooseDirectories:NO
                                      allowsMultipleSelection:NO
                                                      options:options
                                                selectionType:@"file"];
  return [self dispatchResultObject:result callback:nil];
}

- (id)pickFiles:(id)args
{
  ENSURE_UI_THREAD(pickFiles, args);

  KrollCallback *callback = [self callbackFromArgs:args];
  NSDictionary *options = nil;
  id validationDispatch = [self dispatchOptionErrorOrValidatedOptionsFromArgs:args
                                                                        panel:TFPPanelOpen
                                                                selectionType:@"files"
                                                                     callback:callback
                                                             validatedOptions:&options];
  if (validationDispatch != nil) {
    return validationDispatch;
  }

  BOOL allowMultiple = YES;
  if ([options objectForKey:@"allowMultiple"] != nil) {
    allowMultiple = [TiUtils boolValue:[options objectForKey:@"allowMultiple"] def:YES];
  }

  if (callback != nil) {
    [self scheduleAsyncSelector:@selector(asyncRunOpenPanel:)
                        options:options
                       callback:callback
                          extra:@{
                            @"chooseFiles" : @YES,
                            @"chooseDirectories" : @NO,
                            @"allowsMultipleSelection" : @(allowMultiple),
                            @"selectionType" : @"files"
                          }];
    return nil;
  }

  NSDictionary *result = [self openPanelResultWithChooseFiles:YES
                                            chooseDirectories:NO
                                      allowsMultipleSelection:allowMultiple
                                                      options:options
                                                selectionType:@"files"];
  return [self dispatchResultObject:result callback:nil];
}

- (id)openDocument:(id)args
{
  ENSURE_UI_THREAD(openDocument, args);

  KrollCallback *callback = [self callbackFromArgs:args];
  NSDictionary *options = nil;
  id validationDispatch = [self dispatchOptionErrorOrValidatedOptionsFromArgs:args
                                                                        panel:TFPPanelOpen
                                                                selectionType:@"document"
                                                                     callback:callback
                                                             validatedOptions:&options];
  if (validationDispatch != nil) {
    return validationDispatch;
  }

  if (callback != nil) {
    [self scheduleAsyncSelector:@selector(asyncRunOpenPanel:)
                        options:options
                       callback:callback
                          extra:@{
                            @"chooseFiles" : @YES,
                            @"chooseDirectories" : @NO,
                            @"allowsMultipleSelection" : @NO,
                            @"selectionType" : @"document"
                          }];
    return nil;
  }

  NSDictionary *result = [self openPanelResultWithChooseFiles:YES
                                            chooseDirectories:NO
                                      allowsMultipleSelection:NO
                                                      options:options
                                                selectionType:@"document"];
  return [self dispatchResultObject:result callback:nil];
}

- (id)openDocuments:(id)args
{
  ENSURE_UI_THREAD(openDocuments, args);

  KrollCallback *callback = [self callbackFromArgs:args];
  NSDictionary *options = nil;
  id validationDispatch = [self dispatchOptionErrorOrValidatedOptionsFromArgs:args
                                                                        panel:TFPPanelOpen
                                                                selectionType:@"documents"
                                                                     callback:callback
                                                             validatedOptions:&options];
  if (validationDispatch != nil) {
    return validationDispatch;
  }

  if (callback != nil) {
    [self scheduleAsyncSelector:@selector(asyncRunOpenPanel:)
                        options:options
                       callback:callback
                          extra:@{
                            @"chooseFiles" : @YES,
                            @"chooseDirectories" : @NO,
                            @"allowsMultipleSelection" : @YES,
                            @"selectionType" : @"documents"
                          }];
    return nil;
  }

  NSDictionary *result = [self openPanelResultWithChooseFiles:YES
                                            chooseDirectories:NO
                                      allowsMultipleSelection:YES
                                                      options:options
                                                selectionType:@"documents"];
  return [self dispatchResultObject:result callback:nil];
}

- (id)saveFile:(id)args
{
  ENSURE_UI_THREAD(saveFile, args);

  KrollCallback *callback = [self callbackFromArgs:args];
  NSDictionary *options = nil;
  id validationDispatch = [self dispatchOptionErrorOrValidatedOptionsFromArgs:args
                                                                        panel:TFPPanelSave
                                                                selectionType:@"save"
                                                                     callback:callback
                                                             validatedOptions:&options];
  if (validationDispatch != nil) {
    return validationDispatch;
  }

  if (callback != nil) {
    [self scheduleAsyncSelector:@selector(asyncRunSavePanel:)
                        options:options
                       callback:callback
                          extra:nil];
    return nil;
  }

  NSDictionary *result = [self savePanelResultWithOptions:options];
  return [self dispatchResultObject:result callback:nil];
}

@end
