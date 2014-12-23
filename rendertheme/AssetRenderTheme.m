/*
 * Copyright 2014 Matthew Hall
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

#import "AssetRenderTheme.h"
#import "java/io/FileInputStream.h"

@implementation AssetRenderTheme

-(id)initWithAssetPath:(NSString*)assetPath {
    self = [super init];
    if (self) {
        _assetPath = assetPath;
    }
    return self;
}

- (id<OrgMapsforgeMapRenderthemeXmlRenderThemeMenuCallback>)getMenuCallback {
    return nil;
}

- (NSString *)getRelativePathPrefix {
    return @"";
}

- (JavaIoInputStream *)getRenderThemeAsStream {
    JavaIoFileInputStream *fileStream = [[[JavaIoFileInputStream alloc] initWithNSString:_assetPath] autorelease];
    return fileStream;
}

@end
