//
//  PutComponents.swift
//  SwiftAWSS3
//
//  Created by Ben Spratling on 5/13/17.
//
//

import Foundation
import SwiftAWSSignatureV4

///used to build a PUT request with options
public struct S3PutComponents {
	
	public let bucket:AWSBucket
	
	public let objectName:String
	
	public let data:Data
	
	public init(bucket:AWSBucket, objectName:String, data:Data) {
		self.bucket = bucket
		self.objectName = objectName
		self.data = data
	}
	
	
	public var mimeType:String?
	
	public var serverSideEncryption:ServerSideEncryption?
	
	//TODO: encryption context
	
	/// value for header x-amz-acl
	/// adds bucket-owner-full-control if nil
	//see http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#CannedACL
	public var acl:String?
	
	//not tested
	///after setting all properties, call this to get a new request
	public var request:URLRequest? {
		guard let encodedName:String = objectName.aws_uriEncoded(encodeSlash: false)
			,let url = URL(string:"https://\(bucket.bucket).\(bucket.server)\(encodedName)") else {
			//guard let url = URL(string:"https://examplebucket.s3.amazonaws.com/photos/photo1.jpg") else {
			return nil
		}
		var request:URLRequest = URLRequest(url: url, cachePolicy:.reloadIgnoringLocalAndRemoteCacheData)
		request.httpMethod = "PUT"
		let acl:String = self.acl ?? "bucket-owner-full-control"
		request.addValue(acl, forHTTPHeaderField: "x-amz-acl")
		request.addValue("\(data.count)", forHTTPHeaderField: "Content-Length")
		if let mime = mimeType {
			request.addValue(mime, forHTTPHeaderField: "Content-Type")
		}
		request.httpBody = data
		if let encryption:ServerSideEncryption = serverSideEncryption {
			switch encryption {
			case .default:
				request.addValue("aws:kms", forHTTPHeaderField: "x-amz-server-side-encryption")
			case .master(let keyID):
				request.addValue("aws:kms", forHTTPHeaderField: "x-amz-server-side-encryption")
				request.addValue(keyID, forHTTPHeaderField: "x-amz-server-side-encryption-aws-kms-key-id")
			}
		}
		
		return request
	}
	
}

