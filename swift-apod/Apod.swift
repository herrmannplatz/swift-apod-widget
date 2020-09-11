//
//  Apod.swift
//  swift-apod
//
//  Created by rehez on 12.07.20.
//


struct Apod: Codable{
    let date : String
    let explanation : String
    let url : String
    let hdurl : String? // missing if media_type is not image
    let media_type : String
    let service_version : String
    let title : String
    let copyright : String?
}
