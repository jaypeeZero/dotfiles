#!/usr/bin/env swift

import Foundation

print("Updating all git repos...")
print("")

let manager = NSFileManager.defaultManager()

func nuTraverse(directoryUrl: NSURL) throws {
    let contents = try manager.contentsOfDirectoryAtURL(directoryUrl, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: [])
    for url in contents {
        var isDirectory: ObjCBool = false
        manager.fileExistsAtPath(url.path!, isDirectory:&isDirectory)
        if isDirectory {
            let contents = try manager.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: [])
                .map { url in return url.lastPathComponent! }
            if contents.contains(".git") {
                let relativePath = url.relativePath!
                let numberOfStars = relativePath.characters.count + 4
                let stars = String(count:numberOfStars, repeatedValue:"*" as Character)
                print("\(stars)")
                print("* \(relativePath) *")
                print("\(stars)")
                let task = NSTask()
                task.currentDirectoryPath = url.path!
                task.launchPath = "/usr/bin/env"
                task.arguments = ["git", "pull"]
                let pipe = NSPipe()
                task.standardOutput = pipe
                task.launch()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output: String = String(data: data, encoding: NSUTF8StringEncoding) {
                    print(output)
                }
                task.waitUntilExit()
            } else {
                try nuTraverse(url)
            }
        }
    }
}

let currentUrl = NSURL(fileURLWithPath: manager.currentDirectoryPath, isDirectory: true)
do {
    try nuTraverse(currentUrl)
}