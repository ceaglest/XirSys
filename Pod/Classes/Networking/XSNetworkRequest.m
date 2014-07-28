//
//  XSNetworkRequest.m
//  Pods
//
//  Created by Sam Symons on 2014-07-27.
//
//

#import "XSNetworkRequest.h"

NSString * const XSBaseURL = @"";

@interface XSNetworkRequest ()

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *secretKey;

@property (nonatomic, copy) NSDictionary *credentials;

- (NSURLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters method:(NSString *)method;
- (NSDictionary *)parametersByMergingCredentials:(NSDictionary *)parameters;

@end

@implementation XSNetworkRequest

- (instancetype)initWithUsername:(NSString *)username secretKey:(NSString *)secretKey
{
    NSParameterAssert(username);
    NSParameterAssert(secretKey);
    
    if (self = [super init]) {
        _username = username;
        _secretKey = secretKey;
        
        _credentials = @{ @"ident": _username, @"secret": _secretKey };
    }
    
    return self;
}

- (NSURLSessionDataTask *)postPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(XSCompletion)completion
{
    NSParameterAssert(path);
    
    NSURLRequest *request = [self requestWithPath:path parameters:parameters method:@"POST"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request];
    
    return task;
}

#pragma mark - Private

- (NSURLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters method:(NSString *)method
{
    NSURL *URL = [[NSURL URLWithString:XSBaseURL] URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error];
    
    if (error) {
        return nil;
    }
    
    [request setHTTPMethod:method];
    [request setHTTPBody:JSONData];
    
    return [request copy];
}

- (NSDictionary *)parametersByMergingCredentials:(NSDictionary *)parameters
{
    NSMutableDictionary *mutableParameters = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
    [mutableParameters addEntriesFromDictionary:self.credentials];
    
    return [mutableParameters copy];
}

@end
